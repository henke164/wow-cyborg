function runParty() {
  try {
    characterController.followLeader();
  } catch (e) {
    console.log(e);
  }
}

document.getElementById('run-party-button').addEventListener('click', runParty);
