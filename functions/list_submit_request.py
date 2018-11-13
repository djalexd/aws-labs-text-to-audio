import json
import boto3
import os
from functions.convert import convert_types

def handler(event, context):
  dynamodb_client = boto3.client('dynamodb')
  response = dynamodb_client.scan(
    TableName=os.environ['requests_table'],
    Limit=100)

  items = list(map(convert_types,response['Items']))
  return {
    'statusCode': 200,
    'body': json.dumps(items),
    'headers': {
      'Access-Control-Allow-Origin': '*'
    }
  }