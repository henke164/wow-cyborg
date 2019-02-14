import React, { Component } from 'react';
import Map from './components/Map/index';
import './App.css';

class App extends Component {
  constructor() {
    super();

    const player = { id: 1, position: { x: 0.5, y: 0.5 }};

    this.state = {
      players: [player]
    };

    setInterval(() => {
      player.position.x += 0.01;
      player.position.y += 0.01;
      this.forceUpdate();
    }, 1000);
  }

  render() {
    return (
      <Map units={this.state.players}></Map>
    );
  }
}

export default App;
