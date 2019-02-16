import React, { Component } from 'react';
import mapIds from '../../mapIds.json';
import './index.css';

class Map extends Component {
  constructor (props) {
    super(props);

    this.state = {
      map: null,
      mapId: 16,
      mapWidth: 0,
      mapHeight: 0,
      units: [],
    };
    
    this.loadMap = this.loadMap.bind(this);
    this.addUnitMarker = this.addUnitMarker.bind(this);
    this.onMapChanged = this.onMapChanged.bind(this);
    this.convertToMapPosition = this.convertToMapPosition.bind(this);
    this.renderWaypoints = this.renderWaypoints.bind(this);

    this.settings = props.settings;
  }
  
  componentDidMount() {
    this.loadMap(this.state.mapId);
  }

  componentDidUpdate() {
    this.props.units.forEach(unit => {
      if (this.state.units.map(m => m.id).indexOf(unit.id) === -1) {
        this.addUnitMarker(unit.id, unit.position);
      } else {
        this.updateUnitMarker(unit.id, unit.position, unit.selected);
      }
    });

    if (this.props.mapId && this.props.mapId !== this.state.mapId) {
      this.loadMap(this.props.mapId);
    }

    this.renderWaypoints();
  }

  renderMapSelectOptions() {
    let x = 0;
    const maps = mapIds.map(map =>
      <option key={x++} value={map.id}>{map.name}</option>
    );
    return maps;
  }

  renderWaypoints() {
    if (!this.props.selectedWaypointProfile) {
      return;
    }
    
    const existingWps = [];
    this.state.map.eachLayer(layer => {
      if (layer._latlng) {
        existingWps.push(layer._latlng);
      }
    });

    this.props.selectedWaypointProfile.waypoints.forEach(wp => {
      const mapPosition = this.convertToMapPosition(wp);
      console.log(existingWps);
      if (existingWps.filter(w => w.lat === mapPosition.lat && w.lng === mapPosition.lng).length > 0) {
        console.log('exists');
        return;
      }

      const marker = window.L.marker([mapPosition.lat, mapPosition.lng], {
        icon: window.L.icon({
          iconUrl: './images/marked.png',  
          iconSize: [20, 20],
        })
      });

      marker.on('click', () => {
        this.props.onWaypointRemoved(wp);
        this.state.map.removeLayer(marker);
      });

      marker.addTo(this.state.map);
    });
  }

  convertToMapPosition(position) {
    const mapPosition = {
      x: this.state.mapWidth * position.x,
      y: this.state.mapHeight * position.y,
    }
    
    const southWest = this.state.map.unproject([0, mapPosition.y], this.state.map.getMaxZoom()-1);
    const northEast = this.state.map.unproject([mapPosition.x, 0], this.state.map.getMaxZoom()-1);

    return {
      lat: southWest.lat,
      lng: northEast.lng,
    }
  }
  
  convertToGamePosition(latLng) {
    const pos1 = this.state.map.project([0, latLng.lng], this.state.map.getMaxZoom()-1);
    const pos2 = this.state.map.project([latLng.lat, 0], this.state.map.getMaxZoom()-1);

    return {
      x: pos1.x / this.state.mapWidth,
      y: pos2.y / this.state.mapHeight,
    };
  }

  addUnitMarker(id, position) {
    const mapPosition = this.convertToMapPosition(position);
    const marker = window.L.marker([mapPosition.lat, mapPosition.lng], {
      icon: window.L.icon({
        iconUrl: './images/unmarked.png',  
        iconSize: [20, 20],
      })
    });

    this.state.units.push({ id, marker });
    marker.on('click', () => {
      const unit = this.state.units.filter(u => u.id === id)[0];
      if (unit.selected) {
        this.props.onBotUnselected(id);
      } else {
        this.props.onBotSelected(id);
      }
    });

    marker.addTo(this.state.map);
  }

  updateUnitMarker(id, position, selected) {
    const unit = this.state.units.filter(m => m.id === id)[0];
    const mapPosition = this.convertToMapPosition(position);
    unit.selected = selected;
    unit.marker.setLatLng(new window.L.LatLng(mapPosition.lat, mapPosition.lng));
    unit.marker.setIcon(window.L.icon({
      iconUrl: unit.selected ? './images/marked.png' : './images/unmarked.png',  
      iconSize: [20, 20],
    }));
  }

  loadMap(id) {
    console.log(id);
    const zoneIndex = mapIds.map(m => m.id).indexOf(parseInt(id));
    console.log(zoneIndex);
    const oldId = zoneIndex > -1 ? mapIds[zoneIndex].oldId : 0;
    
    const url = `https://wow.zamimg.com/images/wow/maps/enus/zoom/${oldId}.jpg`;
    console.log(url);
    let map;
    if (this.state.map == null) {
      map = window.L.map('image-map', {
        minZoom: 1,
        maxZoom: 6,
        center: [0, 0],
        zoom: 1,
        crs: window.L.CRS.Simple,
      });

      map.on('click', e => {
        this.props.onMapClicked(this.convertToGamePosition(e.latlng));
      });
    } else {
      map = this.state.map;
    }

    window.map = map;
    
    this.setState({
      map,
      mapId: id,
    });

    const img = new Image();
    img.onload = function() {
      const mapWidth = img.width * 20;
      const mapHeight = img.height * 20;

      this.setState({
        mapWidth,
        mapHeight,
      });

      const southWest = map.unproject([0, mapHeight], map.getMaxZoom()-1);
      const northEast = map.unproject([mapWidth, 0], map.getMaxZoom()-1);
      const bounds = new window.L.LatLngBounds(southWest, northEast);

      window.L.imageOverlay(url, bounds).addTo(map);

      map.setMaxBounds(bounds);
    }.bind(this);

    img.onerror = function() {
      img.src = "";
    }.bind(this);

    img.src = url;
  }

  onMapChanged(event) {
    this.props.onMapChanged(event.target.value);
  }

  render() {
    return (
      <div className="Map">
        <div className="MapHeader">
          <select className="MapSelector" onChange={this.onMapChanged}>
            {this.renderMapSelectOptions()}
          </select>
        </div>
        <div id="image-map"></div>
      </div>
    );
  }
}

export default Map;
