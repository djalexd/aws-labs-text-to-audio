import json
import boto3
from uuid import uuid4
import os

def handler(event, context):
  print("submit-request received event {}".format(json.dumps(event)))
  no_body = {
    "message": "Body is empty"
  }
  if event['body'] is None:
    return {
      'statusCode': 400,
      'body': json.dumps(no_body),
      'headers': {
        'Access-Control-Allow-Origin': '*'
      }
    }
  else:
    text = event['body']
    print("Storing text to convert: {}".format(text))

    dynamodb = boto3.client('dynamodb')
    id = str(uuid4())
    dynamodb.put_item(
      TableName=os.environ['requests_table'],
      Item={
        'id': { 'S': id },
        'text': { 'S': text },
        'status': { 'S': 'NEW' }
      })
    print("Stored text to convert: id={} / {}".format(id, text))

    sns_client = boto3.client('sns')
    sns_client.publish(
      TopicArn=os.environ['topic'],
      Message=json.dumps({
        'id': id,
        'text': text
      })
    )
    print("Published message to SNS")

    return {
      "statusCode": 200,
      "body": json.dumps({
        'id': id,
        'text': text
      }),
      'headers': {
        'Access-Control-Allow-Origin': '*'
      }
    }