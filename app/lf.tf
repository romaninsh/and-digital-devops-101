variable "public_subnets" {}


resource "aws_alb" "main" {

  name            = var.name
  subnets         = var.public_subnets
  security_groups = [aws_security_group.main.id]
}

resource "aws_alb_target_group" "main" {
  name = var.name
  port = 80
  protocol = "HTTP"
  vpc_id = var.vpc
  target_type = "ip"
}

resource "aws_alb_listener" "main" {
  load_balancer_arn = aws_alb.main.arn
  port = 80
  protocol = "HTTP"

  default_action {
    target_group_arn = aws_alb_target_group.main.arn
    type = "forward"
  }
}

