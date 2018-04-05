provider "aws" {
  /* Assumed that aws credentials are stored
     somewhere accessible to Terraform, such as
     ~/.aws/credentials. */
  region     = "us-east-2"
}

resource "aws_s3_bucket" "bucket" {
}
