resource "aws_api_gateway_rest_api" "main" {
  name = "aws-labs API"
}

resource "aws_api_gateway_resource" "text-to-audio" {
  rest_api_id = "${aws_api_gateway_rest_api.main.id}"
  parent_id   = "${aws_api_gateway_rest_api.main.root_resource_id}"
  path_part   = "text-to-audio"
}

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

