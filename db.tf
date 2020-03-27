

resource "aws_db_subnet_group" "default" {
  subnet_ids = module.vpc.private_subnets
}

resource "aws_db_instance" "default" {
  allocated_storage    = 20
  storage_type         = "gp2"
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = var.prod ? "db.r5.large": "db.t2.micro"
  name                 = replace(var.project, "-", "_")
  username             = "root"
  password             = random_password.mysql-password.result
  parameter_group_name = "default.mysql5.7"
  multi_az             = var.prod
  db_subnet_group_name = aws_db_subnet_group.default.name
}
