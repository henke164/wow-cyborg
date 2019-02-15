import React, { Component } from 'react';
import './index.css';

class Map extends Component {
  constructor (props) {
    super(props);

    this.state = {
      map: null,
      mapWidth: 0,
      mapHeight: 0,
      units: [],
    };
    
    this.loadMap = this.loadMap.bind(this);
    this.addUnitMarker = this.addUnitMarker.bind(this);
    this.convertToMapPosition = this.convertToMapPosition.bind(this);
    
    this.settings = props.settings;
  }
  
  componentDidMount() {
    this.loadMap(16);
  }

  componentDidUpdate() {
    this.props.units.forEach(unit => {
      if (this.state.units.map(m => m.id).indexOf(unit.id) === -1) {
        this.addUnitMarker(unit.id, unit.position);
      } else {
        this.updateUnitMarker(unit.id, unit.position);
      }
    });
  }

  convertToMapPosition(position) {
    return {
      x: this.state.mapWidth * position.x,
      y: this.state.mapHeight * position.y,
    }
  }

  addUnitMarker(id, position) {
    const mapPosition = this.convertToMapPosition(position);
    const southWest = this.state.map.unproject([0, mapPosition.y], this.state.map.getMaxZoom()-1);
    const northEast = this.state.map.unproject([mapPosition.x, 0], this.state.map.getMaxZoom()-1);
    const marker = window.L.marker([southWest.lat, northEast.lng], {
      icon: window.L.icon({
        iconUrl: './images/unmarked.png',  
        iconSize: [20, 20],
      }),
      onClick: function() {
        alert('click');
      }
    });

    this.state.units.push({ id, marker });
    
    marker.addTo(this.state.map);
  }

  updateUnitMarker(id, position) {
    const unit = this.state.units.filter(m => m.id === id)[0];
    const mapPosition = this.convertToMapPosition(position);
    
    const southWest = this.state.map.unproject([0, mapPosition.y], this.state.map.getMaxZoom()-1);
    const northEast = this.state.map.unproject([mapPosition.x, 0], this.state.map.getMaxZoom()-1);
    unit.marker.setLatLng(new window.L.LatLng(southWest.lat, northEast.lng));
  }

  loadMap(id) {
    const url = `https://wow.zamimg.com/images/wow/maps/enus/zoom/${id}.jpg`;
    const map = window.L.map('image-map', {
      minZoom: 1,
      maxZoom: 6,
      center: [0, 0],
      zoom: 1,
      crs: window.L.CRS.Simple
    });

    const img = new Image();
    img.onload = function() {
      const mapWidth = img.width * 10;
      const mapHeight = img.height * 10;

      this.setState({
        map,
        mapWidth,
        mapHeight,
      });

      const southWest = map.unproject([0, mapHeight], map.getMaxZoom()-1);
      const northEast = map.unproject([mapWidth, 0], map.getMaxZoom()-1);
      const bounds = new window.L.LatLngBounds(southWest, northEast);

      window.L.imageOverlay(url, bounds).addTo(map);

      map.setMaxBounds(bounds);
    }.bind(this);

    img.src = url;
  }

  render() {
    return (
      <div className="Map">
        <div id="image-map"></div>
      </div>
    );
  }
}

export default Map;
