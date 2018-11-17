data "aws_iam_policy_document" "invoke-lambda" {
  statement {
    resources = ["*"]
    actions   = ["lambda:InvokeFunction"]
  }
}

resource "aws_iam_role_policy" "invoke-lambda" {
  name   = "invoke-lambda"
  policy = "${data.aws_iam_policy_document.invoke-lambda.json}"
  role   = "${aws_iam_role.apigateway-lamba-invocation-role.id}"
}

data "aws_iam_policy_document" "cloudwatch-logs" {
  statement {
    resources = ["*"]

    actions = [
      "logs:*",
      "cloudwatch:*",
    ]
  }
}

data "aws_iam_policy_document" "dynamodb-readwrite" {
  statement {
    resources = ["*"]

    actions = [
      "dynamodb:GetItem",
      "dynamodb:BatchGetItem",
      "dynamodb:Scan",
      "dynamodb:Query",
      "dynamodb:PutItem",
      "dynamodb:UpdateItem",
    ]
  }
}

data "aws_iam_policy_document" "sns-publish" {
  statement {
    resources = ["*"]

    actions = [
      "sns:Publish",
    ]
  }
}

resource "aws_iam_role_policy" "cloudwatch-logs" {
  name   = "cloudwatch-logs"
  policy = "${data.aws_iam_policy_document.cloudwatch-logs.json}"
  role   = "${aws_iam_role.apigateway-lamba-invocation-role.id}"
}

data "template_file" "apigateway-lambda-invocation-role" {
  template = "${file("${path.module}/iam_role.tpl")}"

  vars {
    service = "apigateway.amazonaws.com"
  }
}

resource "aws_iam_role" "apigateway-lamba-invocation-role" {
  name               = "apigateway-lamba-invocation-role"
  assume_role_policy = "${data.template_file.apigateway-lambda-invocation-role.rendered}"
}

# these are the resources related to execution roles for
# lambdas that are connected to API. Usually they have less
# permissions than others.
data "template_file" "lambda-execution-role-api" {
  template = "${file("${path.module}/iam_role.tpl")}"

  vars {
    service = "lambda.amazonaws.com"
  }
}

resource "aws_iam_role" "lambda-execution-role-api" {
  name               = "lambda-execution-role-api"
  assume_role_policy = "${data.template_file.lambda-execution-role-api.rendered}"
}

resource "aws_iam_role_policy" "lambda-execution-role-api-dynamodb-readwrite" {
  name   = "lambda-execution-role-api-dynamodb-readwrite"
  policy = "${data.aws_iam_policy_document.dynamodb-readwrite.json}"
  role   = "${aws_iam_role.lambda-execution-role-api.id}"
}

resource "aws_iam_role_policy" "lambda-execution-role-api-cloudwatch-logs" {
  name   = "lambda-execution-role-api-cloudwatch-logs"
  policy = "${data.aws_iam_policy_document.cloudwatch-logs.json}"
  role   = "${aws_iam_role.lambda-execution-role-api.id}"
}

resource "aws_iam_role_policy" "lambda-execution-role-api-sns-publish" {
  name   = "lambda-execution-role-api-sns-publish"
  policy = "${data.aws_iam_policy_document.sns-publish.json}"
  role   = "${aws_iam_role.lambda-execution-role-api.id}"
}
