## web servers (2)
resource "aws_instance" "web" {
  count                  = "${length(module.vpc.aws_subnet_pub)}"
  subnet_id              = "${element(module.vpc.aws_subnet_pub, count.index)}"
  ami                    = data.aws_ami.aws-linux.id
  instance_type          = var.instance_type
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.allow_ssh.id]
  associate_public_ip_address = true

 connection {
    type        = "ssh"
    host        = self.public_ip
    user        = "ec2-user"
    private_key = file(var.private_key_path)
  }

  provisioner "remote-exec" {
    inline = [
      "sudo yum install nginx -y",
      "sudo service nginx start",
      "echo '<html><head><title>Welcome!</title><body>OpsSchool hw3!</body></head></html>' | sudo tee /usr/share/nginx/html/index.html"
    ]
  }

   tags = {
    Name          = "web-${count.index + 1}"
  }
}

## DB servers (2)
resource "aws_instance" "DB" {
  count                  = "${length(module.vpc.aws_subnet_prv)}"
  subnet_id              = "${element(module.vpc.aws_subnet_prv, count.index)}"
  ami                    = data.aws_ami.aws-linux.id
  instance_type          = var.instance_type
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.allow_ssh.id]
  # associate_public_ip_address = true

    tags = {
    Name        = "DB-${count.index + 1}"
  }
}