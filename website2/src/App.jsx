import React, { Component } from "react";
import ItemsList from "./components/itemsList";
import ApiKeyConfigurator from "./components/apiKeyConfigurator";
import { library } from "@fortawesome/fontawesome-svg-core";
import { faPlay } from "@fortawesome/free-solid-svg-icons";

library.add(faPlay);

class App extends Component {
  state = {
    apiKey: typeof Storage !== "undefined" ? localStorage.apiKey : "",
    apiBaseUrl: "https://6lorfb62u4.execute-api.eu-west-1.amazonaws.com/foo"
  };

  handleConfigureApiKey = apiKey => {
    this.setState({ apiKey });
    if (typeof Storage !== "undefined") {
      localStorage.apiKey = apiKey;
    }
  };

  handleClearApiKey = () => {
    this.setState({ apiKey: "" });
    if (typeof Storage !== "undefined") {
      localStorage.apiKey = "";
    }
  };

  render() {
    return (
      <div className="container mt-2">
        <div className="border-bottom mb-2">
          <h1>Aws Labs: text to audio</h1>
          <h6>
            This website provides basic text to audio convertion using AWS
            technologies: Api Gateway, Lambda and Polly. The contents are stored
            using S3 static website
          </h6>
        </div>
        <ApiKeyConfigurator
          onConfigureApiKey={this.handleConfigureApiKey}
          onClearApiKey={this.handleClearApiKey}
          apiKey={this.state.apiKey}
        />
        <ItemsList apiKey={this.state.apiKey} apiBaseUrl={this.state.apiBaseUrl} />
      </div>
    );
  }
}

export default App;
