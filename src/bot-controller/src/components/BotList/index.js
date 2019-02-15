import React, { Component } from 'react';
import Draggable from 'react-draggable';
import './index.css';

class BotList extends Component {
  constructor() {
    super();

    this.toggleAddBotFrame = this.toggleAddBotFrame.bind(this);
    this.addBot = this.addBot.bind(this);
    this.renderBots = this.renderBots.bind(this);

    this.addBotName = React.createRef();
    this.addBotIp = React.createRef();

    this.state = {
      displayAddBotFrame: false,
    };
  }

  addBot() {
    if (this.props.onBotAdded) {
      this.props.onBotAdded({
        id: Math.floor(Math.random() * 100000),
        name: this.addBotName.current.value, 
        ip: `127.0.0.1`,// this.addBotIp.current.value,
        position: { 
          x: 0, 
          y: 0
        },
        selected: false,
      });
    }

    this.setState({displayAddBotFrame: false});
  }

  renderAddBotFrame() {
    if (this.state.displayAddBotFrame) {
      return (
        <div className="AddBot">
          <div className="BotListHeader">
            <span>Add bot</span>
          </div>
          <div className="BotListContent">
            <span>Name:</span>
            <input ref={this.addBotName} type="text"></input>
            <span>Ip:</span>
            <input ref={this.addBotIp} type="text"></input>
            <button onClick={this.addBot}>Add</button>
          </div>
          <div className="BotListFooter">
            <a href="#" onClick={this.toggleAddBotFrame}>Close</a>
          </div>
        </div>
      );
    }
    return null;
  }

  toggleAddBotFrame() {
    this.setState({displayAddBotFrame: !this.state.displayAddBotFrame});
  }

  renderBots() {
    return this.props.bots.map(bot => {
      return bot.selected ? (
        <a key={bot.id} href="#"
          className={"selected"}
          onClick={() => this.props.onBotUnselected(bot.id)}
        >{bot.name}</a>
      ) : (
        <a key={bot.id} href="#"
          onClick={() => this.props.onBotSelected(bot.id)}
        >{bot.name}</a>
      )
    });
  }

  render() {
    return (
      <Draggable handle=".BotListHeader">
        <div className="BotList">
          <div className="BotListHeader">
            <span>Botlist</span>
          </div>
          <div className="BotListContent">
            {this.renderBots()}
          </div>
          <div className="BotListFooter">
            <a href="#" onClick={this.toggleAddBotFrame}>+</a>
          </div>
          {this.renderAddBotFrame()}
        </div>
      </Draggable>
    );
  }
}

export default BotList;
