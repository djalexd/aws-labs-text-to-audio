
data "aws_iam_policy_document" "invoke-lambda" {
  statement {
    resources = ["*"]
    actions = ["lambda:InvokeFunction"]
  }
}

resource "aws_iam_role_policy" "invoke-lambda" {
  name = "invoke-lambda"
  policy = "${data.aws_iam_policy_document.invoke-lambda.json}"
  role   = "${aws_iam_role.apigateway-lamba-invocation-role.id}"
}

data "aws_iam_policy_document" "cloudwatch-logs" {
  statement {
    resources = ["*"]
    actions = [
      "logs:*",
      "cloudwatch:*"
    ]
  }
}

resource "aws_iam_role_policy" "cloudwatch-logs" {
  name = "cloudwatch-logs"
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
  name = "apigateway-lamba-invocation-role"
  assume_role_policy = "${data.template_file.apigateway-lambda-invocation-role.rendered}"
}

resource "aws_iam_role_policy" "lambda_execution_policy" {
  name = "lambda_execution"
  role = "${aws_iam_role.lambda_execution.id}"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [{
    "Action": [
        "dynamodb:*",
        "cloudwatch:*",
        "logs:*",
        "polly:*",
        "s3:*",
        "sns:*"
    ],
    "Effect": "Allow",
    "Resource": "*"
  }]
}
EOF
}

resource "aws_iam_role" "lambda_execution" {
  name = "lambda_execution"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}