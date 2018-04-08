provider "aws" {
  /* Assumed that aws credentials are stored
     somewhere accessible to Terraform, such as
     ~/.aws/credentials. If necessary, uncomment
     the two lines below and put in the keys */
# access_key = "ACCESSKEY"
# secret_key = "SECRETKEY"
  region     = "us-east-2"
}

# Create an AWS bucket
resource "aws_s3_bucket" "bucket" {
}

# Create an IAM role policy to give the
# Lambda function write access to the bucket
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

# Create a role for the Lambda
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

# Create the lambda itself from the deployment zip
resource "aws_lambda_function" "time_and_date_function" {
  filename        = "timeAndDate.zip"
  function_name   = "timeAndDateFunction"
  role            = "${aws_iam_role.iam_for_lambda.arn}"
  handler         = "timeAndDate.timeAndDate"
  source_code_hash = "${base64sha256(file("timeAndDate.zip"))}"
  runtime         = "nodejs6.10"

  # Make the bucket name an environment variable so the code
  # can use the bucket name when writing to S3 without hard
  # coding the name of the bucket into the source
  environment {
    variables = {
      BUCKET = "${aws_s3_bucket.bucket.bucket_domain_name}"
    }
  }
}

# Create a cloudwatch event to invoke the function every 5 minutes
resource "aws_cloudwatch_event_rule" "every_five_minutes" {
    name = "every-five-minutes"
    description = "Fires every five minutes"
    schedule_expression = "rate(5 minutes)"
}

# Make the lambda function the target of the cloudwatch event
resource "aws_cloudwatch_event_target" "time_and_date_every_five_minutes" {
    rule = "${aws_cloudwatch_event_rule.every_five_minutes.name}"
    target_id = "time_and_date_function"
    arn = "${aws_lambda_function.time_and_date_function.arn}"
}

# Give the cloudwatch permissions to invoke the lambda function
resource "aws_lambda_permission" "allow_cloudwatch_to_call_time_and_date_function" {
    statement_id = "AllowExecutionFromCloudWatch"
    action = "lambda:InvokeFunction"
    function_name = "${aws_lambda_function.time_and_date_function.function_name}"
    principal = "events.amazonaws.com"
    source_arn = "${aws_cloudwatch_event_rule.every_five_minutes.arn}"
}
