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

variable "base_path" {
  default = ""
}

# profile is used for commands executed through aws cli (see below)
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
    command     = "PUBLIC_URL=http://${var.domain}/${var.base_path} npm run build && aws s3 cp --recursive build/ s3://${aws_s3_bucket.website.bucket}/${var.base_path} --region ${var.region} --profile ${var.profile} --acl public-read"
    working_dir = "website"
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
    name = "s3-website-${var.region}.amazonaws.com."

    # this zone will only work when region == 'eu-west-1'
    # other regions will have other zone_ids, consult AWS documentation
    zone_id = "Z1BKCTXD74EZPE"

    evaluate_target_health = "False"
  }]
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
