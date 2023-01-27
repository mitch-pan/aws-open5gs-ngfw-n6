# Generates a secure private key and encodes it as PEM.
resource "tls_private_key" "this" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

module "key_pair" {
  source          = "terraform-aws-modules/key-pair/aws"
  key_name        = var.new_ssh_key
  public_key      = tls_private_key.this.public_key_openssh
}

resource "local_file" "ngfw_private_key" {
  #filename = "${var.dirpath}/ngfw.pem"
  filename = join("", ["${var.dirpath}/", var.new_ssh_key])
  file_permission = "0400"
  content  = tls_private_key.this.private_key_pem
}