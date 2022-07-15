output "FirewallManagementSSHAccess" {
  value = join("", ["ssh -i ", local_file.ngfw_private_key.filename, " admin@", module.vmseries-modules_vmseries["vmseries01"].public_ips["mgmt"]] )
}

output "Ubuntu-EPC-Server-SSH-Access" {
  value = join("", ["ssh -i ", local_file.ngfw_private_key.filename, " ubuntu@", module.vmseries-modules_vmseries["vmseries01"].public_ips["public"], " -p 222"]   )
}

output "Ubuntu-UPF-Server-SSH-Access" {
  value = join("", ["ssh -i ", local_file.ngfw_private_key.filename, " ubuntu@", module.vmseries-modules_vmseries["vmseries01"].public_ips["public"], " -p 223"]   )
}

output "Ubuntu-UERANSIM-Server-SSH-Access" {
  value = join("", ["ssh -i ", local_file.ngfw_private_key.filename, " ubuntu@", module.vmseries-modules_vmseries["vmseries01"].public_ips["public"], " -p 224"]   )
}

output "WebUIAccess" {
  value = join("", ["http://", module.vmseries-modules_vmseries["vmseries01"].public_ips["public"], ":3000"]   )
}

output "bucket_id" {
  value       = module.panos-bootstrap.bucket_name
  description = "ID of created bucket."
}