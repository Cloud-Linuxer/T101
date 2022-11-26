variable "RdsAdminCred" {
  default = {
    username = "$USERNAME"
    password = "$PASSWORD"
  }
  type = map(string)
}

resource "aws_secretsmanager_secret" "RdsAdminCred" {
  name = "RdsAdminCred"
}
resource "aws_secretsmanager_secret_version" "RdsAdminCred" {
  secret_id     = aws_secretsmanager_secret.RdsAdminCred.id
  secret_string = jsonencode(var.RdsAdminCred)
}
