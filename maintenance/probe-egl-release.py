#!/usr/bin/env python3
"""Bounded render-node probe; never takes DRM master or changes a display.

Intentionally wakes the selected GPU. Reports only this process's graphics FDs.
Use the exact EGL/GBM libraries mapped by the compositor for a comparable test.
"""
import argparse
import ctypes as C
import json
import os
from pathlib import Path


def snapshot(stage):
    targets = []
    for fd in Path('/proc/self/fd').iterdir():
        try:
            target = os.readlink(fd)
        except FileNotFoundError:
            continue
        if target.startswith(('/dev/dri/', '/dev/nvidia')):
            targets.append(target)
    print(json.dumps({'stage': stage, 'fds': sorted(targets)}), flush=True)


def bind(lib, name, result, *args):
    fn = getattr(lib, name)
    fn.restype = result
    fn.argtypes = args
    return fn


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--egl', required=True)
    parser.add_argument('--gbm', required=True)
    parser.add_argument('--device', required=True)
    args = parser.parse_args()
    if not args.device.startswith('/dev/dri/renderD') or not args.device[16:].isdigit():
        parser.error('only a DRM render node is permitted')
    ptr, integer, boolean = C.c_void_p, C.c_int, C.c_uint
    snapshot('before-library-load')
    egl, gbm = C.CDLL(args.egl), C.CDLL(args.gbm)
    create_gbm = bind(gbm, 'gbm_create_device', ptr, integer)
    destroy_gbm = bind(gbm, 'gbm_device_destroy', None, ptr)
    get_display = bind(egl, 'eglGetPlatformDisplay', ptr, C.c_uint, ptr, ptr)
    initialize = bind(egl, 'eglInitialize', boolean, ptr, ptr, ptr)
    bind_api = bind(egl, 'eglBindAPI', boolean, C.c_uint)
    create_context = bind(egl, 'eglCreateContext', ptr, ptr, ptr, ptr, C.POINTER(integer))
    make_current = bind(egl, 'eglMakeCurrent', boolean, ptr, ptr, ptr, ptr)
    destroy_context = bind(egl, 'eglDestroyContext', boolean, ptr, ptr)
    terminate = bind(egl, 'eglTerminate', boolean, ptr)
    release_thread = bind(egl, 'eglReleaseThread', boolean)
    get_error = bind(egl, 'eglGetError', integer)

    def checked(value, operation):
        if not value:
            raise RuntimeError(f'{operation} failed: EGL {get_error():#x}')
        return value

    fd, device, display, context = -1, None, None, None
    try:
        snapshot('libraries-loaded')
        fd = os.open(args.device, os.O_RDWR | os.O_CLOEXEC)
        device = checked(create_gbm(fd), 'gbm_create_device')
        snapshot('gbm-created')
        display = checked(get_display(0x31D7, device, None), 'get-platform-display')
        checked(initialize(display, None, None), 'initialize')
        snapshot('egl-initialized')
        checked(bind_api(0x30A0), 'bind-OpenGL-ES')
        attrs = (integer * 3)(0x3098, 2, 0x3038)
        context = checked(create_context(display, None, None, attrs), 'create-context')
        checked(make_current(display, None, None, context), 'make-current')
        snapshot('context-current')
    finally:
        if context:
            checked(make_current(display, None, None, None), 'clear-current')
            checked(destroy_context(display, context), 'destroy-context')
        if display:
            checked(terminate(display), 'terminate')
        if device:
            destroy_gbm(device)
        if fd >= 0:
            os.close(fd)
        snapshot('all-explicit-resources-released')
        checked(release_thread(), 'release-thread')
        snapshot('thread-released')


if __name__ == '__main__':
    main()
