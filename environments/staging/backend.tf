terraform {
  backend "s3" {
    bucket         = "selmonosky-bootstrap-bucket"
    key            = "environments/dev/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "bootstrap-lock-table" # Enables state locking
  }
}