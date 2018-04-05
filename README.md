# AWS S3 Lambda Project

This project creates an Amazon S3 bucket, and creates a lambda function set to run every five
minutes. Every time it runs it puts a file containing the current date and time into the S3
bucket. It also includes an IAM policy allowing the lambda function to write to the S3 bucket.

## Assumptions

- This repo contains no AWS credentials. By default on linux (which is the OS this project was
created on), terraform is able to find AWS credentials in ~/.aws/credentials. If your machine
does not store credentials in a standard place, the AWS access key and secret key for your
account can be added to main.tf.

## Running the project

1. **Install terraform.** 
    Terraform can be installed as a binary from https://www.terraform.io/downloads.html 
    Versions used to develop this project:
       Terraform v0.11.5
       + provider.aws v1.13.0 

2. Run `terraform init`

3. Run `terraform apply`
