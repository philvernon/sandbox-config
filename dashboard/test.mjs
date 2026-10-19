import test from 'node:test';
import assert from 'node:assert/strict';
import { readFileSync, existsSync } from 'node:fs';
import { runInNewContext } from 'node:vm';

// A wrong service port or hardcoded hostname must break these checks.
test('dashboard includes both tools and a mobile viewport', () => {
  const file = new URL('./index.html', import.meta.url);
  assert.ok(existsSync(file), 'dashboard page must exist');
  const html = readFileSync(file, 'utf8');
  assert.match(html, /name="viewport"/);
  assert.match(html, /href="http:\/\/127\.0\.0\.1:8765\/" data-port="8765"/);
  assert.match(html, /href="http:\/\/127\.0\.0\.1:30141\/" data-port="30141"/);
  assert.match(html, /src="links.js"/);
});

for (const host of ['sandbox.example', '127.0.0.1', 'localhost', '[::1]']) {
  test(`service links keep the dashboard hostname: ${host}`, () => {
    const file = new URL('./links.js', import.meta.url);
    assert.ok(existsSync(file), 'hostname-aware links script must exist');
    const links = ['8765', '30141'].map(port => ({ dataset: { port }, href: '' }));
    runInNewContext(readFileSync(file, 'utf8'), {
      URL,
      window: { location: { href: `http://${host}:8080/?ignored=yes#top` } },
      document: { querySelectorAll: () => links },
    });
    assert.deepEqual(links.map(link => link.href), [
      `http://${host}:8765/`, `http://${host}:30141/`,
    ]);
  });
}
