var waypoints = [];

var waypointList;

function addWaypoint() {
  try {
    waypointManager.addWaypoint(
      players[0].x.toString(), 
      players[0].z.toString()
    );
  } catch (e) {
    alert(e);
  }

  updateWaypointList();
}

function runWaypoints() {
  try {
    characterController.goToNextWaypoint();
  } catch (e) {
    alert(e);
  }
}

function renderWaypoints() {
  waypointList.innerHTML = '';
  
  for (var x = 0; x < waypoints.length; x++) {
    waypointList.innerHTML += '<li>' + 
      waypoints[x].x + ',' + waypoints[x].z
    '</li>';
  }
}

function setWaypointList(waypointList) {
  waypoints = JSON.parse(waypointList);
  renderWaypoints();
}

waypointList = document.getElementById('waypoints');
document.getElementById('add-wp-button').addEventListener('click', addWaypoint);
document.getElementById('run-wp-button').addEventListener('click', runWaypoints);
renderWaypoints();