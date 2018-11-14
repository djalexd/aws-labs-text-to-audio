import json
import boto3
import os
from functions.repositories import AudioText, Repo
from functions.http import payload_response

def handler(event, context):
  repo = Repo(table=os.environ['requests_table'])
  items = repo.scan()
  # perhaps convert to AudioText?
  return payload_response(json.dumps(items))