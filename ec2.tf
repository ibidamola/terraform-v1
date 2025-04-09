#resource block
# Define the Security Group
resource "aws_security_group" "terraform_sg" {
  name        = "terraform_sg"
  description = "Security group for Terraform EC2 instance"
  
  # Allow SSH inbound access on port 22
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allow SSH from any IP (change for more security)
  }

  # Allow HTTP inbound access on port 80 (optional, if you're installing Apache)
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allow HTTP from any IP (change for more security)
  }

  # Allow all outbound traffic (default)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"  # All protocols
    cidr_blocks = ["0.0.0.0/0"]  # Allow outbound to any IP
  }
}



resource "aws_instance" "terraform_server"{
    ami = "ami-04f167a56786e4b09"
    instance_type = "t2.micro"
    count = 1
    key_name = "terraform"

    security_groups = [aws_security_group.terraform_sg]

    provisioner "remote-exec"{
        inline = [
            "sudo apt update -y",
            "sudo apt install -y apache2"
        ]
        connection {
          type = "ssh"
          user = "ubuntu"
          private_key = file ("C:/Users/Owner/Downloads/terraform.pem")
          host = self.public_ip
        }
      
    }


    tags = {
        Name = "MyTerraformInstance"
    }
}

resource "aws_ami_from_instance" "example_ami"  {
    name = "example_ami"
  
    source_instance_id = aws_instance.terraform_server[0].id
     
    description = "AMI created for my Terraform instance"
 
}