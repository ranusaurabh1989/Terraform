variable "compartment_ocid" {}

variable "tenancy_ocid" {}

variable "user_ocid" {}

variable "private_key_path" {}

variable "ha" {
  type = "map"
}

variable "nat_public_ips" {
  type = "map"
}

variable "vcn_id" {}

variable "cluster_subnets" {
  type = "map"
}

variable "cluster_kubernetes_version" {}

variable "cluster_name" {}

variable "cluster_options_add_ons_is_kubernetes_dashboard_enabled" {}

variable "cluster_options_add_ons_is_tiller_enabled" {}

variable "cluster_options_kubernetes_network_config_pods_cidr" {}

variable "cluster_options_kubernetes_network_config_services_cidr" {}

variable "node_pool_ssh_public_key" {}

variable "node_pool_name_prefix" {}

variable "node_pool_node_image_name" {}

variable "node_pool_node_shape" {}

variable "node_pool_quantity_per_subnet" {}

variable "node_pools" {}

variable "nodepool_topology" {}

variable "cluster_kube_config_expiration" {
  default = 2592000
}

variable "cluster_kube_config_token_version" {
  default = "1.0.0"
}

variable "install_helm" {}

variable "helm_version" {}

variable "install_istio" {}

variable "istio_version" {}

variable "ingress_enabled" {
  default = "false"
}

variable "tracing_enabled" {
  default = "true"
}

variable "grafana_enabled" {
  default = "true"
}

variable "servicegraph_enabled" {
  default = "true"
}

variable gateways_istio_ingressgateway_enabled {
  default = "false"
}

variable gateways_istio_egressgateway_enabled {
  default = "true"
}

variable galley_enabled {
  default = "true"
}

variable sidecarInjectorWebhook_enabled {
  default = "true"
}

variable mixer_enabled {
  default = "true"
}

variable prometheus_enabled {
  default = "true"
}
variable global_proxy_envoy_statsd_enabled {
  default = "true"
}

variable "efk_enabled" {
  default = "true"
}

variable "install_bookinfo_sample" {
  default = "true"
}

variable "install_weavescope" {
  default = "true"
}
variable "open_sesame" {
  default = "false"
}