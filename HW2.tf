variable "aws_access_key" {
    default = ""
}
variable "aws_secret_key" {
    default = ""  
}
variable "private_key_path" {
    default = ""
}
variable "key_name" {
    default = ""
}
variable "instance_count" {
  default = "2"
}
variable "region" {
  default = "us-east-1"
}
variable "cidr_block" {
  default = "10.0.0.0/16"
}
variable "subnet_count" {
    default = 2
}
variable "availability_zones" {
  default = ["us-east-1a", "us-east-1b"]
  type = "list"
}

provider "aws" {
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  region     = var.region
}

data "aws_ami" "aws-linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn-ami-hvm*"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_vpc" "vpc-1" {
    cidr_block = var.cidr_block
    tags = {
       Name = "vpc-1"
   }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = "${aws_vpc.vpc-1.id}"

  tags = {
    Name = "igw"
  }
}

resource "aws_subnet" "pub-subnet1" {
  #count      = "${var.subnet_count}"
  vpc_id     = "${aws_vpc.vpc-1.id}"
  # subnet_id     = "${aws_vpc.pub-subnet.id}"
  cidr_block = "10.0.1.0/24"
  availability_zone = "${var.availability_zones[0]}"
  # availability_zone = "${var.availability_zones[count.index]}"
  depends_on = ["aws_internet_gateway.gw"]

  tags = {
    Name = "public subnet1"
  }
}

resource "aws_subnet" "pub-subnet2" {
  vpc_id     = "${aws_vpc.vpc-1.id}"
  cidr_block = "10.0.2.0/24"
  availability_zone = "${var.availability_zones[1]}"
  depends_on = ["aws_internet_gateway.gw"]
  tags = {
    Name = "public subnet2"
  }
}

resource "aws_subnet" "prv-subnet3" {
  vpc_id     = "${aws_vpc.vpc-1.id}"
  cidr_block = "10.0.10.0/24"
  availability_zone = "${var.availability_zones[0]}"
  depends_on = ["aws_internet_gateway.gw"]
  tags = {
    Name = "private subnet3"
  }
}

resource "aws_subnet" "prv-subnet4" {
  vpc_id     = "${aws_vpc.vpc-1.id}"
  cidr_block = "10.0.20.0/24"
  availability_zone = "${var.availability_zones[1]}"
  depends_on = ["aws_internet_gateway.gw"]
  tags = {
    Name = "private subnet4"
  }
}

resource "aws_eip" "Eip1" {
  depends_on = ["aws_internet_gateway.gw"]
  vpc      = true
}

resource "aws_eip" "Eip2" {
  depends_on = ["aws_internet_gateway.gw"]
  vpc      = true
}

resource "aws_nat_gateway" "ngw1" {
   allocation_id = "${aws_eip.Eip1.id}"
   subnet_id     = "${aws_subnet.pub-subnet1.id}"
    tags = {
      Name = "NAT gw1"
    }
}

resource "aws_nat_gateway" "ngw2" {
   allocation_id = "${aws_eip.Eip2.id}"
   subnet_id     = "${aws_subnet.pub-subnet2.id}"
    tags = {
      Name = "NAT gw2"
    }
}

resource "aws_route_table" "public" {
  vpc_id = "${aws_vpc.vpc-1.id}"

  tags = {
    Name = "public RTB"
  }
}

resource "aws_route_table" "private1" {
  vpc_id = "${aws_vpc.vpc-1.id}"

  tags = {
    Name = "private1 RTB"
  }
}

resource "aws_route_table" "private2" {
  vpc_id = "${aws_vpc.vpc-1.id}"

  tags = {
    Name = "private2 RTB"
  }
}

resource "aws_route_table_association" "public" {
  #   subnet_id      = "${element(aws_subnet.public.*.id, count.index)}"
  subnet_id      = "${aws_subnet.pub-subnet1.id}"
  route_table_id = "${aws_route_table.public.id}"
}

resource "aws_route_table_association" "public2" {
  subnet_id      = "${aws_subnet.pub-subnet2.id}"
  route_table_id = "${aws_route_table.public.id}"
}

resource "aws_route_table_association" "private1" {
  subnet_id      = "${aws_subnet.prv-subnet3.id}"
  route_table_id = "${aws_route_table.private1.id}"
}

resource "aws_route_table_association" "private2" {
  subnet_id      = "${aws_subnet.prv-subnet4.id}"
  route_table_id = "${aws_route_table.private2.id}"
}

resource "aws_security_group" "allow_ssh" {
  name        = "nginx_demo"
  description = "Allow ports for nginx demo"
  vpc_id      = "${aws_vpc.vpc-1.id}"
  

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "web1" {
  # count                  = "${var.instance_count}"
  subnet_id              = aws_subnet.pub-subnet1.id #[count.index].id
  ami                    = data.aws_ami.aws-linux.id
  instance_type          = "t2.micro"
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.allow_ssh.id]

  tags = {
    Name        = "web1" #-${count.index + 1}"
    owner       = "760579235815"
    server_name = "yael"
    purpose     = "learning"
  }

 connection {
    type        = "ssh"
    host        = self.public_ip
    user        = "ec2-user"
    private_key = file(var.private_key_path)
  }

#     provisioner "remote-exec" {
#     inline = [
#       "sudo yum install nginx -y",
#       "sudo service nginx start",
#     ]
#   }
}

resource "aws_instance" "web2" {
  # count                  = "${var.instance_count}"
  subnet_id              = aws_subnet.pub-subnet2.id #[count.index].id
  ami                    = data.aws_ami.aws-linux.id
  instance_type          = "t2.micro"
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.allow_ssh.id]

  tags = {
    Name        = "web2" #-${count.index + 1}"
    owner       = "760579235815"
    server_name = "yael"
    purpose     = "learning"
  }
    
 connection {
    type        = "ssh"
    host        = self.public_ip
    user        = "ec2-user"
    private_key = file(var.private_key_path)
  }

#   provisioner "remote-exec" {
#     inline = [
#       "sudo yum install nginx -y",
#       "sudo service nginx start",
#     ]
#   }
}

resource "aws_instance" "DB1" {
  # count                  = "${var.instance_count}"
  subnet_id              = aws_subnet.prv-subnet3.id #[count.index].id
  ami                    = data.aws_ami.aws-linux.id
  instance_type          = "t2.micro"
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.allow_ssh.id]

  tags = {
    Name        = "DB1" #-${count.index + 1}"
    owner       = "760579235815"
    server_name = "yael"
    purpose     = "learning"
  }

  connection {
    type        = "ssh"
    host        = self.public_ip
    user        = "ec2-user"
    private_key = file(var.private_key_path)

  }

#   provisioner "remote-exec" {
#     inline = [
#       "sudo yum install nginx -y",
#       "sudo service nginx start",
#     ]
#   }
}

resource "aws_instance" "DB2" {
  # count                  = "${var.instance_count}"
  subnet_id              = aws_subnet.prv-subnet4.id #[count.index].id
  ami                    = data.aws_ami.aws-linux.id
  instance_type          = "t2.micro"
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.allow_ssh.id]

  tags = {
    Name        = "DB2" #-${count.index + 1}"
    owner       = "760579235815"
    server_name = "yael"
    purpose     = "learning"
  }

  connection {
    type        = "ssh"
    host        = self.public_ip
    user        = "ec2-user"
    private_key = file(var.private_key_path)

  }

#   provisioner "remote-exec" {
#     inline = [
#       "sudo yum install nginx -y",
#       "sudo service nginx start",
#     ]
#   }
}

resource "aws_lb" "lb" {
  name               = "LB"
  internal           = false
  load_balancer_type = "application"
  subnets            = ["${aws_subnet.pub-subnet1.id}","${aws_subnet.pub-subnet2.id}"]

  tags = {
    Environment = "dev"
  }
}

output "aws_instance_public_dns" {
  value = [aws_lb.lb.dns_name]
}
