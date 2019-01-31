var wpWrapper = document.getElementById('waypoints-wrapper');
var partyWrapper = document.getElementById('party-wrapper');
var logWrapper = document.getElementById('log-wrapper');

document.getElementById('party-button').addEventListener('click', function () {
  wpWrapper.style.display = 'none';
  logWrapper.style.display = 'none';
  partyWrapper.style.display = 'block';
});

document.getElementById('waypoint-button').addEventListener('click', function() {
  wpWrapper.style.display = 'block';
  logWrapper.style.display = 'none';
  partyWrapper.style.display = 'none';
  renderWaypoints();
});

document.getElementById('log-button').addEventListener('click', function() {
  wpWrapper.style.display = 'none';
  logWrapper.style.display = 'block';
  partyWrapper.style.display = 'none';
  renderLog();
});

document.getElementById('devtools-button').addEventListener('click', function () {
  characterController.showDevTools();
});
