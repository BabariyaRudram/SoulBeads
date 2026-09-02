"use strict";

/*
  SoulBeads
  Basic Jap Counter

  Data is stored locally in the browser.
  No account, tracking, or external server is required.
*/

const TARGET = 1008;

let currentChant = "Radhe Radhe";
let count = 0;


/* =========================
   STORAGE
========================= */

function getStorageKey() {
  return "soulbeads_count_" + currentChant;
}


function loadCount() {
  const saved = localStorage.getItem(getStorageKey());

  count = saved ? Number(saved) : 0;

  if (!Number.isFinite(count) || count < 0) {
    count = 0;
  }

  count = Math.floor(count);

  updateCounter();
}


function saveCount() {
  localStorage.setItem(
    getStorageKey(),
    String(count)
  );
}


/* =========================
   OPEN JAP SCREEN
========================= */

function openJap(name, icon = "📿") {

  currentChant = String(name);

  const home = document.querySelector(".app");
  const japScreen = document.getElementById("japScreen");

  if (!home || !japScreen) {
    return;
  }

  home.style.display = "none";
  japScreen.style.display = "block";

  const naamElement = document.getElementById("japNaam");
  const imageElement = document.getElementById("japImage");

  if (naamElement) {
    naamElement.textContent = currentChant;
  }

  if (imageElement) {
    imageElement.textContent = icon;
  }

  loadCount();

  window.scrollTo({
    top: 0,
    behavior: "smooth"
  });
}


/* =========================
   GO HOME
========================= */

function goHome() {

  const home = document.querySelector(".app");
  const japScreen = document.getElementById("japScreen");

  if (!home || !japScreen) {
    return;
  }

  japScreen.style.display = "none";
  home.style.display = "block";

  window.scrollTo({
    top: 0,
    behavior: "smooth"
  });
}


/* =========================
   ADD ONE JAP
========================= */

function doJap() {

  /*
    Keep the counter within a safe browser number range.
  */

  if (count >= Number.MAX_SAFE_INTEGER) {
    return;
  }

  count += 1;

  saveCount();
  updateCounter();

  /*
    Small vibration on supported phones.
    It is optional and does nothing if unavailable.
  */

  if ("vibrate" in navigator) {
    navigator.vibrate(15);
  }
}


/* =========================
   UPDATE DISPLAY
========================= */

function updateCounter() {

  const countElement = document.getElementById("count");
  const progressBar = document.getElementById("progressBar");
  const progressText = document.getElementById("progressText");

  if (!countElement) {
    return;
  }

  countElement.textContent =
    count.toLocaleString("en-IN");


  const percentage =
    Math.min((count / TARGET) * 100, 100);


  if (progressBar) {
    progressBar.style.width =
      percentage + "%";
  }


  if (progressText) {

    if (count >= TARGET) {

      progressText.textContent =
        "Target completed 🪷🙏🏻";

    } else {

      progressText.textContent =
        Math.floor(percentage) +
        "% complete";

    }
  }
}


/* =========================
   RESET
========================= */

function resetJap() {

  const modal = document.getElementById("resetModal");

  if (modal) {
    modal.style.display = "flex";
  }
}


function closeResetModal() {

  const modal = document.getElementById("resetModal");

  if (modal) {
    modal.style.display = "none";
  }
}


function confirmReset() {

  count = 0;

  saveCount();
  updateCounter();

  closeResetModal();
}


/* =========================
   STARTUP
========================= */

document.addEventListener(
  "DOMContentLoaded",
  function () {

    /*
      We don't open the Jap screen automatically.
      The user chooses a Naam from Home.
    */

    const saved = localStorage.getItem(
      "soulbeads_count_" + currentChant
    );

    count = saved ? Number(saved) : 0;

    if (!Number.isFinite(count) || count < 0) {
      count = 0;
    }

    count = Math.floor(count);

    updateCounter();
  }
);
