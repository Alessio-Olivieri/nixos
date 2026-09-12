"""Exercise signal cleanup as an ordinary user in an isolated temporary path."""
import os
from pathlib import Path
import signal
import subprocess
import sys
import tempfile
import time
import unittest


class ActivationCleanupTests(unittest.TestCase):
    def test_termination_signals_remove_only_the_test_socket_directory(self):
        for sig in (signal.SIGHUP, signal.SIGTERM, signal.SIGINT):
            with self.subTest(signal=sig), tempfile.TemporaryDirectory() as directory:
                target = Path(directory) / 'activation-test'
                script = Path(__file__).with_name('hdmi-activation-session.py')
                code = '''
import os, pathlib, runpy, sys
from unittest.mock import patch
ns = runpy.run_path(sys.argv[1], run_name='activation_cleanup_test')
target = pathlib.Path(sys.argv[2])
ns['main'].__globals__.update(DIRECTORY=target, SOCKET=target / 'control.sock',
                            activation_path=lambda _: None)
with patch('os.geteuid', return_value=0), patch('os.chown'), \
     patch.dict(os.environ, {'SUDO_UID': '1001'}):
    ns['main']()
'''
                # No sudo, activation, socket requests, or real /run paths.
                process = subprocess.Popen([sys.executable, '-c', code, str(script), str(target)],
                                           stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
                try:
                    deadline = time.monotonic() + 5
                    while not (target / 'control.sock').exists():
                        if process.poll() is not None or time.monotonic() >= deadline:
                            self.fail('Test helper did not become ready')
                        time.sleep(0.02)
                    os.kill(process.pid, sig)
                    output, errors = process.communicate(timeout=5)
                    self.assertEqual(process.returncode, 0, errors)
                    self.assertFalse(target.exists(), output)
                finally:
                    if process.poll() is None:
                        process.terminate()
                        process.communicate(timeout=5)


if __name__ == '__main__':
    unittest.main()
