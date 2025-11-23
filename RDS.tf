resource "aws_db_instance" "rds" {
  allocated_storage      = 10
  db_name                = var.db-name
  engine                 = "mysql"
  engine_version         = "8.0"          
  instance_class         = "db.t3.micro" 
  username               = "admin"
  password               = var.db-password  
  parameter_group_name   = "default.mysql8.0"
  skip_final_snapshot    = true
  db_subnet_group_name   = aws_db_subnet_group.rds_subnet_group.name
  vpc_security_group_ids = [aws_security_group.Database-SG.id]
  publicly_accessible    = false  
       
}