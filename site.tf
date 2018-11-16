# requires credentials file
provider aws {
  region  = "${var.region}"
  profile = "${var.profile}"
}

variable "region" {
  default = "eu-west-1"
}

variable "account_id" {}

variable "tags" {
  type = "map"

  default = {
    AwsLab = "text_to_audio"
  }
}

variable "domain" {}

variable "profile" {
  default = "default"
}

# no need for s3 backend, this is a simple example.

resource "aws_s3_bucket" "website" {
  bucket = "${var.domain}"
  acl    = "public-read"
  region = "${var.region}"

  website {
    index_document = "index.html"
    error_document = "error.html"
  }

  tags = "${var.tags}"
}

resource "aws_s3_bucket" "mp3s" {
  bucket = "synthesized-speeches-mp3-bucket"
  acl    = "public-read"
  region = "${var.region}"
  tags   = "${var.tags}"

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET"]
    allowed_origins = ["*"]
    expose_headers  = ["ETag"]
    max_age_seconds = 3000
  }
}

resource "null_resource" "copy-contents" {
  # always provision this
  triggers = {
    uuid = "${uuid()}"
  }

  provisioner "local-exec" {
    command     = "npm run build && aws s3 cp --recursive build/ s3://${aws_s3_bucket.website.bucket} --region ${var.region} --profile ${var.profile} --acl public-read"
    working_dir = "website2"
  }
}

resource "aws_route53_zone" "website" {
  name = "${var.domain}"
}

resource "aws_route53_record" "main" {
  name    = "${var.domain}"
  zone_id = "${aws_route53_zone.website.zone_id}"
  type    = "A"

  alias = [{
    name                   = "s3-website-${var.region}.amazonaws.com."
    zone_id                = "Z1BKCTXD74EZPE"
    evaluate_target_health = "False"
  }]
}

resource "aws_api_gateway_rest_api" "main" {
  name = "aws-labs API"
}

resource "aws_api_gateway_resource" "text-to-audio" {
  rest_api_id = "${aws_api_gateway_rest_api.main.id}"
  parent_id   = "${aws_api_gateway_rest_api.main.root_resource_id}"
  path_part   = "text-to-audio"
}

resource "null_resource" "zip-code" {
  # always provision this
  triggers = {
    uuid = "${uuid()}"
  }

  provisioner "local-exec" {
    command = "rm -rf functions/code.zip && zip functions/code.zip functions/*.py"
  }
}

resource "aws_lambda_function" "process-request" {
  depends_on       = ["null_resource.zip-code"]
  function_name    = "text-to-audio-processor"
  filename         = "./functions/code.zip"
  source_code_hash = "${base64sha256(file("./functions/code.zip"))}"
  handler          = "functions/convert_to_audio.handler"
  runtime          = "python3.6"
  role             = "${aws_iam_role.lambda_execution.arn}"
  tags             = "${var.tags}"

  environment = {
    variables = {
      requests_table = "${aws_dynamodb_table.text-to-audio-requests.name}"
      mp3_bucket     = "${aws_s3_bucket.mp3s.bucket}"
      region         = "${var.region}"
    }
  }
}

resource "aws_dynamodb_table" "text-to-audio-requests" {
  name = "text-to-audio-requests"

  attribute = {
    name = "id"
    type = "S"
  }

  hash_key       = "id"
  write_capacity = 1
  read_capacity  = 1
  tags           = "${var.tags}"
}

resource "aws_sns_topic" "text-to-audio" {
  name = "text-to-audio-topic"
}

resource "aws_sns_topic_subscription" "configure-processor" {
  topic_arn = "${aws_sns_topic.text-to-audio.arn}"
  endpoint  = "${aws_lambda_function.process-request.arn}"
  protocol  = "lambda"
}

# resource "aws_lambda_event_source_mapping" "event_source_mapping" {
#   batch_size        = 100
#   event_source_arn  = "arn:aws:kinesis:REGION:123456789012:stream/stream_name"
#   enabled           = true
#   function_name     = "arn:aws:lambda:REGION:123456789012:function:function_name"
#   starting_position = "TRIM_HORIZON|LATEST"
# }

resource "aws_api_gateway_api_key" "apikey" {
  name = "text-to-audio-apikey"
}

resource "aws_api_gateway_usage_plan" "text-to-audio-plan" {
  name = "my_usage_plan"

  api_stages {
    api_id = "${aws_api_gateway_rest_api.main.id}"
    stage  = "${aws_api_gateway_deployment.foo.stage_name}"
  }
}

resource "aws_api_gateway_usage_plan_key" "main" {
  key_id        = "${aws_api_gateway_api_key.apikey.id}"
  key_type      = "API_KEY"
  usage_plan_id = "${aws_api_gateway_usage_plan.text-to-audio-plan.id}"
}

resource "aws_api_gateway_deployment" "foo" {
  rest_api_id = "${aws_api_gateway_rest_api.main.id}"
  stage_name  = "foo"

  depends_on = [
    "module.text-to-audio-POST",
    "module.text-to-audio-GET",
  ]
}

resource "aws_api_gateway_method_settings" "api_settings" {
  rest_api_id = "${aws_api_gateway_rest_api.main.id}"
  stage_name  = "${aws_api_gateway_deployment.foo.stage_name}"
  method_path = "*/*"

  settings {
    metrics_enabled = true
    logging_level   = "INFO"
  }

  depends_on = ["aws_iam_role.apigateway-lamba-invocation-role"]
}

# can be set via null_resource
# aws apigateway --profile ${var.profile} update-account --patch-operations op='replace',path='/cloudwatchRoleArn',value='${aws_iam_role.apigateway-lamba-invocation-role.arn}'

