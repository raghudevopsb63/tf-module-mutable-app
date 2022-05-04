resource "null_resource" "app-deploy" {
  count = var.SPOT_INSTANCE_COUNT + var.OD_INSTANCE_COUNT
  provisioner "remote-exec" {
    connection {
      host     = element(local.ALL_INSTANCE_PRIVATE_IPS, count.index)
      user     = jsondecode(data.aws_secretsmanager_secret_version.secrets.secret_string)["SSH_USERNAME"]
      password = jsondecode(data.aws_secretsmanager_secret_version.secrets.secret_string)["SSH_PASSWORD"]
    }
    inline = [
      "ansible-pull -U https://github.com/raghudevopsb63/ansible roboshop.yml  -e role_name=${var.COMPONENT} -e HOST=localhost -e APP_VERSION=1.0.0 -e ENV=${var.ENV}"
    ]
  }
}

