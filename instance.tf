# Origionally was trying to create the webservers inside of a private subnet and then use a 
# bastion host to ssh into the private subnet and run the ansible playbook. I was having 
# issues with the bastion host and the webservers not being able to communicate with each other. 
# As a workaround, I changed to using public subnets for the webservers which isnt ideal but I've 
# left the other code commented out at the bottom of the file as proof-of-work-done.
# You can find any other code used for the old method commented in the bottom of each file.

# Nginx 1
resource "aws_instance" "nginx_1" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.haproxy_instance_type
  key_name      = aws_key_pair.aws_key.key_name
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.terraformansible-securitygroup.id]
  associate_public_ip_address = true
  tags = {
    Name = "nginx-1"
  }

  provisioner "local-exec" {
    command = "chmod 400 terraformansiblekey.pem"
  }

  provisioner "remote-exec" {
    inline = ["echo 'Wait until SSH is ready'"]
    
    connection {
      type        = "ssh" 
      user        = "ubuntu"
      private_key = tls_private_key.key.private_key_pem
      host        = aws_instance.nginx_1.public_ip
    }
  }

  provisioner "local-exec" {
    environment = {
      ANSIBLE_HOST_KEY_CHECKING = "false"
    }
    command = "ansible-playbook -i ${aws_instance.nginx_1.public_ip}, --private-key terraformansiblekey.pem nginx.yml"
  }
}

# Nginx 2
resource "aws_instance" "nginx_2" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.haproxy_instance_type
  key_name      = aws_key_pair.aws_key.key_name
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.terraformansible-securitygroup.id]
  associate_public_ip_address = true
  tags = {
    Name = "nginx-2"
  }

  provisioner "local-exec" {
    command = "chmod 400 terraformansiblekey.pem"
  }

  provisioner "remote-exec" {
    inline = ["echo 'Wait until SSH is ready'"]
    
    connection {
      type        = "ssh" 
      user        = "ubuntu"
      private_key = tls_private_key.key.private_key_pem
      host        = aws_instance.nginx_2.public_ip
    }
  }

  provisioner "local-exec" {
    environment = {
      ANSIBLE_HOST_KEY_CHECKING = "false"
    }
    command = "ansible-playbook -i ${aws_instance.nginx_2.public_ip}, --private-key terraformansiblekey.pem nginx.yml"
  }
}


# HAProxy
resource "aws_instance" "haproxy" {
  depends_on = [
    aws_key_pair.aws_key,
    aws_security_group.terraformansible-securitygroup,
    aws_subnet.public,
    tls_private_key.key,
    aws_route_table.route_table,
    aws_internet_gateway.internet_gateway,
    aws_route_table_association.route_table_association,
    aws_instance.nginx_1,
    aws_instance.nginx_2
  ]
  
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.haproxy_instance_type
  key_name                    = aws_key_pair.aws_key.key_name
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.terraformansible-securitygroup.id]
  associate_public_ip_address = true
  
  tags = {
    Name = "haproxy"
  }

  provisioner "local-exec" {
    command = "chmod 400 terraformansiblekey.pem"
  }

  provisioner "remote-exec" {
    inline = [
      "echo 'Wait until SSH is ready'",
      "echo '${aws_instance.nginx_1.public_ip} nginx1' >> hosts",
      "echo '${aws_instance.nginx_2.public_ip} nginx2' >> hosts"
    ]
    
    connection {
      type        = "ssh" 
      user        = "ubuntu"
      private_key = tls_private_key.key.private_key_pem
      host        = aws_instance.haproxy.public_ip
    }
  }

  provisioner "local-exec" {
    environment = {
      ANSIBLE_HOST_KEY_CHECKING = "false"
    }
    command = "ansible-playbook -i hosts --private-key terraformansiblekey.pem haproxy.yml"
  }
}


## Get the latest Ubuntu AMI
data "aws_ami" "ubuntu" {
 most_recent = true
 filter {
   name   = "name"
   values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
 }
 filter {
   name   = "virtualization-type"
   values = ["hvm"]
 }
 owners = ["099720109477"]
}




# ---------------- Private WebServer Code ---------------- #

# Create a bastion host
# resource "aws_instance" "bastion" {
#   depends_on = [
#     aws_instance.nginx_1,
#     aws_instance.nginx_2
#   ]

#   ami           = data.aws_ami.ubuntu.id
#   instance_type = var.haproxy_instance_type
#   key_name = aws_key_pair.aws_key.key_name
#   associate_public_ip_address = true
#   subnet_id                   = aws_subnet.public[0].id
#   vpc_security_group_ids      = [aws_security_group.haproxy.id]

#   tags = {
#     Name = "bastion"
#   }

#   provisioner "local-exec" {
#     command = "chmod 400 terraformansiblekey.pem"
#   }

#   provisioner "remote-exec" {
#     inline = ["echo 'Wait until SSH is ready'"]
#   }

#   provisioner "local-exec" {
#     environment = {
#       ANSIBLE_HOST_KEY_CHECKING = "false"
#     }
#     command = "ansible-playbook -i ${aws_instance.bastion.public_ip}, --private-key terraformansiblekey.pem bastion.yml"
#   }

#   connection {
#     type        = "ssh" 
#     user        = "ubuntu"
#     private_key = tls_private_key.key.private_key_pem
#     host        = aws_instance.bastion.public_ip
#   }

#   provisioner "local-exec" {
#     command = "ansible-playbook -i '${aws_instance.nginx_1.private_ip},' --private-key terraformansiblekey.pem nginx.yml"
#     environment = {
#       ANSIBLE_HOST_KEY_CHECKING = "false"
#     }
#   }

#   provisioner "local-exec" {
#     command = "ansible-playbook -i '${aws_instance.nginx_2.private_ip},' --private-key terraformansiblekey.pem nginx.yml"
#     environment = {
#       ANSIBLE_HOST_KEY_CHECKING = "false"
#     }
#   }
# }