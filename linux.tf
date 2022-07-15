data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}
# This VM will run all the packet core elements exept the UPF
resource "aws_instance" "ubuntu-epc" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"
  associate_public_ip_address = "false"
  subnet_id = module.vmseries_subnet_set["private-1"].subnets["us-west-1a"].id
  private_ip = "10.100.2.20"
  key_name = var.new_ssh_key
  security_groups = [module.secure_5g_vpc.security_group_ids["wide_open"]]
  source_dest_check = "false"

  tags = {
    Name = "ubuntu-epc"
  }
}

# This VM will run the UPF
resource "aws_instance" "ubuntu-upf" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"      # Used t3.small since t3.micro only supports 2 ENIs
  associate_public_ip_address = "false"
  subnet_id = module.vmseries_subnet_set["private-1"].subnets["us-west-1a"].id
  private_ip = "10.100.2.21"
  key_name = var.new_ssh_key
  security_groups = [module.secure_5g_vpc.security_group_ids["wide_open"]]
  source_dest_check = "false"

  tags = {
    Name = "ubuntu-upf"
  }
}

# This VM will run the UERANSIM software
resource "aws_instance" "ubuntu-ueransim" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"      # Used t3.small since t3.micro only supports 2 ENIs
  associate_public_ip_address = "false"
  subnet_id = module.vmseries_subnet_set["private-1"].subnets["us-west-1a"].id
  private_ip = "10.100.2.22"
  key_name = var.new_ssh_key
  security_groups = [module.secure_5g_vpc.security_group_ids["wide_open"]]

  tags = {
    Name = "ubuntu-ueransim"
  }
}

