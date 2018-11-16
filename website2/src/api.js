import axios from "axios";

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
  text
}) => {
  return axios.post(`${baseUrl}/text-to-audio`, text, {
      headers: {
        'x-api-key': apiKey
      }
    })
    .then(r => r.data)
}

export {
  getItems,
  createItem
}