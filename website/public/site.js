
function NoSupportForLocalStorage(props) {
  return <div class="alert alert-warning" role="alert">
    Browser doesn't have support for localStorage. The API key cannot be configured
  </div>
}

function ConfigureApiKey(props) {
  return <div class="alert alert-warning" role="alert">
    API key not yet configured!
    <div class="input-group mb-3">
      <div class="input-group-prepend">
        <span class="input-group-text" id="basic-addon3">api key</span>
      </div>
      <input type="text" class="form-control" id="basic-url" aria-describedby="basic-addon3"/>
    </div>
    <button type="button" class="btn btn-info" style="margin-left: 10px" onclick="storeApiKey()">configure</button>
  </div>
}

function UsingApiKey(props) {
  return <div class="alert alert-info" role="alert">
    Using API key: {props.apiKey}
  </div>
}