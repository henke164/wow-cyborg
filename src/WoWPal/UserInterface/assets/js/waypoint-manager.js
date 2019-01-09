var waypointCollections = [];
var wpCollectionSelectorPopup = document.getElementById('wp-collection-popup');
var wpCollectionSelector = document.getElementById('wp-collection-selector');
var selectedWaypointCollection = document.getElementById('wp-collection-label');
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

  var wpCollection = getCurrentWaypointCollection();

  if (!wpCollection) {
    return;
  }

  for (var x = 0; x < wpCollection.Waypoints.length; x++) {
    waypointList.innerHTML += '<li>' + 
      wpCollection.Waypoints[x].X + ',' + wpCollection.Waypoints[x].Z
    '</li>';
  }
}

function setWaypointList(waypointList) {
  waypoints = JSON.parse(waypointList);
  renderWaypoints();
}

function newWaypointCollection() {
  var nameInput = document.getElementById('wp-collection-name-input');
  var name = nameInput.value;
  waypointManager.createWaypointCollection(name);
  waypointManager.setSelectedCollection(name);
  selectedWaypointCollection.innerHTML = name;
  nameInput.value = "";
}

function loadWaypointCollections(wpCollections) {
  waypointCollections = JSON.parse(wpCollections);

  wpCollectionSelector.innerHTML = "";
  for (var x = 0; x < waypointCollections.length; x++) {
    wpCollectionSelector.innerHTML +=
      "<li>" + 
      "<a onclick='selectWaypointCollection(\"" + waypointCollections[x].Name + "\")'>" +
      waypointCollections[x].Name +
      "</a>" +
      "<a class='wp-delete' onclick='deleteWaypointCollection(\"" + waypointCollections[x].Name + "\")'>" +
      "Delete" +
      "</a>" +
      "</li > ";

    try {
      if (!selectedWaypointCollection.innerHTML) {
        selectedWaypointCollection.innerHTML = waypointCollections[x].Name;
        waypointManager.setSelectedCollection(selectedWaypointCollection.innerHTML);
      }
    } catch (e) {
      alert(e);
    }
  }

  renderWaypoints();
}

function getCurrentWaypointCollection() {
  return waypointCollections.filter(w => w.Name === selectedWaypointCollection.innerHTML)[0];
}

function deleteWaypointCollection(name) {
  selectedWaypointCollection.innerHTML = '';
  waypointManager.deleteWaypointCollection(name);
}

function selectWaypointCollection(name) {
  selectedWaypointCollection.innerHTML = name;
  waypointManager.setSelectedCollection(name);
  wpCollectionSelectorPopup.style.display = 'none';
}

waypointList = document.getElementById('waypoints');
document.getElementById('add-wp-button').addEventListener('click', addWaypoint);
document.getElementById('run-wp-button').addEventListener('click', runWaypoints);
document.getElementById('new-wp-collection-button').addEventListener('click', newWaypointCollection);
selectedWaypointCollection.addEventListener('click', function () {
  wpCollectionSelectorPopup.style.display = 'block';
});
waypointManager.synchronizeWaypointCollections();