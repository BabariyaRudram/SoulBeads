const TARGET = 1008;

let currentChant = "Radhe Radhe";
let count = Number(localStorage.getItem("soulbeads_count")) || 0;


// Open Jap screen
function openJap(name, icon = "📿") {
  currentChant = name;

  document.querySelector(".app").style.display = "none";
  document.getElementById("japScreen").style.display = "block";

  document.getElementById("japNaam").textContent = name;
  document.getElementById("japImage").textContent = icon;

  loadCount();
}


// Go back to Home
function goHome() {
  document.getElementById("japScreen").style.display = "none";
  document.querySelector(".app").style.display = "block";
}


// Add one Jap
function doJap() {
  count++;

  localStorage.setItem("soulbeads_count", count);

  updateCounter();
}


// Load saved count
function loadCount() {
  count = Number(localStorage.getItem("soulbeads_count")) || 0;
  updateCounter();
}


// Update counter and progress
function updateCounter() {

  document.getElementById("count").textContent = count;

  const percentage = Math.min((count / TARGET) * 100, 100);

  document.getElementById("progressBar").style.width =
    percentage + "%";

  document.getElementById("progressText").textContent =
    Math.floor(percentage) + "% complete";
}


// Reset count
function resetJap() {

  const confirmReset = confirm(
    "Are you sure you want to reset your Jap count?"
  );

  if (!confirmReset) return;

  count = 0;

  localStorage.setItem("soulbeads_count", 0);

  updateCounter();
}


// Start with saved progress
updateCounter();
