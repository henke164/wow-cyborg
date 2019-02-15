import React, { Component } from 'react';
import Map from './components/Map/index';
import BotList from './components/BotList';
const fetch = require('no-fetch');

class App extends Component {
  constructor() {
    super();

    this.updateBotLocations = this.updateBotLocations.bind(this);
    this.connectBot = this.connectBot.bind(this);
    this.setBotSelected = this.setBotSelected.bind(this);

    this.state = {
      bots: []
    };

    //setInterval(this.updateBotLocations, 1000);
  }

  updateBotLocations() {
    this.state.bots.forEach(bot => {
      fetch(`http://${bot.ip}/currentPosition`)
      .then(response => {
        return response.json();
      })
      .then(resp => {
        bot.position = resp;
        this.setState({bots: this.state.bots});
      })
      .catch(e => {
        console.log(e);
      });
    });
  }

  setBotSelected(id, selected) {
    const bot = this.state.bots.filter(b => b.id === id)[0];
    bot.selected = selected;
    this.setState({bots: this.state.bots});
  }

  connectBot(bot) {
    const bots = this.state.bots;
    bots.push(bot);
    this.setState({bots});
  }

  render() {
    return (
      <div>
        <Map units={this.state.bots}></Map>
        <BotList
          onBotAdded={this.connectBot}
          bots={this.state.bots}
          onBotSelected={id => this.setBotSelected(id, true)}
          onBotUnselected={id => this.setBotSelected(id, false)}>
        </BotList>
      </div>
    );
  }
}

export default App;
