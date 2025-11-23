variable "region" {
  description = "The region where resources will be deployed"
  type        = string
  default     = "eu-west-3"
}

variable "az" {
  description = "The availability zone"
  type        = string
  default     = "eu-west-3a"
  
}

variable "az2" {
  description = "The availability zone"
  type        = string
  default     = "eu-west-3b"
  
}


variable "amiID" {
  description = "The AMI ID for the EC2 instances"
  type        = string
  default     = "ami-0ef9bcd5dfb57b968"
  
}

variable "db-password" {

  description = "The password for the RDS database"
  type        = string
  default     = "AWDSecurePass123!"
  sensitive   = true  
  
}

variable "db-name" {
  description = "The name of the RDS database"
  type        = string
  default     = "ecommerce_db"
  
}