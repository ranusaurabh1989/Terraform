resource "oci_containerengine_cluster" "k8s_cluster" {
  compartment_id     = "${var.compartment_ocid}"
  kubernetes_version = "${var.cluster_kubernetes_version}"
  name               = "${var.cluster_name}"
  vcn_id             = "${var.vcn_id}"

  options {
    service_lb_subnet_ids = ["${var.cluster_subnets["lb_ad1"]}", "${var.cluster_subnets["lb_ad2"]}"]

    add_ons {
      is_kubernetes_dashboard_enabled = "${var.cluster_options_add_ons_is_kubernetes_dashboard_enabled}"
      is_tiller_enabled               = "${var.cluster_options_add_ons_is_tiller_enabled}"
    }

    kubernetes_network_config {
      pods_cidr     = "${var.cluster_options_kubernetes_network_config_pods_cidr}"
      services_cidr = "${var.cluster_options_kubernetes_network_config_services_cidr}"
    }
  }
}
