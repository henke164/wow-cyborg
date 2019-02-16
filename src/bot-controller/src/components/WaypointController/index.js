import React, { Component } from 'react';
import Draggable from 'react-draggable';
import './index.css';

class WaypointController extends Component {
  constructor() {
    super();

    this.renderAddWaypointProfileFrame = this.renderAddWaypointProfileFrame.bind(this);
    this.toggleAddWaypointProfileFrame = this.toggleAddWaypointProfileFrame.bind(this);
    this.addProfile = this.addProfile.bind(this);

    this.addWpName = React.createRef();

    this.state = {
      displayAddWaypointProfileFrame: false,
    };
  }

  addProfile () {
    this.props.onWaypointProfileCreated({
      id: Math.floor(Math.random() * 10000),
      name: this.addWpName.current.value,
      waypoints: []
    });

    this.setState({displayAddWaypointProfileFrame: false});
  }

  toggleAddWaypointProfileFrame() {
    this.setState({displayAddWaypointProfileFrame: !this.state.displayAddWaypointProfileFrame});
  }

  renderAddWaypointProfileFrame() {
    if (this.state.displayAddWaypointProfileFrame) {
      return (
        <div className="AddWaypointProfile">
          <div className="WaypointControllerHeader">
            <span>Add Waypoint profile</span>
          </div>
          <div className="WaypointControllerContent">
            <span>Name:</span>
            <input ref={this.addWpName} type="text"></input>
            <button onClick={this.addProfile}>Add</button>
          </div>
          <div className="WaypointControllerFooter">
            <a href="#" onClick={this.toggleAddWaypointProfileFrame}>Close</a>
          </div>
        </div>
      );
    }
    return null;
  }

  renderWaypointProfiles() {
    return this.props.waypointProfiles.map(profile => {
      return profile.selected ? (
        <a key={profile.id} href="#"
          className={"selected"}
          onClick={() => this.props.onProfileUnselected(profile.id)}
        >{profile.name}</a>
      ) : (
        <a key={profile.id} href="#"
          onClick={() => this.props.onProfileSelected(profile.id)}
        >{profile.name}</a>
      )
    });
  }

  render() {
    return (
      <Draggable handle=".WaypointControllerHeader">
        <div className="WaypointController">
          <div className="WaypointControllerHeader">
            <span>Waypoints</span>
          </div>
          <div className="WaypointControllerContent">
            {this.renderWaypointProfiles()}
          </div>
          <div className="WaypointControllerFooter">
            <a href="#" onClick={this.onWaypointRun}>Play</a>
            <a href="#" onClick={this.toggleAddWaypointProfileFrame}>+</a>
          </div>
          {this.renderAddWaypointProfileFrame()}
        </div>
      </Draggable>
    );
  }
}

export default WaypointController;
