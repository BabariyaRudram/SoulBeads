const CACHE_NAME = "soulbeads-v3";

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
