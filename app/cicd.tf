
resource "aws_ecr_repository" "cf_repo" {
  name = var.name
}


resource "aws_iam_user" "cf_access" {
  name = "cf-deploy-${var.name}"
}

resource "aws_iam_access_key" "cf_access" {
  user = aws_iam_user.cf_access.name
}

resource "aws_iam_user_policy_attachment" "cf_access" {
  user       = aws_iam_user.cf_access.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

resource "aws_iam_policy" "policy" {
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "Stmt1479146904000",
      "Effect": "Allow",
      "Action": [
        "ecs:DescribeServices",
        "ecs:DescribeTaskDefinition",
        "ecs:DescribeTasks",
        "ecs:ListClusters",
        "ecs:ListServices",
        "ecs:ListTasks",
        "ecs:RegisterTaskDefinition",
        "ecs:UpdateService"
      ],
      "Resource": [
        "*"
      ]
    }
  ]
}
EOF

}

output "AWS_ACCESS_KEY_ID" {
  value = aws_iam_access_key.cf_access.id
}

output "AWS_SECRET_ACCESS_KEY" {
  value = aws_iam_access_key.cf_access.secret
}
