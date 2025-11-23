output "frontend_public_ip" {
  description = "Public IP of Frontend Server"
  value       = aws_instance.EC2-Frontend.public_ip
}

output "backend_public_ip" {
  description = "Public IP of Backend Server"
  value       = aws_instance.EC2-Backend.public_ip
}

output "rds_endpoint" {
  description = "RDS MySQL Endpoint"
  value       = aws_db_instance.rds.endpoint
  sensitive   = true
}

output "rds_hostname" {
  description = "RDS MySQL Hostname"
  value       = aws_db_instance.rds.address
}

output "rds_port" {
  description = "RDS MySQL Port"
  value       = aws_db_instance.rds.port
}

output "frontend_ssh_command" {
  description = "SSH command for Frontend server"
  value       = "ssh -i /keys/aws-terraform ubuntu@${aws_instance.EC2-Frontend.public_ip}"
}

output "backend_ssh_command" {
  description = "SSH command for Backend server"
  value       = "ssh -i /keys/aws-terraform ubuntu@${aws_instance.EC2-Backend.public_ip}"
}