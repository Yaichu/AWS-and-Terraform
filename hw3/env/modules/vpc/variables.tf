variable "vpc_cidr_block" {
  default = "10.0.0.0/16"
}

variable "subnets_cidr_public" {
	default = ["10.0.1.0/24", "10.0.2.0/24"]
  type = "list"
}

variable "subnets_cidr_private" {
	default = ["10.0.10.0/24", "10.0.20.0/24"]
  type = "list"
}

variable "availability_zones" {
  default = ["us-east-1a", "us-east-1b"]
  type = "list"
}
