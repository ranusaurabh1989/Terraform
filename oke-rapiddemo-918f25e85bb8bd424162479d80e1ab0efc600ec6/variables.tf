# identity and access parameters
variable "tenancy_ocid" {
  description = "tenancy id"
}

variable "user_ocid" {
  description = "user ocid"
}

variable "compartment_ocid" {
  description = "compartment ocid"
}

variable "fingerprint" {
  description = "ssh fingerprint"
}

variable "private_key_path" {
  description = "/the/path/to/the/privatekey"
}

variable "public_key" {
  description = "the public key that matches the private key"
}

# general oci parameters

variable "region" {
  description = "region"
  default     = "us-ashburn-1"

  # List of regions: https://docs.us-phoenix-1.oraclecloud.com/Content/General/Concepts/regions.htm
}

variable "disable_auto_retries" {
  default = true
}

# network parameters
variable "label_prefix" {
  type    = "string"
  default = ""
}

variable "vcn_name" {
  description = "name of vcn"
}

variable "vcn_dns_name" {
  default = "ocioke"
}

variable "vcn_cidr" {
  default = "10.0.0.0/16"
}

variable "newbits" {
  description = "new mask for the subnet within the virtual network. use as newbits parameter for cidrsubnet function"
  default     = "8"
}

variable "subnets" {
  description = "zero-based index of the subnet when the network is masked with the newbit."
  type        = "map"

  default = {
    nat_ad1     = "11"
    nat_ad2     = "21"
    nat_ad3     = "31"
    lb_ad1      = "12"
    lb_ad2      = "22"
    lb_ad3      = "33"
    workers_ad1 = "13"
    workers_ad2 = "23"
    workers_ad3 = "33"
  }
}

# compute
variable "imageocids" {
  type = "map"

  default = {
    # https://docs.us-phoenix-1.oraclecloud.com/Content/Resources/Assets/OracleProvidedImageOCIDs.pdf

    us-phoenix-1   = "ocid1.image.oc1.phx.aaaaaaaaupbfz5f5hdvejulmalhyb6goieolullgkpumorbvxlwkaowglslq"
    us-ashburn-1   = "ocid1.image.oc1.iad.aaaaaaaajlw3xfie2t5t52uegyhiq2npx7bqyu4uvi2zyu3w3mqayc2bxmaa"
    eu-frankfurt-1 = "ocid1.image.oc1.eu-frankfurt1.aaaaaaaa7d3fsb6272srnftyi4dphdgfjf6gurxqhmv6ileds7ba3m2gltxq"
    uk-london-1    = "ocid1.image.oc1.uk-london1.aaaaaaaaa6h6gj6v4n56mqrbgnosskq63blyv2752g36zerymy63cfkojiiq"
  }
}

variable "nat_shape" {
  description = "shape of nat instance"
  default     = "VM.Standard1.1"
}

# ha

variable "ha" {
  description = "ADs to provision instances"
  type        = "map"

  default = {
    nat_ad1     = "false"
    nat_ad2     = "false"
    nat_ad3     = "false"
    lb_ad1      = "true"
    lb_ad2      = "true"
    lb_ad3      = "false"
    workers_ad1 = "true"
    workers_ad2 = "true"
    workers_ad3 = "true"
  }
}

# oke

variable "kubernetes_version" {
  description = "version of kubernetes to use"
  default     = "1.10.3"
}

variable "cluster_name" {
  description = "name of oke cluster"
  default     = "okecluster"
}

variable "dashboard_enabled" {
  description = "whether to enable kubernetes dashboard"
  default     = "true"
}

variable "tiller_enabled" {
  description = "whether to enable tiller"
  default     = "true"
}

variable "pods_cidr" {
  description = "This is the CIDR range used for IP addresses by your pods. A /16 CIDR is generally sufficient. This CIDR should not overlap with any subnet range in the VCN (it can also be outside the VCN CIDR range)."
  default     = "10.244.0.0/16"
}

variable "services_cidr" {
  description = "This is the CIDR range used by exposed Kubernetes services (ClusterIPs). This CIDR should not overlap with the VCN CIDR range."
  default     = "10.96.0.0/16"
}

variable "node_pool_name_prefix" {
  description = "prefix of node pool name"
  default     = "np"
}

variable "node_pool_node_image_name" {
  description = "name of image to use"
  default     = "Oracle-Linux-7.4"
}

variable "node_pool_node_shape" {
  description = "shape of worker nodes"
  default     = "VM.Standard1.4"
}

variable "node_pool_quantity_per_subnet" {
  description = "number of workers in node pool"
  default     = "1"
}

variable "node_pools" {
  description = "number of node pools"
  default     = "1"
}

variable "nodepool_topology" {
  description = "whether to use 2 ADs or 3ADs for the node pool. Possible values are 2 or 3 only"
  default     = "3"
}

# helm

variable "install_helm" {
  description = "whether to install helm on the nat"
  default     = "false"
}

variable "helm_version" {
  description = "version of helm to install"
  default     = "2.9.1"
}

# istio

variable "install_istio" {
  description = "whether to install istio on the cluster. Helm needs to be enabled"
  default     = "false"
}

variable "istio_version" {
  description = "version of istio to install"
  default     = "1.0.0"
}

variable "ingress_enabled" {
  default = "false"
}

variable "tracing_enabled" {
  default = "false"
}

variable "grafana_enabled" {
  default = "false"
}

variable "servicegraph_enabled" {
  default = "false"
}

variable "gateways_istio_ingressgateway_enabled" {
  default = "false"
}

variable "gateways_istio_egressgateway_enabled" {
  default = "false"
}

variable "galley_enabled" {
  default = "false"
}

variable "sidecarInjectorWebhook_enabled" {
  default = "false"
}

variable "mixer_enabled" {
  default = "false"
}

variable "prometheus_enabled" {
  default = "false"
}

variable "global_proxy_envoy_statsd_enabled" {
  default = "false"
}

variable "efk_enabled" {
  default = "false"
}

variable "install_bookinfo_sample" {
  default = "false"
}

variable "install_weavescope" {
  default = "false"
}

variable "open_sesame" {
  default = "false"
}
