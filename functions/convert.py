
def from_dynamodb_raw(item):
  result = {}
  for key in item:
    value = item[key]
    if 'S' in value:
      result[key] = value['S']
    elif 'N' in value:
      result[key] = value['N']
    else:
      raise Exception('unmapped kind {}'.format(value))
  return result

def to_dynamodb_raw(item):
  result = {}
  wrapped_dict = item.__dict__ if item.__dict__ is not None else item
  for key in wrapped_dict:
    value = wrapped_dict[key]
    if type(value) is str:
      result[key] = { 'S': value }
    elif type(value) is int or type(value) is float:
      result[key] = { 'N': value }
    elif value is None:
      pass
    else:
      raise Exception('unmapped kind {}'.format(type(value)))
  return result
