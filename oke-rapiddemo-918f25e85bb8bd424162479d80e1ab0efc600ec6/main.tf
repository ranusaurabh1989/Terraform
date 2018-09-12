module "vcn" {
  source = "git::ssh://git@orahub.oraclecorp.com/ali.mukadam/baseoci.git?ref=nokc"

  # identity 
  compartment_ocid = "${var.compartment_ocid}"
  tenancy_ocid     = "${var.tenancy_ocid}"
  user_ocid        = "${var.user_ocid}"
  fingerprint      = "${var.fingerprint}"
  public_key       = "${var.public_key}"
  private_key_path = "${var.private_key_path}"

  # networking
  vcn_name     = "${var.vcn_name}"
  region       = "${var.region}"
  vcn_dns_name = "${var.vcn_dns_name}"
  label_prefix = "${var.label_prefix}"
  vcn_cidr     = "${var.vcn_cidr}"
  newbits      = "${var.newbits}"
  subnets      = "${var.subnets}"

  # ha
  ha = "${var.ha}"
}

# additional networking for oke
module "network" {
  source           = "./network"
  compartment_ocid = "${var.compartment_ocid}"
  tenancy_ocid     = "${var.tenancy_ocid}"
  vcn_id           = "${module.vcn.vcn_id}"
  ig_route_id      = "${module.vcn.ig_route_id}"
  subnets          = "${var.subnets}"
  vcn_cidr         = "${var.vcn_cidr}"
  newbits          = "${var.newbits}"
  nat_route_ids    = "${module.vcn.nat_route_ids}"
  ha               = "${var.ha}"
}

# cluster creation for oke
module "oke" {
  source           = "./oke"
  compartment_ocid = "${var.compartment_ocid}"
  tenancy_ocid     = "${var.tenancy_ocid}"
  user_ocid        = "${var.user_ocid}"
  ha               = "${var.ha}"
  nat_public_ips   = "${module.vcn.nat_public_ips}"
  vcn_id           = "${module.vcn.vcn_id}"
  private_key_path = "${var.private_key_path}"

  # oke cluster
  cluster_subnets                                         = "${module.network.subnet_ids}"
  cluster_kubernetes_version                              = "${var.kubernetes_version}"
  cluster_name                                            = "${var.cluster_name}"
  cluster_options_add_ons_is_kubernetes_dashboard_enabled = "${var.dashboard_enabled}"
  cluster_options_add_ons_is_tiller_enabled               = "${var.tiller_enabled}"
  cluster_options_kubernetes_network_config_pods_cidr     = "${var.pods_cidr}"
  cluster_options_kubernetes_network_config_services_cidr = "${var.services_cidr}"

  # node pools
  node_pool_ssh_public_key      = "${var.public_key}"
  node_pool_name_prefix         = "${var.node_pool_name_prefix}"
  node_pool_node_image_name     = "${var.node_pool_node_image_name}"
  node_pool_node_shape          = "${var.node_pool_node_shape}"
  node_pool_quantity_per_subnet = "${var.node_pool_quantity_per_subnet}"
  node_pools                    = "${var.node_pools}"
  nodepool_topology             = "${var.nodepool_topology}"

  # weavescope
  install_weavescope = "${var.install_weavescope}"

  # helm
  install_helm = "${var.install_helm}"
  helm_version = "${var.helm_version}"

  # Istio
  install_istio = "${var.install_istio}"
  istio_version = "${var.istio_version}"

  # Istio options
  ingress_enabled                       = "${var.ingress_enabled}"
  tracing_enabled                       = "${var.tracing_enabled}"
  grafana_enabled                       = "${var.grafana_enabled}"
  servicegraph_enabled                  = "${var.servicegraph_enabled}"
  gateways_istio_ingressgateway_enabled = "${var.gateways_istio_ingressgateway_enabled}"
  gateways_istio_egressgateway_enabled  = "${var.gateways_istio_egressgateway_enabled}"
  galley_enabled                        = "${var.galley_enabled}"
  sidecarInjectorWebhook_enabled        = "${var.sidecarInjectorWebhook_enabled}"
  mixer_enabled                         = "${var.mixer_enabled}"
  prometheus_enabled                    = "${var.prometheus_enabled}"
  global_proxy_envoy_statsd_enabled     = "${var.global_proxy_envoy_statsd_enabled}"
  efk_enabled                           = "${var.efk_enabled}"
  install_bookinfo_sample               = "${var.install_bookinfo_sample}"
  open_sesame                           = "${var.open_sesame}"
}
