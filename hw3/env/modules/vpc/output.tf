output "aws_subnet_prv" {
  value = aws_subnet.prv-subnet.*.id
}
output "aws_subnet_pub" {
  value = aws_subnet.pub-subnet.*.id
}

output "aws_vpc_id" {
  value = aws_vpc.vpc-1.id
}
