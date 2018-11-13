import json
import boto3
import os

def convert_to_mp3_and_store(id, text):
  polly_client = boto3.client('polly')
  speech_response = polly_client.synthesize_speech(
    OutputFormat='mp3',
    SampleRate='8000',
    Text=text,
    TextType='text',
    VoiceId='Nicole')

  s3_client = boto3.client('s3')
  s3_client.put_object(
      ACL='public-read',
      Body=speech_response['AudioStream'].read(),
      Bucket=os.environ['mp3_bucket'],
      Key='{}.mp3'.format(id),
      StorageClass='REDUCED_REDUNDANCY'
  )
  return 'http://' + os.environ['mp3_bucket'] + '/{}.mp3'.format(id)

def update_status(id, text, new_status, location=None):
    dynamodb_client = boto3.client('dynamodb')
    item = {
        'id': { 'S': id },
        'text': { 'S': text },
        'status': { 'S': new_status }
      }
    if location is not None:
      item['mp3_location'] = { 'S': location }
    dynamodb_client.put_item(
      TableName=os.environ['requests_table'],
      Item=item)
    print("Updated status for: id={} / {}".format(id, text))

def handler(event, context):
  # only one Sns record (even if others are sent, 
  # this lambda ignores them)
  print("Received raw Sns: {}".format(event))
  message = json.loads(event['Records'][0]['Sns']['Message'])
  print("Received message to process from Sns: {}".format(message))

  try:
    location = convert_to_mp3_and_store(message['id'], message['text'])
    update_status(
      message['id'], 
      message['text'],
      'PROCESSED',
      location)
    return 'done'
  except Exception as e:
    print('Failed to convert to mp3 due to {}'.format(e))
    update_status(message['id'], message['text'], 'FAILED', location=None)
    raise e
