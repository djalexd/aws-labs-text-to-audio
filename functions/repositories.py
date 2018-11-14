from uuid import uuid4
import boto3
from functions.convert import from_dynamodb_raw, to_dynamodb_raw


class AudioText:
  """
  Class that represents the storage for an text-to-audio payload.
  """
  def __init__(self, **kwargs):
    self.text, self.id, self.status, self.mp3_location = \
      kwargs['text'], \
      kwargs.get('id', str(uuid4())), \
      kwargs.get('status', 'NEW'), \
      kwargs.get('mp3_location', None)

class Repo:
  def __init__(self, **kwargs):
    self.table = kwargs['table']
    self.dynamodb = boto3.client('dynamodb')

  def store(self, item):
    self.dynamodb.put_item(
      TableName=self.table,
      Item=to_dynamodb_raw(item))
    return item

  def scan(self, **kwargs):
    response = self.dynamodb.scan(
      TableName=self.table,
      Limit=kwargs.get('limit', 100))
    return list(map(from_dynamodb_raw, response['Items']))