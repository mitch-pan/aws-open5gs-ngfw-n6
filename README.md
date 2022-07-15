# aws-open5gs-ngfw-n6
This repository contains terraoform templates to deploy an AWS VPC with three subnets and four VMs, one of which 
is a Palo Alto Networks NGFW residing on the 5G N6 interface.  Three Ubuntu VMs are
deployed in the "private" subnet to support the open5GS packet core and the UERANSIM simulator.  The steps
to configure the open5GS cor and UERANSIM are included [here](open5gs_ueransim.md).

The Palo Alto Networks VM is [boostrapped](https://docs.paloaltonetworks.com/vm-series/10-2/vm-series-deployment/bootstrap-the-vm-series-firewall/bootstrap-the-vm-series-firewall-in-aws) (using Palo Alto Networks terraform modules) so that it spins up fully configured for allowing secure SSH access
into the Ubuntu servers, as well as inspection and NAT of outbound traffic from the packet core.

## Deployment Steps

1. Download this repo

    `git clone https://github.com/mitch-pan/aws-open5gs-ngfw-n6.git`
2. View / modify variables

    Go through the terraform.tfvars file to ensure you are happy with the Region, VPC name, subet names, etc.  If you 
    aren't sure, just leave them as is. By default it will deploy to us-west-1.
3. Run through terraform commands

    `terraform init`
    `terraform plan`
    Make sure it all looks good, the region is right, the VPC name is right, etc.
    `terraform apply`
 
4. Connect to Ubuntu Instances

    When the terraform templates have been run, there will be several outputs at the end indicating how
    to connect to the different Ubuntu servers, and the NGFW.  When the NGFW was deployed it was bootstrapped
    with a configuration that has destination NAT enabled to send inbound SSH traffic on certain ports (222,
    223 and 224) to certain Ubuntu images.  From here you should read the [open5gs_ueransim](open5gs_ueransim.md) 
    README for the remainder of the setup steps.