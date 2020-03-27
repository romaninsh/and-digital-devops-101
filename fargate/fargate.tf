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

