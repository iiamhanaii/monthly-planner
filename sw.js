const CACHE_NAME = 'monthly-planner-v2';
const SHELL_ASSETS = [
  '/',
  '/index.html',
  '/manifest.json',
  '/icons/icon-192.png',
  '/icons/icon-512.png'
];

self.addEventListener('install', (e) => {
  e.waitUntil(
    caches.open(CACHE_NAME).then((cache) => cache.addAll(SHELL_ASSETS)).catch(() => {})
  );
  self.skipWaiting();
});

self.addEventListener('activate', (e) => {
  e.waitUntil(
    caches.keys().then((keys) =>
      Promise.all(keys.filter((k) => k !== CACHE_NAME).map((k) => caches.delete(k)))
    )
  );
  self.clients.claim();
});

self.addEventListener('fetch', (e) => {
  const url = new URL(e.request.url);
  // Never intercept cross-origin requests (Supabase API, fonts, CDN scripts) —
  // those must always hit the network so data stays live and in sync.
  if (url.origin !== self.location.origin) return;
  // Only cache GET requests for the static app shell.
  if (e.request.method !== 'GET') return;

  // For the page itself (navigations), always try the network first so a
  // new deploy shows up immediately. Only fall back to the cached copy if
  // the phone is offline. This is what makes "reopen the app" pick up updates.
  if (e.request.mode === 'navigate') {
    e.respondWith(
      fetch(e.request)
        .then((res) => {
          const copy = res.clone();
          caches.open(CACHE_NAME).then((cache) => cache.put(e.request, copy));
          return res;
        })
        .catch(() => caches.match(e.request))
    );
    return;
  }

  // Other static assets (icons, manifest) can stay cache-first.
  e.respondWith(
    caches.match(e.request).then((cached) => cached || fetch(e.request))
  );
});

// ---------- push notifications ----------
self.addEventListener('push', (e) => {
  let payload = { title: '待辦提醒', body: '你有待辦事項需要處理' };
  try{ if(e.data) payload = e.data.json(); }catch(err){}
  const options = {
    body: payload.body || '',
    icon: '/icons/icon-192.png',
    badge: '/icons/icon-192.png',
    data: { url: payload.url || '/' }
  };
  e.waitUntil(self.registration.showNotification(payload.title || '待辦提醒', options));
});

self.addEventListener('notificationclick', (e) => {
  e.notification.close();
  const targetUrl = (e.notification.data && e.notification.data.url) || '/';
  e.waitUntil(
    clients.matchAll({ type: 'window', includeUncontrolled: true }).then((windowClients) => {
      for (const client of windowClients) {
        if (client.url.includes(self.location.origin) && 'focus' in client) return client.focus();
      }
      if (clients.openWindow) return clients.openWindow(targetUrl);
    })
  );
});
