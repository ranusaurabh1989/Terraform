resource "oci_core_subnet" "workers_ad1" {
  availability_domain        = "${lookup(data.oci_identity_availability_domains.ADs.availability_domains[0],"name")}"
  cidr_block                 = "${cidrsubnet(var.vcn_cidr,var.newbits,var.subnets["workers_ad1"])}"
  display_name               = "workers subnet ad1"
  compartment_id             = "${var.compartment_ocid}"
  vcn_id                     = "${var.vcn_id}"
  route_table_id             = "${var.ig_route_id}"
  security_list_ids          = ["${oci_core_security_list.workers_seclist.id}"]
  dns_label                  = "w1"
  count                      = "${(var.ha["workers_ad1"] == "true") ? "1" : "0"}"
  prohibit_public_ip_on_vnic = false
}

resource "oci_core_subnet" "workers_ad2" {
  availability_domain        = "${lookup(data.oci_identity_availability_domains.ADs.availability_domains[1],"name")}"
  cidr_block                 = "${cidrsubnet(var.vcn_cidr,var.newbits,var.subnets["workers_ad2"])}"
  display_name               = "workers subnet ad2"
  compartment_id             = "${var.compartment_ocid}"
  vcn_id                     = "${var.vcn_id}"
  route_table_id             = "${var.ig_route_id}"
  security_list_ids          = ["${oci_core_security_list.workers_seclist.id}"]
  dns_label                  = "w2"
  count                      = "${(var.ha["workers_ad2"] == "true") ? "1" : "0"}"
  prohibit_public_ip_on_vnic = false
}

resource "oci_core_subnet" "workers_ad3" {
  availability_domain        = "${lookup(data.oci_identity_availability_domains.ADs.availability_domains[2],"name")}"
  cidr_block                 = "${cidrsubnet(var.vcn_cidr,var.newbits,var.subnets["workers_ad3"])}"
  display_name               = "workers subnet ad3"
  compartment_id             = "${var.compartment_ocid}"
  vcn_id                     = "${var.vcn_id}"
  route_table_id             = "${var.ig_route_id}"
  security_list_ids          = ["${oci_core_security_list.workers_seclist.id}"]
  dns_label                  = "w3"
  count                      = "${(var.ha["workers_ad3"] == "true") ? "1" : "0"}"
  prohibit_public_ip_on_vnic = false
}

resource "oci_core_subnet" "lb_ad1" {
  availability_domain        = "${lookup(data.oci_identity_availability_domains.ADs.availability_domains[0],"name")}"
  cidr_block                 = "${cidrsubnet(var.vcn_cidr,var.newbits,var.subnets["lb_ad1"])}"
  display_name               = "lb subnet ad1"
  compartment_id             = "${var.compartment_ocid}"
  vcn_id                     = "${var.vcn_id}"
  route_table_id             = "${var.ig_route_id}"
  security_list_ids          = ["${oci_core_security_list.lb_seclist.id}"]
  dns_label                  = "lb1"
  count                      = "${(var.ha["lb_ad1"] == "true") ? "1" : "0"}"
  prohibit_public_ip_on_vnic = false
}

resource "oci_core_subnet" "lb_ad2" {
  availability_domain        = "${lookup(data.oci_identity_availability_domains.ADs.availability_domains[1],"name")}"
  cidr_block                 = "${cidrsubnet(var.vcn_cidr,var.newbits,var.subnets["lb_ad2"])}"
  display_name               = "lb subnet ad2"
  compartment_id             = "${var.compartment_ocid}"
  vcn_id                     = "${var.vcn_id}"
  route_table_id             = "${var.ig_route_id}"
  security_list_ids          = ["${oci_core_security_list.lb_seclist.id}"]
  dns_label                  = "lb2"
  count                      = "${(var.ha["lb_ad2"] == "true") ? "1" : "0"}"
  prohibit_public_ip_on_vnic = false
}

resource "oci_core_subnet" "lb_ad3" {
  availability_domain        = "${lookup(data.oci_identity_availability_domains.ADs.availability_domains[2],"name")}"
  cidr_block                 = "${cidrsubnet(var.vcn_cidr,var.newbits,var.subnets["lb_ad3"])}"
  display_name               = "lb subnet ad3"
  compartment_id             = "${var.compartment_ocid}"
  vcn_id                     = "${var.vcn_id}"
  route_table_id             = "${var.ig_route_id}"
  security_list_ids          = ["${oci_core_security_list.lb_seclist.id}"]
  dns_label                  = "lb3"
  count                      = "${(var.ha["lb_ad3"] == "true") ? "1" : "0"}"
  prohibit_public_ip_on_vnic = false
}
