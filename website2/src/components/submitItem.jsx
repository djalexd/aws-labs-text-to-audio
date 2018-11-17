import React, { Component } from "react";

class SubmitItem extends Component {
  state = {
    text: "",
    voices: ["Nicole", "Brian", "Amy", "Joey", "Justin", "Kendra", "Salli"]
  };

  handleChange = e => {
    this.setState({ text: e.target.value });
  };

  onTextAdd = text => {
    if (text.length === 0) {
      return;
    }
    this.props.onTextAdd(text);
    this.setState({
      text: ""
    });
  };

  displayEmptyTextError = () => {
    if (this.state.text.length === 0) {
      return "block";
    } else {
      return "none";
    }
  };

  render() {
    return (
      <div>
        <span>
          Just input your text into input below and wait for background process to
          complete, max <b>500</b> characters.
        </span>
        <div className="input-group mb-1">
          <div className="input-group-prepend">
            <span className="input-group-text">Your text:</span>
          </div>
          <textarea
            className="form-control"
            onChange={this.handleChange}
            rows="8"
            value={this.state.text}
          />
        </div>
        <div
          className="invalid-feedback"
          style={{ display: this.displayEmptyTextError() }}
        >
          *Text is required
        </div>
        <div className="row justify-content-center">
          <button
            className="btn btn-info btn-lg col-4 shadow p-3 mt-1 mb-4"
            onClick={() => this.onTextAdd(this.state.text)}
          >
            Submit
          </button>
          <p className="m-1 text-muted col-lg-2">
            <small>You can also choose the voice</small>
          </p>
          <select
            className="ml-1 mt-1 mb-4 shadow"
            onChange={this.props.onVoiceIdChange}
          >
            {this.state.voices.map(voiceId => (
              <option key={voiceId} value={voiceId}>
                {voiceId}
              </option>
            ))}
          </select>
        </div>
      </div>
    );
  }
}

export default SubmitItem;
