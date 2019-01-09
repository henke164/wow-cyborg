var wpWrapper = document.getElementById('waypoints-wrapper');
var logWrapper = document.getElementById('log-wrapper');

document.getElementById('waypoint-button').addEventListener('click', function() {
  wpWrapper.style.display = 'block';
  logWrapper.style.display = 'none';
  renderWaypoints();
});

document.getElementById('log-button').addEventListener('click', function() {
  wpWrapper.style.display = 'none';
  logWrapper.style.display = 'block';
  renderLog();
});

document.getElementById('devtools-button').addEventListener('click', function () {
  characterController.showDevTools();
});
