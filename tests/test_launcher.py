import json
import os
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


class LauncherTests(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.addCleanup(self.tmp.cleanup)
        self.root = Path(self.tmp.name)
        self.bin = self.root / 'bin'
        self.bin.mkdir()
        self.trace = self.root / 'trace'
        self.env = dict(os.environ, HOME=str(self.root), XDG_STATE_HOME=str(self.root / 'state'),
                        PATH=f'{self.bin}:{os.environ["PATH"]}', TRACE=str(self.trace),
                        SANDBOX_ALLOW_TCG='1')
        for command in ['systemctl', 'systemd-run', 'ss', 'nix-store']:
            p = self.bin / command
            p.write_text(f'#!{sys.executable}\n' + '''import json, os, sys
with open(os.environ['TRACE'], 'a') as f: f.write(json.dumps(sys.argv) + '\\n')
if 'is-active' in sys.argv: sys.exit(3)
if sys.argv[0].endswith('/ss') and os.environ.get('PORT_BUSY'): print('LISTEN 0 1 127.0.0.1:2222')
''')
            p.chmod(0o755)
        self.script = self.root / 'sandbox'
        source = ROOT / 'host/sandbox.sh'
        self.assertTrue(source.exists(), 'launcher must exist')
        self.script.write_text(source.read_text().replace('@vmRunner@', '/fake/run-vm'))

    def run_launcher(self, *args, **env):
        return subprocess.run(['bash', str(self.script), *args], env=self.env | env,
                              capture_output=True, text=True, timeout=10)

    def calls(self):
        return [json.loads(line) for line in self.trace.read_text().splitlines()]

    def test_start_uses_persistent_disk_and_only_generated_public_key(self):
        result = self.run_launcher('start')
        self.assertEqual(result.returncode, 0, result.stderr)
        calls = self.calls()
        start = next(c for c in calls if c[0].endswith('/systemd-run'))
        args = ' '.join(start)
        state = self.root / 'state/nix-sandbox/main'
        self.assertIn(f'NIX_DISK_IMAGE={state}/root.qcow2', args)
        self.assertIn(f'TMPDIR={state}/runtime', args)
        self.assertIn('USE_TMPDIR=1', args)
        self.assertTrue((state / 'runtime').is_dir())
        self.assertIn(f'file={state}/id_ed25519.pub', args)
        self.assertNotIn('file=' + str(state / 'id_ed25519 '), args)
        self.assertTrue((state / 'id_ed25519').exists())
        self.assertEqual((state / 'id_ed25519').stat().st_mode & 0o777, 0o600)
        self.assertIn('ExecStop=', args)
        self.assertEqual(start[-1], '/fake/run-vm')

    def test_second_start_keeps_existing_key(self):
        self.assertEqual(self.run_launcher('start').returncode, 0)
        key = self.root / 'state/nix-sandbox/main/id_ed25519'
        original = key.read_bytes()
        self.assertEqual(self.run_launcher('start').returncode, 0)
        self.assertEqual(key.read_bytes(), original)

    def test_busy_port_refuses_without_starting_or_creating_key(self):
        result = self.run_launcher('start', PORT_BUSY='1')
        self.assertNotEqual(result.returncode, 0)
        self.assertIn('port', result.stderr.lower())
        self.assertFalse(any(c[0].endswith('/systemd-run') for c in self.calls()))
        self.assertFalse((self.root / 'state/nix-sandbox/main/id_ed25519').exists())

    def test_stop_does_not_create_vm_state(self):
        result = self.run_launcher('stop')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn('stop', self.calls()[0])
        self.assertFalse((self.root / 'state').exists())

    def test_unknown_action_is_not_executed(self):
        self.assertNotEqual(self.run_launcher('destroy').returncode, 0)
        self.assertFalse(self.trace.exists())

    def test_unsafe_state_path_is_rejected(self):
        result = self.run_launcher('start', XDG_STATE_HOME=str(self.root / 'has space'))
        self.assertNotEqual(result.returncode, 0)
        self.assertIn('path', result.stderr.lower())


if __name__ == '__main__':
    unittest.main()
