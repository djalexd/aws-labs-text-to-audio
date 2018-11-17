import React, { Component } from "react";
import Item from "./item";
import { Howl } from "howler";
import SubmitItem from "./submitItem";
import { getItems, createItem } from "../api";

class ItemsList extends Component {
  state = {
    items: [],
    voice: undefined
  };

  componentDidMount() {
    getItems({
      baseUrl: this.props.apiBaseUrl,
      apiKey: this.props.apiKey
    }).then(items => {
      this.setState({ items });
    });
  }

  playSound = item => {
    const sound = new Howl({
      src: [item.mp3_location]
    });
    sound.play();
  };

  onTextAdd = text => {
    createItem({
      baseUrl: this.props.apiBaseUrl,
      apiKey: this.props.apiKey,
      voice: this.state.voice,
      text
    }).then(item => {
      const items = [item].concat(Array.from(this.state.items));
      this.setState({ items });
    });
  };

  onVoiceIdChange = e => {
    this.setState({ voice: e.target.value });
  };

  render() {
    return (
      <React.Fragment>
        <SubmitItem
          onTextAdd={this.onTextAdd}
          onVoiceIdChange={this.onVoiceIdChange}
        />
        <ul className="list-group">
          {this.state.items.map(item => (
            <Item key={item.id} item={item} onPlaySound={this.playSound} />
          ))}
        </ul>
      </React.Fragment>
    );
  }
}

export default ItemsList;
