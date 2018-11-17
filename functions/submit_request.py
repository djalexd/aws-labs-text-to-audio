import json
import boto3
import os
from urllib.parse import parse_qs
from functions.repositories import AudioText, Repo
from functions.errors import LambdaHttpStatusError
from functions.http import payload_response, error_response


def publish(item):
    sns_client = boto3.client('sns')
    sns_client.publish(
        TopicArn=os.environ['topic'],
        Message=json.dumps(item.__dict__))


def handler(event, context):
    print("submit-request received event {}".format(json.dumps(event)))
    try:
        if event['body'] is None:
            raise LambdaHttpStatusError(status=400, message='Body is empty')

        decoded = parse_qs(event['body'])
        if 'text' not in decoded:
            raise LambdaHttpStatusError(
                status=400, message='Text not specified')
        text = decoded['text'][0]
        if len(text) > 500:
            raise LambdaHttpStatusError(
                status=400, message='Text length larger than 500')

        repo = Repo(table=os.environ['requests_table'])
        item = AudioText(text=text, voice=decoded.get('voice', ['Nicole'])[0])
        print("Storing item: {}".format(item))
        repo.store(item)

        print("Publishing item: {}".format(item))
        publish(item)

        return payload_response(json.dumps(item.__dict__))
    except LambdaHttpStatusError as e:
        return error_response(e)
