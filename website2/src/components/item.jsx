import React, { Component } from "react";
import { FontAwesomeIcon } from "@fortawesome/react-fontawesome";

class Item extends Component {
  state = {};

  itemClasses() {
    if (this.props.item.status === "FAILED") {
      return "list-group-item disabled";
    } else {
      return "list-group-item";
    }
  }

  badgeClasses() {
    let common = "badge m-2";
    switch (this.props.item.status) {
      case "NEW":
        return common + " badge-light";
      case "PROCESSED":
        return common + " badge-success";
      case "FAILED":
        return common + " badge-danger";
      default:
        throw new Error("unknown status");
    }
  }

  render() {
    return (
      <li
        className={this.itemClasses()}
        onMouseOver={() => this.setState({ showIcon: true })}
        onMouseOut={() => this.setState({ showIcon: false })}
      >
        <span className={this.badgeClasses()}>{this.props.item.status}</span>
        {this.props.item.text}
        <FontAwesomeIcon
          icon="play"
          className="ml-3 fa-sm"
          style={{
            display:
              this.state.showIcon && this.props.item.status === "PROCESSED"
                ? "inline-block"
                : "none"
          }}
          onClick={() => this.props.onPlaySound(this.props.item)}
        />
      </li>
    );
  }
}

export default Item;
