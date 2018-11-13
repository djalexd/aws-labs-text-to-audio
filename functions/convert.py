
def convert_types(body):
  result = {}
  for key in body:
    result[key] = body[key]['S']
  return result