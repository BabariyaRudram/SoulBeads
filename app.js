"use strict";

/*
  SoulBeads
  Basic Jap Counter

  Data is stored locally in the browser.
  No account, tracking, or external server is required.
*/

let currentChant = "Radhe Radhe";
let count = 0;
let target = 1008;


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
   JAP TARGET
========================= */

function getTargetKey() {
  return "soulbeads_target_" + currentChant;
}


function loadTarget() {

  const saved = localStorage.getItem(getTargetKey());

  target = saved ? Number(saved) : 1008;

  if (!Number.isFinite(target) || target < 1) {
    target = 1008;
  }

  target = Math.floor(target);

  updateTargetDisplay();
}


function saveTarget() {

  localStorage.setItem(
    getTargetKey(),
    String(target)
  );
}


function setTarget(newTarget) {

  newTarget = Number(newTarget);

  if (!Number.isFinite(newTarget) || newTarget < 1) {
    return;
  }

  target = Math.floor(newTarget);

  saveTarget();
  updateTargetDisplay();
  updateCounter();
}


function showCustomTarget() {

  const area = document.getElementById("customTargetArea");
  const input = document.getElementById("customTargetInput");

  if (area) {
    area.style.display = "flex";
  }

  if (input) {
    input.focus();
  }
}


function applyCustomTarget() {

  const input =
    document.getElementById("customTargetInput");

  if (!input) {
    return;
  }

  const value = Number(input.value);

  if (!Number.isFinite(value) || value < 1) {
    input.value = "";
    return;
  }

  target = Math.floor(value);

  saveTarget();
  updateTargetDisplay();
  updateCounter();

  input.value = "";

  const area =
    document.getElementById("customTargetArea");

  if (area) {
    area.style.display = "none";
  }
}


function updateTargetDisplay() {

  const targetElement =
    document.getElementById("targetDisplay");

  if (targetElement) {
    targetElement.textContent =
      target.toLocaleString("en-IN");
  }
}
/* =========================
   DAILY PROGRESS
========================= */

function getTodayKey() {

  const today = new Date();

  const year = today.getFullYear();
  const month = String(today.getMonth() + 1).padStart(2, "0");
  const day = String(today.getDate()).padStart(2, "0");

  return year + "-" + month + "-" + day;
}


function getDailyStorageKey() {

  return "soulbeads_daily_" + getTodayKey();
}


function loadDailyProgress() {

  const saved =
    localStorage.getItem(getDailyStorageKey());

  if (!saved) {
    return {};
  }

  try {

    const data = JSON.parse(saved);

    if (
      typeof data !== "object" ||
      data === null ||
      Array.isArray(data)
    ) {
      return {};
    }

    return data;

  } catch (error) {

    return {};
  }
}


function saveDailyProgress() {

  const dailyProgress =
    loadDailyProgress();

  if (!Number.isFinite(dailyProgress[currentChant])) {
    dailyProgress[currentChant] = 0;
  }

  dailyProgress[currentChant] += 1;

  localStorage.setItem(
    getDailyStorageKey(),
    JSON.stringify(dailyProgress)
  );
}

/* =========================
   OPEN JAP SCREEN
========================= */

function openJap(name, icon = "📿") {

  currentChant = String(name);
  loadTarget();

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

  if (count >= Number.MAX_SAFE_INTEGER) {
    return;
  }

  count += 1;

  saveCount();
  saveDailyProgress();
  updateCounter();

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
  Math.min((count / target) * 100, 100);


  if (progressBar) {
    progressBar.style.width =
      percentage + "%";
  }


  if (progressText) {

    if (count >= target) {

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
/* =========================
   DAILY PROGRESS SCREEN
========================= */

function openDailyProgress() {

  const home = document.querySelector(".app");
  const dailyScreen = document.getElementById("dailyScreen");

  if (!home || !dailyScreen) {
    return;
  }

  home.style.display = "none";
  dailyScreen.style.display = "block";

  updateDailyProgress();

  window.scrollTo({
    top: 0,
    behavior: "smooth"
  });
}


function closeDailyProgress() {

  const home = document.querySelector(".app");
  const dailyScreen = document.getElementById("dailyScreen");

  if (!home || !dailyScreen) {
    return;
  }

  dailyScreen.style.display = "none";
  home.style.display = "block";

  window.scrollTo({
    top: 0,
    behavior: "smooth"
  });
}


function updateDailyProgress() {

  const dailyData = loadDailyProgress();

  const totalElement =
    document.getElementById("dailyTotal");

  const listElement =
    document.getElementById("dailyList");

  const dateElement =
    document.getElementById("dailyDate");

  if (!totalElement || !listElement) {
    return;
  }

  let total = 0;

  listElement.innerHTML = "";

  Object.keys(dailyData).forEach(function (naam) {

    const value = Number(dailyData[naam]);

    if (!Number.isFinite(value) || value <= 0) {
      return;
    }

    total += value;

    const card = document.createElement("div");

    card.className = "daily-item";

    card.innerHTML =
      "<span>" +
      naam +
      "</span>" +
      "<strong>" +
      value.toLocaleString("en-IN") +
      "</strong>";

    listElement.appendChild(card);
  });

  totalElement.textContent =
    total.toLocaleString("en-IN");

  if (dateElement) {

    const today = new Date();

    dateElement.textContent =
      today.toLocaleDateString(
        "en-IN",
        {
          weekday: "long",
          day: "numeric",
          month: "long",
          year: "numeric"
        }
      );
  }

  if (Object.keys(dailyData).length === 0) {

    listElement.innerHTML =
      '<p class="empty-daily">No Jap recorded today yet 🪷</p>';
  }
}
