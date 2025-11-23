resource "aws_key_pair" "dev-key" {
  key_name   = "dev-key"
  public_key = file("keys/aws-terraform.pub")
}