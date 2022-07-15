# General
region = "us-west-1"
ngfw_name   = "secure_5G_ngfw"

global_tags = {
  ManagedBy   = "Terraform"
  Application = "Palo Alto Networks VM-Series NGFW"
}

# VPC
security_vpc_name = "secure_5g_vpc"
security_vpc_cidr = "10.100.0.0/16"

# Subnets
security_vpc_subnets = {
  # Do not modify value of `set=`, it is an internal identifier referenced by main.tf in module
  # Make sure AZ's match region!
  "10.100.0.0/24" = { az = "us-west-1a", set = "mgmt" }
  "10.100.1.0/24" = { az = "us-west-1a", set = "public-1" }
  "10.100.2.0/24" = { az = "us-west-1a", set = "private-1" }
}

# Security Groups
security_vpc_security_groups = {
  vmseries_mgmt = {
    name = "vmseries_mgmt"
    rules = {
      all_outbound = {
        description = "Permit All traffic outbound"
        type        = "egress", from_port = "0", to_port = "0", protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
      }
      https = {
        description = "Permit HTTPS"
        type        = "ingress", from_port = "443", to_port = "443", protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"] # TODO: update here
      }
      ssh = {
        description = "Permit SSH"
        type        = "ingress", from_port = "22", to_port = "22", protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"] # TODO: update here
      }
    }
  },
  wide_open = {
    name = "wide_open"
    rules = {
      all_outbound = {
        description = "Permit All traffic outbound"
        type = "egress",
        from_port = "0",
        to_port = "0",
        protocol = "-1"
        cidr_blocks = [
          "0.0.0.0/0"]
      }
      all_inbound = {
        description = "Permit All traffic inbound"
        type = "ingress",
        from_port = "0",
        to_port = "0",
        protocol = "-1"
        cidr_blocks = [
          "0.0.0.0/0"]
      }
    }
  }
}

# VM-Series
new_ssh_key      = "open5gs-testing-key"

vmseries_version = "10.2.2"
vmseries = {
  vmseries01 = { az = "us-west-1a" }
}

#bootstrap_options = "plugin-op-commands=type=dhcp-client;hostname=vms01"

# Routes
security_vpc_routes_outbound_destin_cidrs = ["0.0.0.0/0"]
