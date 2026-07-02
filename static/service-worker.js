const CACHE_NAME = "ward-shabdam-v1";

const urlsToCache = [
    "/",
    "/static/css/style.css",
    "/static/css/responsive.css",
    "/static/images/logo.png"
];

self.addEventListener("install", event => {
    event.waitUntil(
        caches.open(CACHE_NAME)
        .then(cache => cache.addAll(urlsToCache))
    );
});

self.addEventListener("fetch", event => {
    event.respondWith(
        caches.match(event.request)
        .then(response => {
            return response || fetch(event.request);
        })
    );
});