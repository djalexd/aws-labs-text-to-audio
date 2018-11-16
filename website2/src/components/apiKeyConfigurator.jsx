import React, { Component } from "react";

class ApiKeyConfigurator extends Component {
  state = {
    apiKey: this.props.apiKey,
    localStorageSupported: typeof Storage !== "undefined"
  };

  handleChange = e => {
    this.setState({ apiKey: e.target.value });
  };

  render() {
    return (
      <div className="mt-2 mb-4">
        <div
          className="alert alert-warning"
          style={{ display: !this.state.localStorageSupported ? "block" : "none" }}
        >
          Browser doesn't have support for localStorage. The API key cannot be
          configured
        </div>
        <h5>ApiKey configurator</h5>
        <div
          className="alert alert-info"
          style={{ display: this.props.apiKey ? "block" : "none" }}
        >
          Using API key: {this.props.apiKey}
          <a
            href="#"
            className="badge badge-danger m-2"
            onClick={() => this.props.onClearApiKey()}
          >
            clear
          </a>
        </div>
        <div
          className="alert alert-warning"
          style={{ display: this.props.apiKey ? "none" : "block" }}
        >
          API key not yet configured!
          <input className="form-control" onChange={this.handleChange} />
          <button
            className="btn btn-info"
            onClick={() => this.props.onConfigureApiKey(this.state.apiKey)}
          >
            Set
          </button>
        </div>
      </div>
    );
  }
}

export default ApiKeyConfigurator;
