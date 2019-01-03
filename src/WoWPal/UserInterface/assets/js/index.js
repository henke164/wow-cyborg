var mapWrapper;
var map;
var locationDebug;
var players = [];

function setCharacterLocation(x, z, a) {
  var idx = 0;
  players[idx].x = parseFloat(x.replace(',', '.'));
  players[idx].z = parseFloat(z.replace(',', '.'));
  players[idx].a = parseFloat(a.replace(',', '.'));
  locationDebug.innerHTML = "x: " + x + ", z: " + z;

  var xPos = players[idx].x * map.width;
  var zPos = players[idx].z * map.height;
  players[idx].element.style.left = (xPos - (players[idx].element.width / 2)) + "px";
  players[idx].element.style.top = (zPos - (players[idx].element.width / 2)) + "px";

  var degrees = -(players[idx].a * 57.2957795);
  players[idx].element.style.transform = 'rotate(' + degrees + 'deg)';
}

function setMapUrl(url) {
  map.setAttribute('src', url);
}

mapWrapper = document.getElementById("map-wrapper");
map = document.getElementById("map");
locationDebug = document.getElementById("debug");
players.push({
  x: 0,
  y: 0,
  a: 0,
  element: document.getElementById('player1_arrow')
});

map.addEventListener("mousedown", function (e) {
  e.preventDefault();
});

mapWrapper.addEventListener("mousedown", function (e) {
  var x = e.offsetX / map.width;
  var y = e.offsetY / map.height;

  if (e.button === 0) {
    try {
      characterController.onFaceCommand(x.toString(), y.toString());
    } catch (e) {
      console.log(e);
    }
  } else {
    try {
      characterController.onMovementCommand(x.toString(), y.toString());
    } catch (e) {
      console.log(e);
    }

    console.log(x, y);
  }
});