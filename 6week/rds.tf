
data "aws_secretsmanager_secret" "env_secrets" {
  name = "RdsAdminCred"
  depends_on = [
    aws_secretsmanager_secret.RdsAdminCred
  ]
}
data "aws_secretsmanager_secret_version" "current_secrets" {
  secret_id = data.aws_secretsmanager_secret.env_secrets.id
}
resource "aws_db_instance" "default" {
  identifier        = "testdb"
  allocated_storage = 20
  storage_type      = "gp2"
  engine            = "mysql"
  engine_version    = "5.7.40"
  instance_class    = "db.t2.medium"
  name              = "mydb"

  username = jsondecode(data.aws_secretsmanager_secret_version.current_secrets.secret_string)["username"]
  password = jsondecode(data.aws_secretsmanager_secret_version.current_secrets.secret_string)["password"]
}
