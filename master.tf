
data "aws_region" "current" {}

data "aws_availability_zones" "available" {
  state = "available"
}

variable "project" {
  default = "romans"
}

variable "subdomain" {
  default = "aa.dekker-and.digital"
}

variable "prod" {
  type = bool
  default = false
}


locals {
  tags = {
    Project = var.project
  }
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = var.project
  cidr = "10.0.0.0/16"

  azs             = slice(data.aws_availability_zones.available.names, 0, 2)
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]

  enable_nat_gateway = true
  #enable_vpn_gateway = true

  tags = local.tags

}

resource "aws_ecs_cluster" "fargate" {
  name = var.project
}

module "app" {
  source = "./app"

  cluster = aws_ecs_cluster.fargate.id
  vpc = module.vpc.vpc_id
  #subnets = module.vpc.private_subnets
  subnets = module.vpc.public_subnets
  public_subnets = module.vpc.public_subnets

  rds_address = aws_db_instance.default.endpoint
  rds_password = random_password.mysql-password.result

  name = "myapp"
}

output "AWS_ACCESS_KEY_ID" {
  value = module.app.AWS_ACCESS_KEY_ID
}

output "AWS_SECRET_ACCESS_KEY" {
  value = module.app.AWS_SECRET_ACCESS_KEY
}

resource "random_password" "mysql-password" {
  length = 10
}

output "dns_nameservers" {
  value = aws_route53_zone.dns.name_servers
}

output "mysql-password" {
  value = random_password.mysql-password.result
}

output "region" {
  value = data.aws_region.current.name
}

output "zones" {
  value = slice(data.aws_availability_zones.available.names, 0, 2)
}