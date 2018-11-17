resource "aws_lambda_function" "text-to-audio-POST" {
  depends_on       = ["null_resource.zip-code"]
  function_name    = "text-to-audio-POST"
  filename         = "./functions/code.zip"
  source_code_hash = "${base64sha256(file("./functions/code.zip"))}"
  handler          = "functions/submit_request.handler"
  runtime          = "python3.6"
  role             = "${aws_iam_role.lambda-execution-role-api.arn}"
  tags             = "${var.tags}"

  environment = {
    variables = {
      requests_table = "${aws_dynamodb_table.text-to-audio-requests.name}"
      region         = "${var.region}"
      topic          = "${aws_sns_topic.text-to-audio.arn}"
    }
  }
}

resource "aws_lambda_permission" "text-to-audio-POST-permission" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.text-to-audio-POST.function_name}"
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.main.execution_arn}/*/*/*"
}

module "text-to-audio-POST" {
  source          = "github.com/djalexd/terraform-lambda-api-gateway-integration"
  rest_api_id     = "${aws_api_gateway_rest_api.main.id}"
  resource_id     = "${aws_api_gateway_resource.text-to-audio.id}"
  http_method     = "POST"
  use_api_key     = "true"
  region          = "${var.region}"
  lambda_function = "${aws_lambda_function.text-to-audio-POST.arn}"
  lambda_role     = "${aws_iam_role.apigateway-lamba-invocation-role.arn}"

  providers {
    aws = "aws"
  }
}
