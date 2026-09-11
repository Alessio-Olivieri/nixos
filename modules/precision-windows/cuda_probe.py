#!/usr/bin/env python3
"""Execute a CUDA kernel and check its output; never used by monitoring."""
import argparse
import ctypes as C
import json
import time


def probe(hold=0):
    cuda = C.CDLL("/run/opengl-driver/lib/libcuda.so.1")
    def call(name, *args):
        result = getattr(cuda, name)(*args)
        if result:
            message = C.c_char_p()
            cuda.cuGetErrorString(result, C.byref(message))
            raise RuntimeError(f"{name}: {message.value.decode() if message.value else result}")
    device, count = C.c_int(), C.c_int()
    context, module, function = C.c_void_p(), C.c_void_p(), C.c_void_p()
    memory = C.c_uint64()
    call("cuInit", 0)
    call("cuDeviceGetCount", C.byref(count))
    if count.value != 1:
        raise RuntimeError(f"Expected this laptop's single CUDA GPU; found {count.value}")
    call("cuDeviceGet", C.byref(device), 0)
    call("cuDevicePrimaryCtxRetain", C.byref(context), device)
    try:
        call("cuCtxSetCurrent", context)
        call("cuMemAlloc_v2", C.byref(memory), C.c_size_t(128))
        ptx = C.create_string_buffer(b"""
.version 7.0
.target sm_52
.address_size 64
.visible .entry verify(.param .u64 output) {
 .reg .u32 tid, value;
 .reg .u64 ptr, offset;
 ld.param.u64 ptr, [output];
 mov.u32 tid, %tid.x;
 mul.wide.u32 offset, tid, 4;
 add.u64 ptr, ptr, offset;
 add.u32 value, tid, 42;
 st.global.u32 [ptr], value;
 ret;
}
""")
        call("cuModuleLoadData", C.byref(module), ptx)
        call("cuModuleGetFunction", C.byref(function), module, b"verify")
        arguments = (C.c_void_p * 1)(C.addressof(memory))
        call("cuLaunchKernel", function, 1, 1, 1, 32, 1, 1, 0, C.c_void_p(), arguments, C.c_void_p())
        call("cuCtxSynchronize")
        output = (C.c_uint32 * 32)()
        call("cuMemcpyDtoH_v2", output, memory, C.c_size_t(128))
        if list(output) != list(range(42, 74)):
            raise RuntimeError("CUDA kernel returned incorrect data")
        print(json.dumps({"cuda": "passed", "kernel": "32 threads, tid + 42", "verified_values": 32}), flush=True)
        if hold:
            time.sleep(hold)
    finally:
        if module.value:
            call("cuModuleUnload", module)
        if memory.value:
            call("cuMemFree_v2", memory)
        call("cuDevicePrimaryCtxRelease_v2", device)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--hold", type=int, default=0)
    probe(parser.parse_args().hold)
