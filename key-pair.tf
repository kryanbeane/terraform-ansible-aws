# Key pair logic
resource "tls_private_key" "key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "private_key" {
  content  = tls_private_key.key.private_key_pem
  filename = "terraformansiblekey.pem"
}
 
resource "aws_key_pair" "aws_key" {
  key_name   = "terraformansiblekey"
  public_key = tls_private_key.key.public_key_openssh
}