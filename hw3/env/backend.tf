terraform {
backend "s3" {
   bucket  = "hw3yael-bucket"
   key     = "terraform.tfstate"
   region  = "us-east-1"
   encrypt = true
  }
}
