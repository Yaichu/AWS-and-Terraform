output "vpc-prv-subnet" {
  value = module.vpc.aws_subnet_prv
}

output "aws_instance_public_ip" {
  value = aws_instance.web.*.public_ip # public_dns
}

output "aws_instance_private_ip" {
 value = aws_instance.DB.*.public_ip
}

output "aws_security_group" {
  value = "aws_security_group.allow_ssh.*.id"
}

output "elb_dns_name" {
  value = aws_elb.elb3.dns_name
}
