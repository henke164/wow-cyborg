var logRows = [];

function log(text) {
  logRows.splice(0, 0, text);
  renderLog();
}

function renderLog() {
  var logList = document.getElementById('log');
  logList.innerHTML = '';
  
  for (var x = 0; x < logRows.length; x++) {
    logList.innerHTML += '<li>' + logRows[x] + '</li>';
  }
}