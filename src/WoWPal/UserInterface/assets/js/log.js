var logRows = [];

function log(text) {
  logRows.splice(0, 0, text);
  if (logRows.length > 10) {
    logRows.splice(logRows.length - 1, 1);
  }
  renderLog();
}

function renderLog() {
  var logList = document.getElementById('log');
  logList.innerHTML = '';
  
  for (var x = 0; x < logRows.length; x++) {
    logList.innerHTML += '<li>' + logRows[x] + '</li>';
  }
}