# worker security checklist
resource "oci_core_security_list" "workers_seclist" {
  compartment_id = "${var.compartment_ocid}"
  display_name   = "workers security list"
  vcn_id         = "${var.vcn_id}"

  egress_security_rules = [
    {
      protocol    = "all"
      destination = "${var.vcn_cidr}"
      stateless   = "true"
    },
    {
      protocol    = "all"
      destination = "0.0.0.0/0"
      stateless   = "false"
    },
  ]

  ingress_security_rules = [
    {
      # rules 1 - 3
      protocol  = "all"
      source    = "${var.vcn_cidr}"
      stateless = "true"
    },
    {
      # rule 4
      protocol  = "1"
      source    = "0.0.0.0/0"
      stateless = "false"
    },
    {
      # rule 5
      protocol  = "6"
      source    = "130.35.0.0/16"
      stateless = "false"

      tcp_options {
        "max" = 22
        "min" = 22
      }
    },
    {
      # rule 6
      protocol  = "6"
      source    = "138.1.0.0/17"
      stateless = "false"

      tcp_options {
        "max" = 22
        "min" = 22
      }
    },
    {
      # rule 7
      protocol  = "6"
      source    = "0.0.0.0/0"
      stateless = "false"

      tcp_options {
        "max" = 22
        "min" = 22
      }
    },
    {
      # rule 8
      protocol  = "6"
      source    = "0.0.0.0/0"
      stateless = "false"

      tcp_options {
        "max" = 32767
        "min" = 3000
      }
    },
  ]
}

# load balancer security checklist
resource "oci_core_security_list" "lb_seclist" {
  compartment_id = "${var.compartment_ocid}"
  display_name   = "load balancer security list"
  vcn_id         = "${var.vcn_id}"

  egress_security_rules = [{
    protocol    = "all"
    destination = "0.0.0.0/0"
    stateless   = "true"
  }]

  ingress_security_rules = [
    {
      protocol  = "6"
      source    = "0.0.0.0/0"
      stateless = "true"
    },
  ]
}
