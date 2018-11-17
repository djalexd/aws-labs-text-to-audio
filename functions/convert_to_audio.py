import json
import boto3
import os
from uuid import uuid4


def convert_to_mp3_and_store(text, voice='Nicole'):
    polly_client = boto3.client('polly')
    speech_response = polly_client.synthesize_speech(
        OutputFormat='mp3',
        SampleRate='8000',
        Text=text,
        TextType='text',
        VoiceId=voice)

    s3_client = boto3.client('s3')
    key = '{}.mp3'.format(str(uuid4()))
    s3_client.put_object(
        ACL='public-read',
        Body=speech_response['AudioStream'].read(),
        Bucket=os.environ['mp3_bucket'],
        Key=key,
        StorageClass='REDUCED_REDUNDANCY'
    )
    return 'https://s3-{}.amazonaws.com/{}/{}'.format(os.environ['region'], os.environ['mp3_bucket'], key)


def update_status(id, new_status, location=None):
    attrs = {
        'status': {
            'Value': {'S': new_status},
            'Action': 'PUT'
        }
    }
    if location:
        attrs.update({'mp3_location': {
            'Value': {'S': location},
            'Action': 'PUT'
        }})
    dynamodb_client = boto3.client('dynamodb')
    dynamodb_client.update_item(
        TableName=os.environ['requests_table'],
        Key={
            'id': {'S': id}
        },
        AttributeUpdates=attrs)
    print("Updated status for: id={} / new_status={}".format(id, new_status))


def handler(event, context):
    # only one Sns record (even if others are sent,
    # this lambda ignores them)
    print("Received raw Sns: {}".format(event))
    for record in event['Records']:
        message = json.loads(record['Sns']['Message'])
        print("Received message to process from Sns: {}".format(message))

        id = message['id']
        try:
            location = convert_to_mp3_and_store(
                message['text'], voice=message.get('voice', 'Nicole'))
            update_status(
                id,
                new_status='PROCESSED',
                location=location)
            return 'done'
        except Exception as e:
            print('Failed to convert to mp3 due to {}'.format(e))
            update_status(id, new_status='FAILED')
            raise e
