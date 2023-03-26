resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_cidr_block

  tags = {
    Name = var.vpc_name
  }
}

## Subnets
resource "aws_subnet" "public" {
  cidr_block              = var.public_subnet_cidr_block
  vpc_id                  = aws_vpc.vpc.id
  availability_zone       = "${var.region}${var.availability_zone}"
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.vpc_name}-public"
  }
}

resource "aws_security_group" "terraformansible-securitygroup" {
  name_prefix = "terraformansible"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = var.ingress_cidr_blocks
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.ingress_cidr_blocks
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = var.ingress_cidr_blocks
  }

}

# Route table
resource "aws_route_table" "route_table" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway.id
  }

  tags = {
    Name = "${var.vpc_name}-route-table"
  }
}

# IGW
resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.vpc_name}-internet-gateway"
  }
}

# Route table association
resource "aws_route_table_association" "route_table_association" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.route_table.id
}


# # Security Groups
# resource "aws_security_group" "bastion_ssh" {
#   name_prefix = "bastion-ssh-"
#   vpc_id      = aws_vpc.vpc.id

#   ingress {
#     from_port   = 80
#     to_port     = 80
#     protocol    = "tcp"
#     cidr_blocks = var.ingress_cidr_blocks
#   }

#   ingress {
#     from_port   = 22
#     to_port     = 22
#     protocol    = "tcp"
#     cidr_blocks = var.ingress_cidr_blocks
#   }

#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = var.ingress_cidr_blocks
#   }
# }


# resource "aws_subnet" "private_subnet_1" {
#   cidr_block = var.private_subnet_cidr_blocks[0]
#   vpc_id     = aws_vpc.vpc.id
# }

# resource "aws_subnet" "private_subnet_2" {
#   cidr_block = var.private_subnet_cidr_blocks[1]
#   vpc_id     = aws_vpc.vpc.id
# }