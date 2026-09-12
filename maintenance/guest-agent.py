#!/usr/bin/env python3
"""Compatibility entry point; implementation lives with guest provisioning."""
from pathlib import Path
import runpy

runpy.run_path(str(Path(__file__).resolve().parents[1] / 'modules/precision-windows/guest/qga-runner.py'), run_name='__main__')
