variable "name" {
  default = "testing"
}

variable "subnets" {
  type = list(string)
}

variable "vpc" {}

resource "aws_ecs_cluster" "fargate" {
  name = var.name
}


module "app_container_definition" {
  source = "git::https://github.com/cloudposse/terraform-aws-ecs-container-definition.git?ref=tags/0.21.0"
  container_name = var.name
  container_image              = "tutum/hello-world"
  container_cpu                = 512
  container_memory             = 1024
  essential                    = true
  readonly_root_filesystem     = false
  port_mappings                = [
    {
      containerPort            = 80
      hostPort                 = 80
      protocol                 = "tcp"
    }
  ]
}


resource "aws_ecs_task_definition" "app" {
  container_definitions = "[${module.app_container_definition.json_map}]"
  family = "app"
  cpu = 512
  memory = 1024
  requires_compatibilities = ["FARGATE"]
  execution_role_arn = aws_iam_role.main.arn
  network_mode             = "awsvpc"
}


resource "aws_iam_role" "main" {
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_policy" "main" {
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ecr:GetAuthorizationToken",
        "ecr:BatchCheckLayerAvailability",
        "ecr:GetDownloadUrlForLayer",
        "ecr:BatchGetImage",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "main" {
  policy_arn = aws_iam_policy.main.arn
  role = aws_iam_role.main.name
}


resource "aws_security_group" "main" {
  name        = var.name
  vpc_id      = var.vpc

  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_ecs_service" "main" {
  name            = var.name
  cluster         = aws_ecs_cluster.fargate.id
  task_definition = aws_ecs_task_definition.app.arn
  desired_count   = 1
  launch_type     = "FARGATE"
  #iam_role        = aws_iam_role.main.arn

  network_configuration {
    assign_public_ip = true
    security_groups = [aws_security_group.main.id]
    subnets         = var.subnets
  }


//  load_balancer {
//    target_group_arn = aws_alb_target_group.main.arn
//    container_name   = var.name
//    container_port   = 80
//  }
//


//  depends_on = [
//    aws_alb_listener.main
//  ]
}


