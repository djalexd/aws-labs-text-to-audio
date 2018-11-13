
resource "aws_lambda_function" "get-submit-requests" {
  depends_on = ["null_resource.zip-code"]
  function_name = "text-to-audio-get-submit-requests"
  filename = "./functions/code.zip"
  source_code_hash = "${base64sha256(file("./functions/code.zip"))}"
  handler = "functions/list_submit_request.handler"
  runtime = "python3.6"
  role = "${aws_iam_role.lambda_execution.arn}"
  tags = "${var.tags}"
  environment = {
    variables = {
      requests_table = "${aws_dynamodb_table.text-to-audio-requests.name}"
    }
  }
}

resource "aws_lambda_permission" "get-submit-requests-permission" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.get-submit-requests.function_name}"
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.main.execution_arn}/*/*/*"
}

module "text-to-audio-GET" {
  source = "github.com/djalexd/terraform-lambda-api-gateway-integration"
  rest_api_id = "${aws_api_gateway_rest_api.main.id}"
  resource_id = "${aws_api_gateway_resource.text-to-audio.id}"
  http_method = "GET"
  use_api_key = "true"
  region      = "${var.region}"
  lambda_function = "${aws_lambda_function.get-submit-requests.arn}"
  lambda_role = "${aws_iam_role.apigateway-lamba-invocation-role.arn}"
  providers {
    aws = "aws"
  }
}

module "text-to-audio-OPTIONS" {
  source = "github.com/djalexd/terraform-lambda-api-gateway-integration-options"
  rest_api_id = "${aws_api_gateway_rest_api.main.id}"
  resource_id = "${aws_api_gateway_resource.text-to-audio.id}"
  providers {
    aws = "aws"
  }
}