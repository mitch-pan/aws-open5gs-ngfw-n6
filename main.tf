# Configure the AWS Provider
provider "aws" {
  #version = "~> 3.0"
  region  = var.region
}

module "secure_5g_vpc" {
  source = "PaloAltoNetworks/vmseries-modules/aws//modules/vpc"
  version = "0.2.0"

  name                    = var.security_vpc_name
  cidr_block              = var.security_vpc_cidr
  security_groups         = var.security_vpc_security_groups
  create_internet_gateway = true
  enable_dns_hostnames    = true
  enable_dns_support      = true
  instance_tenancy        = "default"

}

module "vmseries_subnet_set" {
  source = "PaloAltoNetworks/vmseries-modules/aws//modules/subnet_set"
  version = "0.2.0"

  for_each = toset(distinct([for _, v in var.security_vpc_subnets : v.set]))

  name                = each.key
  vpc_id              = module.secure_5g_vpc.id
  has_secondary_cidrs = module.secure_5g_vpc.has_secondary_cidrs
  cidrs               = { for k, v in var.security_vpc_subnets : k => v if v.set == each.key }
}

module "vmseries-modules_vmseries" {
  source   = "PaloAltoNetworks/vmseries-modules/aws//modules/vmseries"
  version = "0.2.0"

  for_each = var.vmseries

  vmseries_version = var.vmseries_version
  name              = var.ngfw_name
  ssh_key_name      = var.new_ssh_key

  # Subnets are defined in security_vpc_subnets variable in terraform.tfvars
  interfaces = {
    ## Deploys 2 DP interfaces on the NGW, ethernet1/1, ethernet1/2
    mgmt = {
      device_index       = 0
      security_group_ids = [module.secure_5g_vpc.security_group_ids["vmseries_mgmt"]]
      source_dest_check  = true
      subnet_id          = module.vmseries_subnet_set["mgmt"].subnets[each.value.az].id
      create_public_ip   = true
      private_ips        = ["10.100.0.100"]
    },
    public = {
      device_index       = 1
      security_group_ids = [module.secure_5g_vpc.security_group_ids["wide_open"]]
      source_dest_check  = false
      subnet_id          = module.vmseries_subnet_set["public-1"].subnets[each.value.az].id
      create_public_ip   = true
      private_ips        = ["10.100.1.5"]
    },
    private = {
      device_index       = 2
      security_group_ids = [module.secure_5g_vpc.security_group_ids["wide_open"]]
      source_dest_check  = false
      subnet_id          = module.vmseries_subnet_set["private-1"].subnets[each.value.az].id
      create_public_ip   = false
      private_ips        = ["10.100.2.5"]
    }
  }

  bootstrap_options       = "${join("", tolist(["vmseries-bootstrap-aws-s3bucket=", module.panos-bootstrap.bucket_id]))}"
  iam_instance_profile    = module.panos-bootstrap.instance_profile_name

  tags = var.global_tags
}

module "vpc_route" {
  source   = "PaloAltoNetworks/vmseries-modules/aws//modules/vpc_route"

  for_each = {
    mgmt = {
      route_table_ids = module.vmseries_subnet_set["mgmt"].unique_route_table_ids
      next_hop_set    = module.secure_5g_vpc.igw_as_next_hop_set
      to_cidr         = "0.0.0.0/0"
    }
    public = {
      route_table_ids = module.vmseries_subnet_set["public-1"].unique_route_table_ids
      next_hop_set    = module.secure_5g_vpc.igw_as_next_hop_set
      to_cidr         = "0.0.0.0/0"
    }
    private = {
      route_table_ids = module.vmseries_subnet_set["private-1"].unique_route_table_ids
      next_hop_set = {
        type = "interface"
        id   = null
          ids  = {
            "us-west-1a" = module.vmseries-modules_vmseries["vmseries01"].interfaces["private"].id
          }
      }
      to_cidr         = "0.0.0.0/0"
    }
  }

  route_table_ids = each.value.route_table_ids
  next_hop_set    = each.value.next_hop_set
  to_cidr         = each.value.to_cidr
}


module "panos-bootstrap" {
  source = "PaloAltoNetworks/vmseries-modules/aws//modules/bootstrap"
  source_root_directory = var.local_bootstrap_directory

  #hostname           = "my-firewall"
  #plugin-op-commands = "dhcp-client;hostname=vms01"

}


