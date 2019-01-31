var mapWrapper;
var map;
var locationDebug;
var players = {};

function setCharacterLocation(idx, x, z, a) {
  if (!players[idx]) {
    var element = document.createElement('img');
    element.setAttribute('src', idx === 0 ? 'Images/arrow.png' : 'Images/circle.png')
    element.classList.add('arrow');
    document.getElementById('arrow-wrapper').appendChild(element);

    players[idx] = {
      x: 0,
      y: 0,
      a: 0,
      element
    };
  }

  players[idx].x = parseFloat(x.replace(',', '.'));
  players[idx].z = parseFloat(z.replace(',', '.'));
  players[idx].a = parseFloat(a.replace(',', '.'));

  var xPos = players[idx].x * map.width;
  var zPos = players[idx].z * map.height;
  players[idx].element.style.left = (xPos - (players[idx].element.width / 2)) + "px";
  players[idx].element.style.top = (zPos - (players[idx].element.width / 2)) + "px";

  if (players[idx].a !== 0) {
    locationDebug.innerHTML = "x: " + x + ", z: " + z + ", a:" + a;
    var degrees = -(players[idx].a * 57.2957795);
    players[idx].element.style.transform = 'rotate(' + degrees + 'deg)';
  }
}

function setMapUrl(url) {
  map.setAttribute('src', url);
}

mapWrapper = document.getElementById("map-wrapper");
map = document.getElementById("map");
locationDebug = document.getElementById("debug");

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
  }
});