variable "region" {
  default = "us-west-1"
}
variable "ngfw_name" {}
variable "global_tags" {}
variable "security_vpc_name" {}
variable "security_vpc_cidr" {}
variable "security_vpc_security_groups" {}
variable "security_vpc_subnets" {}
variable "vmseries" {}
variable "vmseries_version" {}
variable "security_vpc_routes_outbound_destin_cidrs" {}
variable "local_bootstrap_directory" {
  description = "local folder to copy to s3"
  type        = string
  default     = "ngfw-bootstrap-files"
}
variable "private_key_path" {
  default = "./private_key"
  type    = string
}

variable "new_ssh_key" {
}

variable "dirpath" {
  default     = "files"
  description = "Directory where ssh key will be saved"
}
