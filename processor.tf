resource "aws_lambda_function" "process-request" {
  depends_on       = ["null_resource.zip-code"]
  function_name    = "text-to-audio-processor"
  filename         = "./functions/code.zip"
  source_code_hash = "${base64sha256(file("./functions/code.zip"))}"
  handler          = "functions/convert_to_audio.handler"
  runtime          = "python3.6"
  role             = "${aws_iam_role.lambda-execution-role-processor.arn}"
  tags             = "${var.tags}"
  timeout          = 30

  environment = {
    variables = {
      requests_table = "${aws_dynamodb_table.text-to-audio-requests.name}"
      mp3_bucket     = "${aws_s3_bucket.mp3s.bucket}"
      region         = "${var.region}"
    }
  }
}

resource "aws_lambda_permission" "process-request-permission" {
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.process-request.function_name}"
  principal     = "sns.amazonaws.com"
  source_arn    = "${aws_sns_topic.text-to-audio.arn}"
}

resource "aws_sns_topic_subscription" "configure-processor" {
  topic_arn = "${aws_sns_topic.text-to-audio.arn}"
  endpoint  = "${aws_lambda_function.process-request.arn}"
  protocol  = "lambda"
}

# configure IAM role for this lambda, I believe the right way!

resource "aws_iam_role" "lambda-execution-role-processor" {
  name               = "lambda-execution-role-processor"
  assume_role_policy = "${data.template_file.lambda-execution-role-api.rendered}"
}

resource "aws_iam_role_policy" "lambda-execution-role-processor-dynamodb-readwrite" {
  policy = "${data.aws_iam_policy_document.dynamodb-readwrite.json}"
  role   = "${aws_iam_role.lambda-execution-role-processor.id}"
}

resource "aws_iam_role_policy" "lambda-execution-role-processor-cloudwatch-logs" {
  policy = "${data.aws_iam_policy_document.cloudwatch-logs.json}"
  role   = "${aws_iam_role.lambda-execution-role-processor.id}"
}

data "aws_iam_policy_document" "polly-synthetize-speech" {
  statement {
    resources = ["*"]

    actions = [
      "polly:SynthesizeSpeech",
    ]
  }
}

resource "aws_iam_role_policy" "lambda-execution-role-processor-polly" {
  policy = "${data.aws_iam_policy_document.polly-synthetize-speech.json}"
  role   = "${aws_iam_role.lambda-execution-role-processor.id}"
}
