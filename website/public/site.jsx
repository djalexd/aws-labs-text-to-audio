class App extends React.Component {
  constructor(props) {
    super(props)

    // Read from local storage
    const localStorageSupported = typeof(Storage) !== "undefined"
    this.state = {
      localStorageSupported,
      apiKey: localStorageSupported ? localStorage.apiKey : '',
      items: []
    }
  }
  configureApiKey = (apiKey) => {
    this.setState({ apiKey })
    if (typeof(Storage) !== "undefined") {
      localStorage.apiKey = apiKey
    }
  }

  clearApiKey = () => {
    this.setState({ apiKey: '' })
    if (typeof(Storage) !== "undefined") {
      localStorage.apiKey = ''
    }
  }

  render() {
    return (<div>
      <NoSupportForLocalStorage display={!this.state.localStorageSupported} />
      <ApiKeyConfigurator configureApiKey={this.configureApiKey} clearApiKey={this.clearApiKey} apiKey={this.state.apiKey} />
      <ItemsList apiKey={this.state.apiKey} />
    </div>)
  }
}

class ApiKeyConfigurator extends React.Component {
  constructor(props) {
    super(props)
    this.handleChange = this.handleChange.bind(this)
    this.state = { apiKey: props.apiKey }
  }

  handleChange(e) {
    e.preventDefault()
    this.setState({apiKey: e.target.value})
  }

  render() {
    return (
      <div className="row">
        <div className="alert alert-info" role="alert" style={{display: this.props.apiKey ? "block" : "none"}}>
          Using API key: {this.props.apiKey}
          <a href="#" className="badge badge-danger" onClick={() => this.props.clearApiKey()}>clear</a>
        </div>
        <div className="alert alert-warning" role="alert" style={{display: this.props.apiKey ? "none" : "block"}}>
        API key not yet configured!
        <div className="input-group mb-3">
          <div className="input-group-prepend">
            <span className="input-group-text" id="basic-addon3">api key</span>
          </div>
          <input type="text" className="form-control" id="basic-url" aria-describedby="basic-addon3" onChange={ this.handleChange }/>
        </div>
        <button type="button" className="btn btn-info" style={{marginLeft: 10}} onClick={() => this.props.configureApiKey(this.state.apiKey)}>configure</button>
        </div>
      </div>
    )
  }
}

const getItems = (baseUrl, apiKey) => {
  return new Promise(resolve => {
    const xhttp = new XMLHttpRequest();
    xhttp.onreadystatechange = function() {
      if (this.readyState == 4 && this.status == 200) {
        resolve(JSON.parse(this.responseText))
      }
    }
    xhttp.open("GET", `${baseUrl}/text-to-audio`, true)
    xhttp.setRequestHeader("X-Api-Key", apiKey)
    xhttp.send()
  })
}

const submitItem = (baseUrl, apiKey, text) => {
  return new Promise(resolve => {
    const xhttp = new XMLHttpRequest();
    xhttp.onreadystatechange = function() {
      if (this.readyState == 4 && this.status == 200) {
        resolve(JSON.parse(this.responseText))
      }
    }
    xhttp.open("POST", `${baseUrl}/text-to-audio`, true)
    xhttp.setRequestHeader("X-Api-Key",apiKey)
    xhttp.send(text)
  })
}

const NoSupportForLocalStorage = ({ display }) => (
  <div className="alert alert-warning" role="alert" style={{display: display? 'block': 'none' }} >
    Browser doesn't have support for localStorage. The API key cannot be configured
  </div>)

class SubmitItem extends React.Component {
  constructor(props) {
    super(props)
    this.handleChange = this.handleChange.bind(this)
    this.state = {text: ''}
  }

  handleChange(e) {
    e.preventDefault()
    this.setState({text: e.target.value})
  }

  render() {
    return (
      <div>Just input your text into input below and wait for background process to complete
        <div className="input-group">
          <div className="input-group-prepend">
            <span className="input-group-text">Your text</span>
          </div>
          <textarea className="form-control" onChange={this.handleChange}></textarea>
        </div>
        <button type="button" onClick={e => this.props.handler(this.state.text)}>Submit</button>
      </div>)
  }
}

class ItemsList extends React.Component {
  constructor(props) {
    super(props)

    this.state = { items: [] }
    getItems(`https://6lorfb62u4.execute-api.eu-west-1.amazonaws.com/foo`, props.apiKey)
      .then(items => this.setState({ items }))
  }

  submitItem = async (text) => {
    const result = await submitItem(`https://6lorfb62u4.execute-api.eu-west-1.amazonaws.com/foo`, this.props.apiKey, text)
    this.setState(previous => ({ items: [result].concat(previous.items) }))
  }

  render() {
    return (
      <div>
        <SubmitItem apiKey={this.props.apiKey} handler={this.submitItem}/>
        <ul>
          {this.state.items.map(item => (
            <Item key={item.id} item={item} />
          ))}
        </ul>
      </div>
    )
  }
}

const playSound = (e, location) => {
  e.preventDefault()
  const sound = new Howl({
    src: [location]
  })
  sound.play()
}

const Item = ({ item }) => (<li>{item.text}<i onClick={e => playSound(e, item.mp3_location)} className="fas fa-volume-up" style={{display: item.status === 'PROCESSED' ? '' : 'none'}}></i></li>)

ReactDOM.render(
  <App />,
  document.getElementById('root')
)