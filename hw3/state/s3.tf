provider "aws" {
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  region     = var.region
}
resource "aws_s3_bucket" "bucket" {
  bucket = "hw3yael-bucket"
#   acl    = "private"

  tags = {
    Name        = "HW3 bucket"
    Environment = "Dev"
  }
}
