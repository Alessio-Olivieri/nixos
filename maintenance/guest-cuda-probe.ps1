$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'
Add-Type -TypeDefinition @'
using System;
using System.Runtime.InteropServices;
public static class PrecisionCudaProbe {
    [DllImport("nvcuda.dll")] static extern int cuInit(uint flags);
    [DllImport("nvcuda.dll")] static extern int cuDeviceGet(out int device, int ordinal);
    [DllImport("nvcuda.dll")] static extern int cuDevicePrimaryCtxRetain(out IntPtr context, int device);
    [DllImport("nvcuda.dll")] static extern int cuDevicePrimaryCtxRelease_v2(int device);
    [DllImport("nvcuda.dll")] static extern int cuCtxSetCurrent(IntPtr context);
    [DllImport("nvcuda.dll")] static extern int cuMemAlloc_v2(out ulong ptr, UIntPtr bytes);
    [DllImport("nvcuda.dll")] static extern int cuMemFree_v2(ulong ptr);
    [DllImport("nvcuda.dll")] static extern int cuModuleLoadData(out IntPtr module, IntPtr data);
    [DllImport("nvcuda.dll")] static extern int cuModuleUnload(IntPtr module);
    [DllImport("nvcuda.dll")] static extern int cuModuleGetFunction(out IntPtr function, IntPtr module, string name);
    [DllImport("nvcuda.dll")] static extern int cuLaunchKernel(IntPtr function, uint gx, uint gy, uint gz, uint bx, uint by, uint bz, uint shared, IntPtr stream, IntPtr[] args, IntPtr extra);
    [DllImport("nvcuda.dll")] static extern int cuCtxSynchronize();
    [DllImport("nvcuda.dll")] static extern int cuMemcpyDtoH_v2([Out] uint[] output, ulong input, UIntPtr bytes);
    static void Check(int value, string operation) { if (value != 0) throw new Exception(operation + " failed: CUDA " + value); }
    public static string Run() {
        int device; IntPtr context, module = IntPtr.Zero, function;
        ulong memory = 0; IntPtr ptx = IntPtr.Zero, argument = IntPtr.Zero;
        Check(cuInit(0), "cuInit"); Check(cuDeviceGet(out device, 0), "cuDeviceGet");
        Check(cuDevicePrimaryCtxRetain(out context, device), "cuDevicePrimaryCtxRetain");
        try {
            Check(cuCtxSetCurrent(context), "cuCtxSetCurrent");
            Check(cuMemAlloc_v2(out memory, (UIntPtr)128), "cuMemAlloc");
            ptx = Marshal.StringToHGlobalAnsi(@".version 7.0
.target sm_52
.address_size 64
.visible .entry verify(.param .u64 output) {
 .reg .u32 tid, value; .reg .u64 ptr, offset;
 ld.param.u64 ptr, [output]; mov.u32 tid, %tid.x;
 mul.wide.u32 offset, tid, 4; add.u64 ptr, ptr, offset;
 add.u32 value, tid, 42; st.global.u32 [ptr], value; ret;
}");
            Check(cuModuleLoadData(out module, ptx), "cuModuleLoadData");
            Check(cuModuleGetFunction(out function, module, "verify"), "cuModuleGetFunction");
            argument = Marshal.AllocHGlobal(8); Marshal.WriteInt64(argument, unchecked((long)memory));
            Check(cuLaunchKernel(function, 1, 1, 1, 32, 1, 1, 0, IntPtr.Zero, new IntPtr[] {argument}, IntPtr.Zero), "cuLaunchKernel");
            Check(cuCtxSynchronize(), "cuCtxSynchronize");
            uint[] values = new uint[32];
            Check(cuMemcpyDtoH_v2(values, memory, (UIntPtr)128), "cuMemcpyDtoH");
            for (uint i=0; i<32; i++) if (values[i] != i+42) throw new Exception("Incorrect GPU computation");
            return "PASS: Windows CUDA kernel verified 32 values (tid + 42) on the passed-through NVIDIA GPU";
        } finally {
            if (module != IntPtr.Zero) cuModuleUnload(module);
            if (memory != 0) cuMemFree_v2(memory);
            if (ptx != IntPtr.Zero) Marshal.FreeHGlobal(ptx);
            if (argument != IntPtr.Zero) Marshal.FreeHGlobal(argument);
            cuDevicePrimaryCtxRelease_v2(device);
        }
    }
}
'@
[PrecisionCudaProbe]::Run()
