import React, { Component } from 'react';
import Draggable from 'react-draggable';
import './index.css';
const fetch = require('no-fetch');

class BotController extends Component {
  constructor() {
    super();

    this.state = {
      lastClickPosition: null,
      command: 'move',
    };
  }

  commandMovement(bot, position) {
    fetch(`http://${bot.ip}/moveTo?x=${position.x}&z=${position.y}`);
  }
  
  commandFacing(bot, position) {
    fetch(`http://${bot.ip}/face?x=${position.x}&z=${position.y}`);
  }

  handleMapClick(position) {
    const markedBots = this.props.bots.filter(b => b.selected === true);

    if (this.state.command === 'move') {
      for (let x = 0; x < markedBots.length; x++) {
        const bot = markedBots[x];
        console.log(`Move ${bot.name} to x: ${position.x}, z: ${position.y}`);
        this.commandMovement(bot, position);
      }
    } else if (this.state.command === 'face') {
      for (let x = 0; x < markedBots.length; x++) {
        const bot = markedBots[x];
        console.log(`Move ${bot.name} to x: ${position.x}, z: ${position.y}`);
        this.commandMovement(bot, position);
      }
    }
  }

  componentDidUpdate() {
    if (this.props.lastClickPosition !== this.state.lastClickPosition) {
      this.handleMapClick(this.props.lastClickPosition);
      this.setState({lastClickPosition: this.props.lastClickPosition});
    }
  }

  setCommand(command) {
    this.setState({command});
  }

  render() {
    return (
      <Draggable handle=".BotControllerHeader">
        <div className="BotController">
          <div className="BotControllerHeader">
            <span>Controller</span>
          </div>
          <div className="BotControllerContent">
            <button 
              className={this.state.command === 'move' ? 'selected' : null} 
              onClick={() => this.setCommand('move')}>
              Move
            </button>

            <button 
              className={this.state.command === 'face' ? 'selected' : null} 
              onClick={() => this.setCommand('face')}>
              Face
            </button>
          </div>
          <div className="BotControllerFooter">
          </div>
        </div>
      </Draggable>
    );
  }
}

export default BotController;
