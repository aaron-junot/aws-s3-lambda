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
      "Resource": ["arn:aws:s3:::terraform-20180405020804602800000001"]
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:PutObject"
      ],
      "Resource": ["arn:aws:s3:::terraform-20180405020804602800000001/*"]
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
  handler         = "exports.timeAndDate"
  runtime         = "nodejs6.10"
}
