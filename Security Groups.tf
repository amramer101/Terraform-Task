
############### Frontend Security Group ####################
resource "aws_security_group" "Frontend-SG" {
  name        = "frontend-sg"
  description = "Allow Http/s , Uptime Kuma, SSH traffic"
  vpc_id = aws_vpc.project-vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Not a best Prractices  
  }

  ingress {
    from_port   = 3001
    to_port     = 3001
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Uptime Kuma  
  }


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]    
  }
}


################# Backend Security Group #######################
resource "aws_security_group" "Backend-SG" {
  name        = "backend-sg"
  description = "Allow Http/s, Uptime Kuma, SSH traffic"
  vpc_id = aws_vpc.project-vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    security_groups = [aws_security_group.Frontend-SG.id] # Allow from Frontend SG only
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Not a best Prractices  
  }

  ingress {
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    security_groups = [aws_security_group.Frontend-SG.id] # Allow from Frontend SG only
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]    
  }
}


################# Database Security Group #######################

resource "aws_security_group" "Database-SG" {
  name        = "database-sg"
  description = "Allow MySQL traffic only from Backend SG"
  vpc_id = aws_vpc.project-vpc.id

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.Backend-SG.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]    
  }
}