
################## VPC and Subnets #######################
resource "aws_vpc" "project-vpc" {
    cidr_block = "10.0.0.0/16"    
    tags = {
        Name = "project-vpc"
    }
}

resource "aws_subnet" "project-subnet-public" {
  vpc_id            = aws_vpc.project-vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = var.az
  map_public_ip_on_launch = true
}

resource "aws_subnet" "project-subnet-private1" {
  vpc_id            = aws_vpc.project-vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = var.az
}

resource "aws_subnet" "project-subnet-private2" {
  vpc_id            = aws_vpc.project-vpc.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = var.az2
}


#####3############ RDS Subnet Group #######################

resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "rds-subnet-group"
  subnet_ids = [aws_subnet.project-subnet-private1.id, aws_subnet.project-subnet-private2.id]

  tags = {
    Name = "RDS subnet group"
  }
  
}


################# Internet Gateway #######################

resource "aws_internet_gateway" "public-gateway" {
  vpc_id = aws_vpc.project-vpc.id
}   


################### Route Table #######################


resource "aws_route_table" "public-route-table" {
  vpc_id = aws_vpc.project-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.public-gateway.id
  }

  tags = {
    Name = "public-route-table"
  }
}

resource "aws_route_table_association" "public-subnet-association" {
  subnet_id      = aws_subnet.project-subnet-public.id
  route_table_id = aws_route_table.public-route-table.id
}


