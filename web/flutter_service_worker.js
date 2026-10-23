self.addEventListener('install', function(e) {
  self.skipWaiting();
});

self.addEventListener('activate', function(e) {
  self.registration.unregister().then(function() {
    if (caches) {
      caches.keys().then(function(names) {
        for (var i = 0; i < names.length; i++) caches.delete(names[i]);
      });
    }
  });
});
