output "nat_public_ips" {
  value = "${module.vcn.nat_public_ips}"
}

output "ssh_to_nats" {
  value = "${module.vcn.ssh_to_nats}"
}
