resource "aws_instance" "EC2-Backend" {

    ami           = var.amiID
    instance_type = "t2.micro"

    subnet_id     = aws_subnet.project-subnet-public.id
    vpc_security_group_ids = [aws_security_group.Backend-SG.id]

    key_name      = aws_key_pair.dev-key.key_name
    
    availability_zone = var.az


    root_block_device {
    volume_size           = 8
    volume_type           = "gp3"
    delete_on_termination = true

  }

    tags = {
        Name = "EC2-Backend"
    }


    user_data = file("scripts/backend-setup.sh")

}