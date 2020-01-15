## eLB
resource "aws_elb" "elb3" {
  name            = "elb-3"
  security_groups = ["${aws_security_group.elb.id}"]
  subnets         = "${module.vpc.aws_subnet_pub}"

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  tags = { 
    Name = "elastic LB" 
  }
}

resource "aws_lb_cookie_stickiness_policy" "elb-stick" {
name                     = "sticky-elb"
load_balancer            = "${aws_elb.elb3.id}"
lb_port                  = 80
cookie_expiration_period = 60
}