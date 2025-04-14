importScripts('https://www.gstatic.com/firebasejs/9.6.1/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/9.6.1/firebase-messaging-compat.js');

firebase.initializeApp({
  apiKey: "AIzaSyANOEtMqeUubdKjrGEDCii7xRPoTgo0V08",
  authDomain: "exterior-cleaning-marketplace.firebaseapp.com",
  projectId: "exterior-cleaning-marketplace",
  storageBucket: "exterior-cleaning-marketplace.firebasestorage.app",
  messagingSenderId: "1020940923995",
  appId: "1:1020940923995:web:6174982f610cbfe12a3b7e",
  measurementId: "G-23GKHHBLS5"
});

const messaging = firebase.messaging();

// Handle background messages
messaging.onBackgroundMessage((payload) => {
  console.log('Received background message:', payload);

  const notificationTitle = payload.notification.title;
  const notificationOptions = {
    body: payload.notification.body,
    icon: '/icons/icon-192x192.png',
    badge: '/icons/icon-72x72.png',
    data: payload.data,
  };

  return self.registration.showNotification(notificationTitle, notificationOptions);
}); 