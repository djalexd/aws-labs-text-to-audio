import json

def payload_response(payload):
  return {
    'statusCode': 200,
    'body': payload,
    'headers': {
      'Access-Control-Allow-Origin': '*'
    }
  }

def error_response(err):
  return {
    'statusCode': err.status,
    'body': json.dumps({
      'message': err.message
    }),
    'headers': {
      'Access-Control-Allow-Origin': '*'
    }
  }
