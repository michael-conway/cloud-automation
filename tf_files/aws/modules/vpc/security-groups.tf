resource "aws_security_group" "local" {
  name        = "local"
  description = "security group that only allow internal tcp traffics"
  vpc_id      = "${var.aws_vpc_main_id}"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    #NIEHS - no peering cidr_blocks = ["${var.vpc_cidr_block}", "${var.peering_cidr}"]
    cidr_blocks = ["${var.vpc_cidr_block}"]
  }

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    #NIEHS - add eks_private block rule
    cidr_blocks = ["${var.eks_private_cidr_block}"]
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"

    # 54.224.0.0/12 logs.us-east-1.amazonaws.com
    #cidr_blocks = ["${var.vpc_cidr_block}", "54.224.0.0/12"]
    cidr_blocks = ["${var.vpc_cidr_block}"]
  }

  tags = {
    Environment  = "${var.vpc_name}"
    Organization = "${var.organization_name}"
    Name         = "${var.vpc_name}-local-sec-group"
  }
}


resource "aws_security_group" "out" {
  name        = "out"
  description = "security group that allow outbound traffics"
  vpc_id      = "${var.aws_vpc_main_id}"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Environment  = "${var.vpc_name}"
    Organization = "${var.organization_name}"
    Name         = "${var.vpc_name}-outbound-traffic"
  }
}


resource "aws_security_group" "proxy" {
  count                  = "${var.deploy_single_proxy ? 1 : 0 }"
  name        = "squid-proxy"
  description = "allow inbound tcp at 3128"
  vpc_id      = "${var.aws_vpc_main_id}"

  ingress {
    from_port   = 0
    to_port     = 3128
    protocol    = "TCP"
    cidr_blocks = ["${var.vpc_cidr_block}", "${var.peering_cidr}"]
  }

  tags = {
    Environment  = "${var.vpc_name}"
    Organization = "Basic Service"
  }
}
