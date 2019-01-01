var mapWrapper;
var map;
var debug;
var players = [];

function setCharacterLocation(x, y, a) {
  var idx = 0;
  players[idx].x = parseFloat(x.replace(',', '.'));
  players[idx].y = parseFloat(y.replace(',', '.'));
  players[idx].a = parseFloat(a.replace(',', '.'));
  debug.innerHTML = "x: " + x + ", y: " + y;

  var xPos = players[idx].x * map.width;
  var yPos = players[idx].y * map.height;
  players[idx].element.style.left = (xPos - (players[idx].element.width / 2)) + "px";
  players[idx].element.style.top = (yPos - (players[idx].element.width / 2)) + "px";

  var degrees = -(players[idx].a * 57.2957795);
  players[idx].element.style.transform = 'rotate(' + degrees + 'deg)';
}

function log(text) {

}

function setMapUrl(url) {
  map.setAttribute('src', url);
}

window.onload = function() {
  mapWrapper = document.getElementById("map-wrapper");
  map = document.getElementById("map");
  debug = document.getElementById("debug");
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

  document.addEventListener('contextmenu', event => event.preventDefault());
}