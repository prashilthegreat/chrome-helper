const CACHE = "m365-hub-v24";
const SHELL = [
  "./index.html",
  "./manifest.json",
  "./icons/icon-192.png",
  "./icons/icon-512.png",
  "./icons/logos/admin365.svg",
  "./icons/logos/entra.svg",
  "./icons/logos/teams.svg",
  "./icons/logos/outlook.svg",
  "./icons/logos/company.svg",
  "./icons/logos/connectwise.svg",
  "./icons/logos/connectwise-manage.png",
  "./icons/logos/connectwise-calendar.svg",
  "./icons/logos/exchange.svg",
  "./icons/logos/intune.svg",
  "./icons/logos/hudu.ico",
  "./icons/logos/n-able.svg",
  "./icons/logos/acronis.svg",
  "./icons/logos/miwatj.png",
  "./icons/logos/mail-release.svg"
];

self.addEventListener("install", (e) => {
  e.waitUntil(caches.open(CACHE).then((c) => c.addAll(SHELL)));
  self.skipWaiting();
});

self.addEventListener("activate", (e) => {
  e.waitUntil(
    caches.keys().then((keys) =>
      Promise.all(keys.filter((k) => k !== CACHE).map((k) => caches.delete(k)))
    )
  );
  self.clients.claim();
});

self.addEventListener("fetch", (e) => {
  if (e.request.method !== "GET") return;
  e.respondWith(
    caches.match(e.request).then((cached) => {
      const network = fetch(e.request)
        .then((res) => {
          if (res.ok && e.request.url.startsWith(self.location.origin)) {
            const clone = res.clone();
            caches.open(CACHE).then((c) => c.put(e.request, clone));
          }
          return res;
        })
        .catch(() => cached);
      return cached || network;
    })
  );
});
