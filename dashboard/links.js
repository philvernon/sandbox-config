// Keep links on the hostname used to open this dashboard (LAN or Tailscale).
for (const link of document.querySelectorAll('a[data-port]')) {
  const url = new URL('/', window.location.href);
  url.port = link.dataset.port;
  link.href = url.href;
}
