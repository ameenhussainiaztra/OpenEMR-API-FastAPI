terraform {
  backend "s3" {
    bucket  = "openemr-api-tf-state-aztra"
    key     = "openemr-api/terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
}
