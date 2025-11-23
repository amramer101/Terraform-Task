terraform {
  backend "s3" {
    bucket = "s3-terraform-2025"
    key    = "terraform/terraform.tfstate"
    region = "eu-west-3"  
  }
}