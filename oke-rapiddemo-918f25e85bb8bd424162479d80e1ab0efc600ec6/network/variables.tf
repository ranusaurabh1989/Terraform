variable "compartment_ocid" {}

variable "tenancy_ocid" {}

variable "vcn_id" {}

variable "subnets" {
  type = "map"
}

variable "vcn_cidr" {}

variable "newbits" {}

variable "nat_route_ids" {
  type = "map"
}

variable "ha" {
  type = "map"
}

variable "ig_route_id" {}
