import json
import boto3
import os

def handler(event, context):
  dynamodb_client = boto3.client('dynamodb')
  response = dynamodb_client.scan(
    TableName=os.environ['requests_table'],
    Limit=100)

  def from_raw(x):
    return {
      'id': x['id']['S'],
      'text': x['text']['S'],
      'status': x['status']['S']
    }
  items = list(map(from_raw,response['Items']))
  return {
    'statusCode': 200,
    'body': json.dumps(items),
    'headers': {
      'Access-Control-Allow-Origin': '*'
    }
  }