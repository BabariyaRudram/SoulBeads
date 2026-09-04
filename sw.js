const CACHE_NAME = "soulbeads-v2";

const APP_FILES = [
  "./",
  "./index.html",
  "./style.css",
  "./app.js",
  "./manifest.json"
];

self.addEventListener("install", function (event) {

  event.waitUntil(
    caches.open(CACHE_NAME)
      .then(function (cache) {
        return cache.addAll(APP_FILES);
      })
  );

  self.skipWaiting();
});


self.addEventListener("activate", function (event) {

  event.waitUntil(
    caches.keys().then(function (cacheNames) {

      return Promise.all(
        cacheNames.map(function (cacheName) {

          if (cacheName !== CACHE_NAME) {
            return caches.delete(cacheName);
          }

        })
      );

    })
  );

  self.clients.claim();
});


self.addEventListener("fetch", function (event) {

  event.respondWith(
    caches.match(event.request)
      .then(function (cachedResponse) {

        return cachedResponse ||
          fetch(event.request);

      })
  );

});
/* =========================
   PUSH NOTIFICATIONS
========================= */

self.addEventListener("push", function (event) {

  let data = {
    title: "SoulBeads 🔔",
    body: "It's time for your daily Jap. 🪷"
  };

  if (event.data) {
    try {
      data = event.data.json();
    } catch (error) {
      // Keep the default message
    }
  }

  event.waitUntil(
    self.registration.showNotification(
      data.title,
      {
        body: data.body,
        icon: "./",
badge: "./",
        tag: "soulbeads-daily-reminder",
        renotify: true
      }
    )
  );

});
