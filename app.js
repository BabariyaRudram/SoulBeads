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
applySavedTheme();
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
  const countElement =
  document.getElementById("count");

if (countElement) {
  countElement.classList.remove("count-pop");

  void countElement.offsetWidth;

  countElement.classList.add("count-pop");
}

  if ("vibrate" in navigator) {
    navigator.vibrate(15);
  }

  /* Check target completion */

  if (count >= target) {

    const message =
      document.getElementById("completeMessage");

    if (message) {
      message.textContent =
        "Your " + currentChant +
        " Jap target is complete. 🙏";
    }

    const modal =
      document.getElementById("completeModal");

    if (modal) {
      modal.style.display = "flex";
    }
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
  updateMalaProgress();
}
function updateMalaProgress() {

  const beads =
    document.getElementById("malaBeads");

  const text =
    document.getElementById("malaText");

  if (!beads) {
    return;
  }

  const malaSize = 108;

  const completed =
    Math.min(
      Math.floor((count / target) * malaSize),
      malaSize
    );

  beads.innerHTML = "";

  for (let i = 0; i < malaSize; i++) {

    const bead =
      document.createElement("span");

    bead.className = "mala-bead";

    if (i < completed) {
      bead.classList.add("bead-filled");
    }

    beads.appendChild(bead);
  }

  if (text) {
    text.textContent =
      Math.min(count, target).toLocaleString("en-IN") +
      " / " +
      target.toLocaleString("en-IN") +
      " Jap";
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
   JAP COMPLETE
========================= */

function closeCompleteModal() {

  const modal =
    document.getElementById("completeModal");

  if (modal) {
    modal.style.display = "none";
  }
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
applySavedTheme();
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
/* =========================
   THEME SETTINGS
========================= */

function setTheme(theme) {

  if (
    theme !== "light" &&
    theme !== "dark" &&
    theme !== "system"
  ) {
    theme = "system";
  }

  applyTheme(theme);

  localStorage.setItem(
    "soulbeads_theme",
    theme
  );

  updateThemeButtons(theme);
}


/* Apply theme without changing saved preference */

function applyTheme(theme) {

  if (theme === "dark") {

    document.body.classList.add("dark-mode");

  } else if (theme === "light") {

    document.body.classList.remove("dark-mode");

  } else {

    const prefersDark =
      window.matchMedia &&
      window.matchMedia(
        "(prefers-color-scheme: dark)"
      ).matches;

    document.body.classList.toggle(
      "dark-mode",
      prefersDark
    );
  }
}


/* Update selected button */

function updateThemeButtons(theme) {

  const buttons =
    document.querySelectorAll(".theme-option");

  buttons.forEach(function(button) {

    button.classList.remove(
      "theme-selected"
    );

    const buttonTheme =
      button.getAttribute("data-theme");

    if (buttonTheme === theme) {

      button.classList.add(
        "theme-selected"
      );
    }
  });
}


/* Load saved theme */

function loadTheme() {

  const savedTheme =
    localStorage.getItem(
      "soulbeads_theme"
    ) || "system";

  applyTheme(savedTheme);

  updateThemeButtons(savedTheme);
}


/* Reapply saved theme when opening screens */

function applySavedTheme() {

  const savedTheme =
    localStorage.getItem(
      "soulbeads_theme"
    ) || "system";

  applyTheme(savedTheme);

  updateThemeButtons(savedTheme);
}


/* Load theme when app starts */

document.addEventListener(
  "DOMContentLoaded",
  loadTheme
);
document.addEventListener("DOMContentLoaded", function () {

  const button =
    document.getElementById("completeContinueButton");

  if (button) {

    button.addEventListener("click", function () {

      const modal =
        document.getElementById("completeModal");

      if (modal) {
        modal.style.display = "none";
      }

    });
  }

});
/* =========================
   JAP HISTORY
========================= */

function openHistory() {

  applySavedTheme();

  const home =
    document.querySelector(".app");

  const historyScreen =
    document.getElementById("historyScreen");

  if (!home || !historyScreen) {
    return;
  }

  home.style.display = "none";
  historyScreen.style.display = "block";

  updateHistory();

  window.scrollTo({
    top: 0,
    behavior: "smooth"
  });
}


function closeHistory() {

  const home =
    document.querySelector(".app");

  const historyScreen =
    document.getElementById("historyScreen");

  if (!home || !historyScreen) {
    return;
  }

  historyScreen.style.display = "none";
  home.style.display = "block";

  window.scrollTo({
    top: 0,
    behavior: "smooth"
  });
}

function updateHistory() {

  const list =
    document.getElementById("historyList");

  if (!list) {
    return;
  }

  list.innerHTML = "";

  const history = [];

  const today = new Date();

  for (let i = 0; i < 30; i++) {

    const date = new Date(today);

    date.setDate(
      today.getDate() - i
    );

    const year =
      date.getFullYear();

    const month =
      String(
        date.getMonth() + 1
      ).padStart(2, "0");

    const day =
      String(
        date.getDate()
      ).padStart(2, "0");

    const dateKey =
      year + "-" + month + "-" + day;

    const saved =
      localStorage.getItem(
        "soulbeads_daily_" + dateKey
      );

    if (!saved) {
      continue;
    }

    try {

      const data =
        JSON.parse(saved);

      if (
        typeof data !== "object" ||
        data === null ||
        Array.isArray(data)
      ) {
        continue;
      }

      let total = 0;
      const chants = [];

      Object.entries(data).forEach(
        function(entry) {

          const chant =
            entry[0];

          const value =
            Number(entry[1]);

          if (
            Number.isFinite(value) &&
            value > 0
          ) {

            total += value;

            chants.push({
              name: chant,
              count: value
            });
          }
        }
      );

      if (total > 0) {

        history.push({
          date: dateKey,
          total: total,
          chants: chants
        });
      }

    } catch (error) {
      continue;
    }
  }


  if (history.length === 0) {

    list.innerHTML =
      "<p class='history-empty'>" +
      "No Jap history yet. 🪷" +
      "</p>";

    return;
  }


  history.forEach(
    function(item) {

      const card =
        document.createElement("div");

      card.className =
        "history-item";

      const dateObject =
        new Date(item.date + "T00:00:00");

      const formattedDate =
        dateObject.toLocaleDateString(
          "en-IN",
          {
            day: "numeric",
            month: "long",
            year: "numeric"
          }
        );

      let chantHTML = "";

      item.chants.forEach(
        function(chant) {

          chantHTML +=
            "<div class='history-chant'>" +
            "<span>" +
            chant.name +
            "</span>" +
            "<strong>" +
            chant.count.toLocaleString("en-IN") +
            " Jap" +
            "</strong>" +
            "</div>";
        }
      );

      card.innerHTML =
        "<div class='history-date'>" +
        "🗓️" +
        formattedDate +
        "</div>" +

        "<div class='history-total'>" +
        "🪷 " +
        item.total.toLocaleString("en-IN") +
        " Total Jap" +
        "</div>" +

        "<div class='history-chants'>" +
        chantHTML +
        "</div>";

      list.appendChild(card);
    }
  );
}
/* =========================
   JAP STATISTICS
========================= */

function openStatistics() {

  applySavedTheme();

  const home =
    document.querySelector(".app");

  const statisticsScreen =
    document.getElementById(
      "statisticsScreen"
    );

  if (!home || !statisticsScreen) {
    return;
  }

  home.style.display = "none";
  statisticsScreen.style.display = "block";

  updateStatistics();

  window.scrollTo({
    top: 0,
    behavior: "smooth"
  });
}


function closeStatistics() {

  const home =
    document.querySelector(".app");

  const statisticsScreen =
    document.getElementById(
      "statisticsScreen"
    );

  if (!home || !statisticsScreen) {
    return;
  }

  statisticsScreen.style.display = "none";
  home.style.display = "block";

  window.scrollTo({
    top: 0,
    behavior: "smooth"
  });
}


function updateStatistics() {

  let totalJap = 0;
  let totalDays = 0;
  let bestDay = 0;

  const today = new Date();

  for (let i = 0; i < 3650; i++) {

    const date = new Date(today);

    date.setDate(
      today.getDate() - i
    );

    const year =
      date.getFullYear();

    const month =
      String(
        date.getMonth() + 1
      ).padStart(2, "0");

    const day =
      String(
        date.getDate()
      ).padStart(2, "0");

    const dateKey =
      year + "-" + month + "-" + day;

    const saved =
      localStorage.getItem(
        "soulbeads_daily_" + dateKey
      );

    if (!saved) {
      continue;
    }

    try {

      const data =
        JSON.parse(saved);

      if (
        typeof data !== "object" ||
        data === null ||
        Array.isArray(data)
      ) {
        continue;
      }

      let dayTotal = 0;

      Object.values(data).forEach(
        function(value) {

          const number =
            Number(value);

          if (
            Number.isFinite(number) &&
            number > 0
          ) {
            dayTotal += number;
          }
        }
      );

      if (dayTotal > 0) {

        totalJap += dayTotal;
        totalDays++;

        if (dayTotal > bestDay) {
          bestDay = dayTotal;
        }
      }

    } catch (error) {
      continue;
    }
  }

  const totalJapElement =
    document.getElementById(
      "totalJapStat"
    );

  const totalDaysElement =
    document.getElementById(
      "totalDaysStat"
    );

  const bestDayElement =
    document.getElementById(
      "bestDayStat"
    );

  const totalMalaElement =
    document.getElementById(
      "totalMalaStat"
    );


  if (totalJapElement) {

    totalJapElement.textContent =
      totalJap.toLocaleString("en-IN");
  }


  if (totalDaysElement) {

    totalDaysElement.textContent =
      totalDays.toLocaleString("en-IN");
  }


  if (bestDayElement) {

    bestDayElement.textContent =
      bestDay.toLocaleString("en-IN");
  }


  if (totalMalaElement) {

    totalMalaElement.textContent =
      Math.floor(
        totalJap / 108
      ).toLocaleString("en-IN");
  }
}
/* =========================
   JAP STREAK
========================= */

function openStreak() {

  applySavedTheme();

  const home =
    document.querySelector(".app");

  const streakScreen =
    document.getElementById("streakScreen");

  if (!home || !streakScreen) {
    return;
  }

  home.style.display = "none";
  streakScreen.style.display = "block";

  updateStreak();

  window.scrollTo({
    top: 0,
    behavior: "smooth"
  });
}


function closeStreak() {

  const home =
    document.querySelector(".app");

  const streakScreen =
    document.getElementById("streakScreen");

  if (!home || !streakScreen) {
    return;
  }

  streakScreen.style.display = "none";
  home.style.display = "block";

  window.scrollTo({
    top: 0,
    behavior: "smooth"
  });
}


function getJapForDate(dateKey) {

  const saved =
    localStorage.getItem(
      "soulbeads_daily_" + dateKey
    );

  if (!saved) {
    return 0;
  }

  try {

    const data =
      JSON.parse(saved);

    if (
      typeof data !== "object" ||
      data === null ||
      Array.isArray(data)
    ) {
      return 0;
    }

    let total = 0;

    Object.values(data).forEach(
      function(value) {

        const number =
          Number(value);

        if (
          Number.isFinite(number) &&
          number > 0
        ) {
          total += number;
        }
      }
    );

    return total;

  } catch (error) {

    return 0;
  }
}


function getDateKey(date) {

  const year =
    date.getFullYear();

  const month =
    String(
      date.getMonth() + 1
    ).padStart(2, "0");

  const day =
    String(
      date.getDate()
    ).padStart(2, "0");

  return (
    year +
    "-" +
    month +
    "-" +
    day
  );
}


function updateStreak() {

  const today =
    new Date();

  let currentStreak = 0;
  let longestStreak = 0;
  let runningStreak = 0;

  /*
    Calculate current streak.
    Today counts only if Jap
    has been completed today.
  */

  const todayKey =
    getDateKey(today);

  if (getJapForDate(todayKey) > 0) {

    currentStreak = 1;

    const checkDate =
      new Date(today);

    checkDate.setDate(
      checkDate.getDate() - 1
    );

    while (
      getJapForDate(
        getDateKey(checkDate)
      ) > 0
    ) {

      currentStreak++;

      checkDate.setDate(
        checkDate.getDate() - 1
      );
    }
  }


  /*
    Find longest streak
    across the last 3650 days.
  */

  for (let i = 3649; i >= 0; i--) {

    const checkDate =
      new Date(today);

    checkDate.setDate(
      today.getDate() - i
    );

    const dateKey =
      getDateKey(checkDate);

    if (
      getJapForDate(dateKey) > 0
    ) {

      runningStreak++;

      if (
        runningStreak >
        longestStreak
      ) {

        longestStreak =
          runningStreak;
      }

    } else {

      runningStreak = 0;
    }
  }


  const currentElement =
    document.getElementById(
      "currentStreak"
    );

  const longestElement =
    document.getElementById(
      "longestStreak"
    );


  if (currentElement) {

    currentElement.textContent =
      currentStreak.toLocaleString(
        "en-IN"
      );
  }


  if (longestElement) {

    longestElement.textContent =
      longestStreak.toLocaleString(
        "en-IN"
      );
  }
}
/* =========================
   SERVICE WORKER
========================= */

if ("serviceWorker" in navigator) {

  window.addEventListener(
    "load",
    function () {

      navigator.serviceWorker
        .register("./sw.js")
        .then(function () {

          console.log(
            "SoulBeads service worker registered."
          );

        })
        .catch(function (error) {

          console.error(
            "Service worker registration failed:",
            error
          );

        });

    }
  );

}
