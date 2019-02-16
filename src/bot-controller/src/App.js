import React, { Component } from 'react';
import Map from './components/Map/index';
import BotList from './components/BotList';
import BotController from './components/BotController';
import WaypointController from './components/WaypointController';

const fetch = require('no-fetch');

class App extends Component {
  constructor() {
    super();

    this.updateBotLocations = this.updateBotLocations.bind(this);
    this.connectBot = this.connectBot.bind(this);
    this.setBotSelected = this.setBotSelected.bind(this);
    this.handleMapClick = this.handleMapClick.bind(this);
    this.setMapId = this.setMapId.bind(this);
    this.addWaypointProfile = this.addWaypointProfile.bind(this);
    this.addWayoint = this.addWayoint.bind(this);
    this.removeWaypoint = this.removeWaypoint.bind(this);
    this.runWaypoints = this.runWaypoints.bind(this);
    
    let bots, waypointProfiles;

    try {
      bots = JSON.parse(localStorage.getItem('bots')) || [];
    } catch(e) {
      bots = [];
    }

    try {
      waypointProfiles = JSON.parse(localStorage.getItem('waypoints')) || [];
    } catch(e) {
      waypointProfiles = [];
    }

    this.state = {
      mapId: null,
      bots,
      lastClickPosition: null,
      waypointProfiles,
    };

    setInterval(this.updateBotLocations, 1000);
  }

  handleMapClick(position) {
    const selectedProfile = this.state.waypointProfiles.filter(w => w.selected)[0];
    if (!selectedProfile) {
      this.setState({lastClickPosition:position});
    } else {
      this.addWayoint(selectedProfile, position);
    }
  }

  addWayoint(selectedProfile, position) {
    selectedProfile.waypoints.push(position);
    this.setState({waypointProfiles: this.state.waypointProfiles});
    localStorage.setItem('waypoints', JSON.stringify(this.state.waypointProfiles));
  }
  
  removeWaypoint(position) {
    const selectedProfile = this.state.waypointProfiles.filter(w => w.selected)[0];
    const index = selectedProfile.waypoints.indexOf(position);
    selectedProfile.waypoints.splice(index, 1);
    this.setState({waypointProfiles: this.state.waypointProfiles});
    localStorage.setItem('waypoints', JSON.stringify(this.state.waypointProfiles));
  }

  setMapId(id) {
    this.setState({
      mapId: id,
    });
  }

  updateBotLocations() {
    this.state.bots.forEach(bot => {
      fetch(`http://${bot.ip}/currentPosition`)
      .then(response => {
        return response.json();
      })
      .then(resp => {
        bot.position = {
          x: resp.x,
          y: resp.z
        };
      })
      .catch(e => {
        bot.position = {
          x: 0,
          y: 0
        };
      })
      .finally(() => {
        this.setState({
          bots: this.state.bots
        });
      });
    });
  }

  setBotSelected(id, selected) {
    const bot = this.state.bots.filter(b => b.id === id)[0];
    bot.selected = selected;
    this.setState({bots: this.state.bots});
  }

  setWaypointProfileSelected(id, selected) {
    const waypointProfile = this.state.waypointProfiles.filter(b => b.id === id)[0];
    waypointProfile.selected = selected;
    this.setState({waypointProfiles: this.state.waypointProfiles});
    console.log(waypointProfile);
  }

  connectBot(bot) {
    const bots = this.state.bots;
    bots.push(bot);
    console.log(bot.position.zone);
    this.setState({
      bots,
    });

    localStorage.setItem('bots', JSON.stringify(bots));
  }

  addWaypointProfile(waypointProfile) {
    const profiles = this.state.waypointProfiles;
    profiles.push(waypointProfile);
    this.setState({waypointProfiles: this.state.waypointProfiles});

    localStorage.setItem('waypoints', JSON.stringify(profiles));
  }

  runWaypoints() {

  }

  render() {
    const selectedWaypointProfile = this.state.waypointProfiles.filter(w => w.selected)[0];
    return (
      <div>
        <Map
          mapId={this.state.mapId}
          units={this.state.bots}
          selectedWaypointProfile={selectedWaypointProfile}
          onMapClicked={this.handleMapClick}
          onMapChanged={this.setMapId}
          onBotSelected={id => this.setBotSelected(id, true)}
          onBotUnselected={id => this.setBotSelected(id, false)}
          onWaypointRemoved={this.removeWaypoint}>
        </Map>
        <BotList
          onBotAdded={this.connectBot}
          bots={this.state.bots}
          onBotSelected={id => this.setBotSelected(id, true)}
          onBotUnselected={id => this.setBotSelected(id, false)}>
        </BotList>
        <BotController
          bots={this.state.bots}
          lastClickPosition={this.state.lastClickPosition}>
        </BotController>
        <WaypointController
          waypointProfiles={this.state.waypointProfiles}
          onWaypointProfileCreated={this.addWaypointProfile}
          onProfileSelected={id => this.setWaypointProfileSelected(id, true)}
          onProfileUnselected={id => this.setWaypointProfileSelected(id, false)}
          onWaypointRun={this.runWaypoints}>
        </WaypointController>
      </div>
    );
  }
}

export default App;
