import {
  initializeApp
} from "https://www.gstatic.com/firebasejs/12.18.0/firebase-app.js";

import {
  getMessaging,
  getToken
} from "https://www.gstatic.com/firebasejs/12.18.0/firebase-messaging.js";


const firebaseConfig = {
  apiKey: "AIzaSyCBx5KyeEJNSL_leHVaHbXTSma5Ja4mrB0",
  authDomain: "soulbeads-7fa3d.firebaseapp.com",
  projectId: "soulbeads-7fa3d",
  storageBucket: "soulbeads-7fa3d.firebasestorage.app",
  messagingSenderId: "967257992249",
  appId: "1:967257992249:web:14f4de7f0be7df5955b1e8"
};


const app =
  initializeApp(firebaseConfig);

const messaging =
  getMessaging(app);


/* Request permission and register for push */

async function setupPushNotifications() {

  try {
    alert("🔥 Firebase setup started");

    const permission =
      await Notification.requestPermission();

    if (permission !== "granted") {
      console.log("Notification permission not granted.");
      return;
    }

    const registration =
      await navigator.serviceWorker.ready;

    const token =
  await getToken(messaging, {
    vapidKey: "BAXqh3ETrRMBA6ghY_ghjiX-RK0wO--yosbGemPuJEwGfQNl8Z2qd5fpiBnEFoX-2z-BIUmU3hXAr4UTmkmMh3M",
    serviceWorkerRegistration: registration
  });

    if (token) {

  console.log(
    "SoulBeads push registration successful."
  );

  localStorage.setItem(
    "soulbeads_fcm_token",
    token
  );

  const status =
    document.getElementById("reminderStatus");

  if (status) {
    status.textContent =
      "Push notifications connected. 🔔🪷";
  }

    }

  } catch (error) {

  console.error(
    "Push notification setup failed:",
    error
  );

  const status =
    document.getElementById("reminderStatus");

  if (status) {
    status.textContent =
      "Push notification setup failed. Please try again. 🔔";
  }

}




/* Make available to SoulBeads */

window.setupPushNotifications =
  setupPushNotifications;
