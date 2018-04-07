provider "aws" {
  /* Assumed that aws credentials are stored
     somewhere accessible to Terraform, such as
     ~/.aws/credentials. */
  region     = "us-east-2"
}

resource "aws_s3_bucket" "bucket" {
}

resource "aws_iam_role_policy" "lambda_policy" {
  name = "lambda_policy"
  role = "${aws_iam_role.iam_for_lambda.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": ["s3:ListBucket"],
      "Resource": ["${aws_s3_bucket.bucket.arn}"]
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:PutObject"
      ],
      "Resource": ["${aws_s3_bucket.bucket.arn}/*"]
    }
  ]
}
EOF
}

resource "aws_iam_role" "iam_for_lambda" {
  name = "iam_for_lambda"

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

resource "aws_lambda_function" "time_and_date_function" {
  filename        = "timeAndDate.zip"
  function_name   = "timeAndDateFunction"
  role            = "${aws_iam_role.iam_for_lambda.arn}"
  handler         = "timeAndDate.timeAndDate"
  source_code_hash = "${base64sha256(file("timeAndDate.zip"))}"
  runtime         = "nodejs6.10"

  environment {
    variables = {
      BUCKET = "${aws_s3_bucket.bucket.bucket_domain_name}"
    }
  }
}

/*
resource "aws_cloudwatch_event_rule" "every_five_minutes" {
    name = "every-five-minutes"
    description = "Fires every five minutes"
    schedule_expression = "rate(5 minutes)"
}

resource "aws_cloudwatch_event_target" "time_and_date_every_five_minutes" {
    rule = "${aws_cloudwatch_event_rule.every_five_minutes.name}"
    target_id = "time_and_date_function"
    arn = "${aws_lambda_function.time_and_date_function.arn}"
}

resource "aws_lambda_permission" "allow_cloudwatch_to_call_time_and_date_function" {
    statement_id = "AllowExecutionFromCloudWatch"
    action = "lambda:InvokeFunction"
    function_name = "${aws_lambda_function.time_and_date_function.function_name}"
    principal = "events.amazonaws.com"
    source_arn = "${aws_cloudwatch_event_rule.every_five_minutes.arn}"
}
*/
