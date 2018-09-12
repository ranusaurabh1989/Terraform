# oke

[API signing]: https://docs.us-phoenix-1.oraclecloud.com/Content/API/Concepts/apisigningkey.htm
[baseoci]:https://orahub.oraclecorp.com/ali.mukadam/baseoci
[cidrsubnet]:http://blog.itsjustcode.net/blog/2017/11/18/terraform-cidrsubnet-deconstructed/
[elasticsearch]:https://www.elastic.co/products/elasticsearch
[example network resource configuration]:https://docs.us-phoenix-1.oraclecloud.com/Content/ContEng/Concepts/contengnetworkconfigexample.htm
[fluentd]:https://www.fluentd.org/
[grafana]:https://grafana.com/
[helm]:https://www.helm.sh/
[istio]:https://istio.io/
[jaeger]:https://www.jaegertracing.io/
[kiali]:https://www.kiali.io/
[kibana]:https://www.elastic.co/products/kibana
[kubernetes]: https://kubernetes.io/
[networks]:https://erikberg.com/notes/networks.html
[oci]: https://cloud.oracle.com/cloud-infrastructure
[oci provider]: https://github.com/oracle/terraform-provider-oci/releases
[oke]: https://docs.us-phoenix-1.oraclecloud.com/Content/ContEng/Concepts/contengoverview.htm
[postman]: https://www.getpostman.com/
[prometheus]:https://prometheus.io/
[terraform]: https://www.terraform.io
[weavescope]: https://www.weave.works/oss/scope/
# Terraform Base Module for [Oracle Container Engine][oke]

## About

The Terraform OKE Module Installer for Oracle Cloud Infrastructure provides a Terraform module that provisions the necessary resources for [Oracle Container Engine][oke]. This is based on the [Example Network Resource Configuration][example network resource configuration].
It leverages [Base OCI][baseoci] to create the basic infrastructure (VCNs, subnets, security lists etc), cluster and node pools. Optionally, it can also install the [Istio][istio] service mesh.

## Features

- Configurable subnet masks and sizes. This helps you:
    - limit your blast radius
    - avoid the overlapping subnet problem, especially if you need to make a hybrid deployment
    - plan your scalability, HA and failover capabilities
- Optional co-located and pre-configured public bastion instances across all 3 ADs. This helps execute kubectl commands faster. The bastion instance has the following configurable features:
    - oci-cli installed, upgraded and pre-configured
    - kubectl installed and pre-configured
    - kubeconfig generation
    - [helm][helm] installed and pre-configured (see helm below)
    - convenient output of how to access the bastion instances
    - choice of AD location for the bastion instance(s) to avoid problems with service limits/shapes, particularly when using trial accounts

> N.B. 'NAT' and 'Bastion' are used interchangeably here as the NAT instance is configured to do both. This avoids using an extra compute just for the other purpose and it's useful for demo/trial accounts as well as speeding up demos. The 'saved' instance can then be used for other purposes e.g. Jenkins

- Automatic creation of [OKE pre-requisites][example network resource configuration]:
    - 3 worker subnets with their corresponding security lists, ingress and egress rules
    - 3 load balancer subnets with their corresponding security lists, ingress and egress rules
    - Possiblity to expand by adding more subnets
- Automatic creation of an OKE cluster with the following configurable options:
    - cluster name
    - [Kubernetes][kubernetes] version
    - Kubernetes addons such as dashboard and helm (tiller)
    - pods and services cidr
- Automatic node pool creation with the following configurable options:
    - number of node pools to be created
    - choice of node pool topology i.e. whether to make a node pool span 2 or 3 subnets (effectively make a nodepool span 2 or 3 ADs within a region)
    - number of worker nodes per subnets
    - fair distribution of node pools across the ADs in the region when choosing 2 subnets topology so that node pools are not concentrated in some ADs only
    - programmable node pool prefix
    - configurable worker node shape
- kubeconfig:
    - automatic generation of kubeconfig on the bastion instances and set to default location (/home/opc/.kube/config) so there's no need to explicitly set KUBECONFIG variable
    - automatic generation of kubeconfig locally under the generated folder
- [helm][helm]:
    - optional installation and configuration of helm on the bastion instances
    - choice of helm version
    - upgrade of the running tiller on the cluster
- [Istio][istio]:
    - optional installation of Istio using helm. This makes it possible to turn on and off Istio features when desired
    - choice of Istio version. This makes it easier to install or upgrade to later versions of Istio when available
    - configurable installation of Istio features such as:
        - automatic sidecar injection
        - performance monitoring ([Prometheus][prometheus])
        - Istio performance dashboard ([Grafana][grafana])
        - log analytics ([Elasticsearch][elasticsearch], [Fluentd][fluentd], [Kibana][kibana])
        - distributed tracing ([Jaeger][jaeger])
        - service graph
        - service mesh observability ([Kiali][kiali]) (this is turned off at the moment until it's Docker image is available)
    - Bookinfo sample demo pre-installed
- Sesame: a utility script that creates an ssh tunnel and allows access to Istio's telemetry services. It's useful when port forwarding is restricted on certain networks/wifis e.g. hotels, airports, customers

## Pre-reqs

1. Download and install [Terraform][terraform] (v0.11+).
2. Download and install the [OCI Terraform Provider][oci provider]. You need at least v2.1.16 to provision OKE.
3. [Configure your OCI account to use Terraform](https://docs.cloud.oracle.com/iaas/Content/API/SDKDocs/terraformgetstarted.htm?tocpath=Developer%20Tools%20%7CTerraform%20Provider%7C_____1)

## Environment variables

> Until this repo and the [dependent baseoci module][baseoci] is published externally, _**ensure that you are on Oracle network when you execute the commands until you have finished running terraform init**_.

```
$ export http_proxy=http://<address_of_your_office_proxy>.com:80/
$ export https_proxy=http://<address_of_your_office_proxy>:80/
$ export TF_VAR_private_key=$(cat ~/.ssh/id_rsa.pem)
$ export TF_VAR_public_key=$(cat ~/.ssh/id_rsa.pub)

##$ export http_proxy=http://www-proxy.idc.oracle.com:80/
##$ export https_proxy=http://www-proxy.idc.oracle.com:80/
##$ export TF_VAR_private_key=$(cat ~/.ssh/id_rsa.pem)
##$ export TF_VAR_public_key=$(cat ~/.ssh/id_rsa.pub)


```

## Quickstart

```
$ git clone git@orahub.oraclecorp.com:ali.mukadam/oke.git
$ git checkout rapiddemo
$ cp terraform.tfvars.example terraform.tfvars
```
* Set mandatory variables tenancy_ocid, user_ocid, compartment_ocid, fingerprint in terraform.tfvars

* Override other variables vcn_name, vcn_dns_name, shapes etc in terraform.tfvars. See the terraform.tfvars.example.

### Deploy OKE

Initialize Terraform:
```
$ terraform init
```

> N.B. Until this module is published externally, you have to run terraform init within Oracle network.

View what Terraform plans do before actually doing it:
```
$ terraform plan
```

Compare what will be provisioned in terms of compute instances/shapes (nat, worker nodes) vs what is available under your service limits of the account in your region and the ADs and modify accordingly. Make sure you read and understand the impact of OKE Parameters. The algorithm is explained below. In particular, pay attention to these variables node_pool_topology, node_pools, node_pool_quantity_per_subnet and node_pool_node_shape. Don't also forget to include 1 nat instance in your count if you're installing Istio.

Create oke resources, cluster, Istio:
```
$ terraform apply
```

### Instructions

- oci-cli is preconfigured and upgraded for the opc user on the nat instances. To
use, enable 1 of the nat instances in terraform.tfvars in the 'ha' variable e.g.

    ```
    ha = {
        "nat_ad1"     = "true"
    }
    ```

    You can do this any time i.e. either at the beginning or after the cluster has been created. After the instance is provisioned, terraform will output the ip address of the nat instance(s):

    ```
    ssh_to_nats = [
        AD1: ssh opc@XXX.XXX.XXX.XXX,
        AD2: ssh opc@,
        AD3: ssh opc@
    ]
    ```

    Copy the ssh command to the nat instance to login and verify:

    ```
    $ oci network vcn list --compartment-id <compartment-ocid>
    ```

    You can turn off the nat instance(s) anytime by setting the above value to false and run terraform apply again.

> N.B. If you're installing Istio, you need to enable _**1 of the nat instances**_ because the Istio installer uses the helm client installed and configured on the NAT instance to install Istio.

- kubectl is pre-installed on the nat instances

    ```
    $ kubectl get nodes
    ```

- The private subnets are programmable and can be controlled using the vcn_cidr, newbits and subnets variables. This can help you control the size and number of subnets that can be created within the VCNs e.g.
  
    ```
    vcn_cidr = "10.0.0.0/16"
    
    newbits = "8"
    
    subnets = {
        "nat_ad1"     = "11"        
        "nat_ad2"     = "21"        
        "nat_ad3"     = "31"        
        "lb_ad1"      = "12"        
        "lb_ad2"      = "22"        
        "lb_ad3"      = "32"        
        "workers_ad1" = "13"        
        "workers_ad2" = "23"        
        "workers_ad3" = "33"
    }
    ```

- In order to use OKE, you need to ensure all 3 public subnets for the worker nodes and 2 public subnets for the load balancers are created:

    ```
    ha = {        
        "nat_ad1"     = "true"
        "nat_ad2"     = "false"        
        "nat_ad3"     = "false"        
        "lb_ad1"      = "true"        
        "lb_ad2"      = "true"        
        "lb_ad3"      = "false"        
        "workers_ad1" = "true"        
        "workers_ad2" = "true"        
        "workers_ad3" = "true"
    }
    ```
    Refer to nodepool topology below to understand how this affects the number of worker subnets you need.

    The nat instances can be turned on and off as needed with no impact on OKE.

- OKE Parameters - see terraform.tfvars.example. Most of them are self-explanatory. The following are highlights:
   
   - Number of node pools are programmable. This is controlled by the node_pools variable.
   
   - Number of worker nodes per node pools are programmable. This is controlled by the node_pool_quantity_per_subnet variable.

   - Setting node_pools = "2" and node_pool_quantity_per_subnet = "2" and nodepool_topology = "2" will create a cluster of 8 worker nodes. Similarly, corresponding values of 3, 2, 2 will create a cluster of 12 worker nodes.
   
   - Node pool topology is configurable via the nodepool_topology parameter. Possible values are 2 or 3. If you set the value of 2, the node pools will span 2 subnets (effectively 2 ADs) and will use the number of node pools you are creating to iterate over the subnets. If you set the value of 3, the node pools will span all 3 subnets (effectively all 3 ADs in the region). Ensure you set the appropriate number of worker subnets under the ha variable above based on your choice of topology. It's easiest of you enable all 3 worker subnets.

- kubeconfig is downloaded locally and stored in generated/kubeconfig. To interact with your cluster:

    ```
    $ export KUBECONFIG=generated/kubeconfig
    $ kubectl get nodes
    ```
- [helm][helm] can also now be installed on the nat instances by setting the install_helm=true in terraform.tfvars

- [Istio][istio] can also now be installed by setting the install_istio=true in terraform.tfvars. 
    - N.B. Ensure _**only 1 NAT instance**_ is created under the ha variables if you plan on installing istio

- [Istio][istio] features such as performance monitoring, logging, tracing can also be enabled. See terraform.tfvars.example

- [Weavescope][weavescope] is a visualization and monitoring tool for Kubernetes and Docker. Set install_weavescope = "true" in terraform.tfvars

## Terraform Configuration options

### Basic OCI Configurations
| Option                                | Description                                   | Values                    | Default               | 
| -----------------------------------   | -------------------------------------------   | ------------              | -------------------   |
| tenanancy_ocid                        | OCI tenancy ocid                                              |               |           |
| user_ocid                             | OCI user                                              |               |           |
| compartment_ocid                      | OCI compartment ocid                                              |               |           |                    
| fingerprint                           | ssh fingerprint                                              |               |           |                           
| region                                | OCI region where to provision                                              | eu-frankfurt-1, us-ashburn-1, uk-london-1, us-phoenix-1               | us-ashburn-1          |
| vcn_dns_name                          | VCN's DNS name                                              |               |      ocioke     |
| vcn_cidr                              | VCN's CIDR                                              |              | 10.0.0.0/16          |
| vcn_name                              | VCN's name in the OCI Console                                             |               |           |
| newbits                               | The difference between the VCN's netmask and the desired subnets mask. At the moment, it is the same value for every subnets. In future, this will be improved so that individual subnets can have their own newbits value. This translates into the newbits parameter in the cidrsubnet Terraform function. [In-depth explanation][cidrsubnet]. Related [networks, subnets and cidr][network] documentation.                                              |               |   8        |
| subnets                               | Defines the boundaries of the subnets. This translates into the netnum parameter in the cidrsubnet Terraform function. [In-depth explanation][cidrsubnet]. Related [networks, subnets and cidr][network] documentation.                                            |               |    See terraform.tfvars.example       |
| nat_shape                             | The shape of the NAT instance that will be provisioned.                                              |               | VM.Standard1.1          |
| ha                                    | Where to provision NAT instances, worker and load balancer subnets.                                              |               | See terraform.tfvars.example          |


### OKE Configuration
| Option                                | Description                                   | Values                    | Default               | 
| -----------------------------------   | -------------------------------------------   | ------------              | -------------------   |
| kubernetes_version                    | The version of Kubernetes to provision. This is based on the available versions in OKE.                                              |               |       1.10.3    |
| cluster_name                          | The name of the OKE cluster as it will appear in the OCI Console.                                              |               |  okecluster         |
| dashboard_enabled                     | Whether to create the default Kubernetes dashboard.                                              |         true/false      |   true        |
| tiller_enabled                        | Whether to install the server side of [Helm][helm] in the OKE cluster.                                              |  true/false             |   true        |
| pods_cidr                             | The CIDR for the Kubernetes POD network.                                              |               |    10.244.0.0/16       |
| services_cidr                         | The CIDR for the Kubernetes services network.                                               |               | 10.96.0.0/16          |
| node_pool_name_prefix                 | The prefix of the node pool.                                              |               |   np        |
| node_pool_node_image_name             | The image name for the worker nodes. At the moment, only Oracle-Linux-7.4 is available                                             |  Oracle-Linux-7.4             |       Oracle-Linux-7.4    |
| node_pool_node_shape                  | The shape for the worker nodes.                                              |               |           VM.Standard1.4 |
| node_pool_quantity_per_subnet         | Number of worker nodes by worker subnets.                                              |               |         1  |
| node_pools                            | Number of node pools to create. Terraform will use this number in conjunction with the node_pool_name_prefix to create the name of the node pools.                                              |               |    1       |
 | nodepool_topology                     | Whether to make the node pool span 2 or 3 subnets (ergo AD). Acceptable and tested values are 2 or 3 only. The total number of worker nodes created is effectively obtained by this formula: nodepool_topology x  node_pools x  node_pool_quantity_per_subnet.                                            |    2/3           |     3      |

### Addons
| Option                                | Description                                   | Values                    | Default               | 
| -----------------------------------   | -------------------------------------------   | ------------              | -------------------   |
| install_helm                          | Whether to install helm on the NAT instance. You need to enable at least 1 of the NAT instances under the 'ha' parameter.                                            |                true/false | false           |
| helm_version                          | The version of helm to install.                                              |               |           2.9.1 |
| install_istio                         | Whether to install the Istio service mesh in the cluster. Enable _**only 1 of the NAT instance**_ under the 'ha' parameter and set install_helm to 'true' .                                             |   true/false            |    false       |
| istio_version                         | The version of the Istio service mesh to install.                                              |               | 1.0.0          |
| ingress_enabled                       | Whether ingress should be installed. Leave to false unless you know what you're doing.                                             | true/false              |  false         |
| tracing_enabled                       | Whether to install the distributed tracing (Jaeger) addon.                                              | true/false              |          false |
| grafana_enabled                       | Whether to install the Grafana addon. This will automatically create the Istio Service Mesh Dashboard.                                                |   true/false            |  false         |
| servicegraph_enabled                  | Whether to install the ServiceGraph addon.                                              |       true/false        |  false         |
| gateways_istio_ingressgateway_enabled | Whether to install the Ingress gateway.                                              |   true/false            |  false         |
| gateways_istio_egressgateway_enabled  | Whether to install the Egress gateway.                                              |   true/false            |  false         |
| galley_enabled                        | Whether to install Galley for server-side config validation.                                              |   true/false            |   false        |
| sidecarInjectorWebhook_enabled        | Whether to install automatic sidecar injector.                                              |     true/false          |         false  |
| mixer_enabled                         | Whether to install Mixer.                                              |   true/false            |  false         |
| prometheus_enabled                    | Whether to install Prometheus for performance monitoring.                                              |     true/false          |     false      |
| global_proxy_envoy_statsd_enabled     |                                               |  true/false             |  false         |
| efk_enabled                           | Whether to install log analytics through EFK (ElasticSearch, fluentd, Kibana).                                              |       true/false        |  false         |
| install_bookinfo_sample               | Whether to install the Bookinfo sample application.                                              |    true/false           |      false     |
| install_weavescope                    | Whether to install the Weavescope visualization tool.                                              |  true/false             |    false       |
| open_sesame                           | Whether to generate ssh tunnel scripts that allow accessing the various services through ssh to the NAT instance. Enable all the Istio options. See Sesame documentation below.                                              |   true/false            |   false        |

## Istio eye candy

### Access the Bookinfo application

- Obtain the product page url:

```
$ chmod +x demo/*.sh
$ demo/bookinfo.sh
```
- Open the productpage URL in the browser to generate traffic

### Poor man's traffic generator

- Install [Postman][postman] in Chrome browser if you don't have it

- Copy the URL of the productpage

- Open the Postman extension in Chrome

- Click on New Request and paste the URL in the address bar and click 'Send'

- Click on 'Save'

- Click on 'Create Collection', give it a name e.g. productpage and select

- Click 'Save' to productpage

- Click on 'Runner' and select the 'productpage' collection

- Enter an iteration number e.g. 500 and optionally a delay and click Run

### Performance monitoring with Prometheus

- Access the Prometheus service

```
demo/prometheus.sh
```
- Open the [Prometheus UI](http://localhost:9090/graph) in the browser
- [Prometheus Documentation][prometheus]

### Performance visualization with Grafana
- Access the Grafana service

```
$ demo/grafana.sh
```
- Open the [Grafana UI](http://localhost:3000/dashboard/db/istio-mesh-dashboard) in browser in the browser

### Log analytics with Kibana

- Access the Kibana service

```
$ demo/efk.sh
```
- Open the [Kibana UI](http://localhost:5601/) in browser
- Click "Set up index patterns" in the top right
- Use * as the index pattern, and click 'Next step.'
- Select @timestamp as the Time Filter field name, and click “Create index pattern.”
- Now click 'Discover' on the left menu, and start exploring the logs generated
- [Kibana Documentation][kibana]

### Distributed Tracing with Jaeger

- Access the Jaeger service

```
$ demo/jaeger.sh
```
- Open the [Jaeger UI](http://localhost:16686/) in the browser

### ServiceGraph

- Access the ServiceGraph service

```
$ demo/servicegraph.sh
```
- Open the [ServiceGraph UI](http://localhost:8088/force/forcegraph.html) in the browser

### OKE Visualization through Weavescope

- Access the Weavescope service

```
$ demo/weavescope.sh
```
- Open the [Weavescope UI](http://localhost:4040) in the browser

### Accessing telemetry services through Sesame

Certain networks (airports, customer wifi etc.) restrict outgoing ports access. As such, kube forwarding to access telemetry services may not work.

[Sesame](https://en.wikipedia.org/wiki/Open_Sesame_(phrase)) (named after the magic door in Alladin's story) does the following:

- runs the kube forwarding command on 1 of the nat instances
- creates a ssh tunnel to the nat instance so you can access the telemetry services locally

To use, you need to ensure the following:

- 1 of the nat instances are enabled under the 'ha' variable
- The istio parameters are set to true (with the exception of ingress_enabled)
- open_sesame is set to "true"

Then run the local script to create the ssh tunnel to the nat instance:

```
$ demo/opensesame.sh
```

You can now access the telemetry services using the URLs above.

### Istio Service URLs to bookmark

| Service      | URL                                                     |
| ------------ | ------------------------------------------------------- |
| Prometheus   | http://localhost:9090/graph                             |
| Grafana      | http://localhost:3000/dashboard/db/istio-mesh-dashboard |
| Kibana       | http://localhost:5601/                                  |  
| Jaeger       | http://localhost:16686/                                 |
| Servicegraph | http://localhost:8088/force/forcegraph.html             |
| Weavescope   | http://localhost:4040                                   |


## Destroying the cluster

ssh to the nat instance:

```
$ /home/opc/delete_istio.sh
```

Logout of the nat instance and then run terraform:

```
$ terraform destroy
```

## Known Issues

- The subnet allocation algorithm must be tested more thoroughly for the 2-subnet node pool topology. At the moment, ensure all 3 worker subnets are enabled to avoid unknown problems.

- If you're enabling Istio, use _**only 1 nat instance**_. This is controlled under the 'ha' variable in terraform.tfvars.

- Occasional flakiness has been observed on slow networks during cluster creation which may result in failed cluster creation/failed node pool creation or incorrect/incomplete Istio installation. The dependency graph of Terraform has been made more explicit to avoid this. However, it is possible that this may still happen. Please capture the order of execution and report the issue.

- The local kubeconfig is generated on every run. While it's not a big issue, it is a bit annoying.  

## TODO

1. Make nokc branch on baseoci become master and update vcn module source accordingly
2. Make rapiddemo branch become master
3. Add kiali option when its Docker image is published
4. Explore integration with Cameron Senese's oke-go
5. Wercker integration
6. Use of OCIR
7. Architecture diagram

## Call to Action

1. Test to improve the robustness of the project
2. Review the code to see how it can be made to run faster
3. Build/contribute demo apps, preferably polyglot that can be used for Istio demo

## Related Docs

OKE: https://docs.us-phoenix-1.oraclecloud.com/Content/ContEng/Concepts/contengnetworkconfigexample.htm

## Acknowledgement
- Code liberally lifted and adapted from: https://github.com/oracle/terraform-provider-oci/tree/master/docs/examples/container_engine

- Istio instructions from [Istio][istio] website

- Folks who contributed with code, feedback, ideas, testing etc:
    - Stephen Cross
    - Cameron Senese
    - Jang Whan
    - Mike Raab
    - Jon Reeve
    - Craig Carl
    - Arjav Desai
    - Patrick Galbraith
    - Jeevan Joseph
    - Manish Kapur
    - Jeet Jagasia
    - Karsten Terp-Nielsen