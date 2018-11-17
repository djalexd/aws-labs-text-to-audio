import axios from "axios";
import querystring from "querystring";

const getItems = ({
  baseUrl,
  apiKey
}) => {
  return axios.get(`${baseUrl}/text-to-audio`, {
      headers: {
        'x-api-key': apiKey
      }
    })
    .then(r => r.data)
}

const createItem = ({
  baseUrl,
  apiKey,
  voice = 'Nicole',
  text
}) => {
  return axios.post(`${baseUrl}/text-to-audio`, querystring.stringify({
      text,
      voice
    }), {
      headers: {
        'x-api-key': apiKey,
        'Content-Type': 'application/x-www-form-urlencoded'
      }
    })
    .then(r => r.data)
}

export {
  getItems,
  createItem
}