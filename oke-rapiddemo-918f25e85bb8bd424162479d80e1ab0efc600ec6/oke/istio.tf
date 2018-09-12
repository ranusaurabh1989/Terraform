data "template_file" "check_worker_node_status" {
  template = "${file("${path.module}/scripts/is_worker_active.py")}"

  vars {
    compartment_id = "${var.compartment_ocid}"
  }

  count = "${var.install_istio == "true"   ? "1" : "0"}"
}

data "template_file" "install_istio" {
  template = "${file("${path.module}/scripts/install_istio.template.sh")}"

  vars = {
    istio_version                         = "${var.istio_version}"
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
  }

  count = "${var.install_istio == "true"   ? "1" : "0"}"
}

data "template_file" "fluentd" {
  template = "${file("${path.module}/resources/fluentd-istio.yaml")}"
}

data "template_file" "logging_stack" {
  template = "${file("${path.module}/resources/logging-stack.yaml")}"
}

data "template_file" "delete_istio" {
  template = "${file("${path.module}/scripts/delete_istio.template.sh")}"

  vars = {
    istio_version = "${var.istio_version}"
  }

  count = "${var.install_istio == "true"   ? "1" : "0"}"
}

data "template_file" "tunnel" {
  template = "${file("${path.module}/scripts/tunnel.template.sh")}"

  count = "${(var.install_istio == "true" && var.open_sesame == "true")   ? "1" : "0"}"
}

data "template_file" "opensesame_nat_ad1" {
  template = "${file("${path.module}/scripts/opensesame.template.sh")}"

  vars {
    nat_ip = "${element(var.nat_public_ips["ad1"],0)}"
  }

  count = "${(var.ha["nat_ad1"] == "true" && var.install_istio == "true" && var.open_sesame == "true")   ? "1" : "0"}"
}

data "template_file" "opensesame_nat_ad2" {
  template = "${file("${path.module}/scripts/opensesame.template.sh")}"

  vars {
    nat_ip = "${element(var.nat_public_ips["ad2"],0)}"
  }

  count = "${(var.ha["nat_ad2"] == "true" && var.install_istio == "true" && var.open_sesame == "true")   ? "1" : "0"}"
}

data "template_file" "opensesame_nat_ad3" {
  template = "${file("${path.module}/scripts/opensesame.template.sh")}"

  vars {
    nat_ip = "${element(var.nat_public_ips["ad3"],0)}"
  }

  count = "${(var.ha["nat_ad3"] == "true" && var.install_istio == "true" && var.open_sesame == "true")   ? "1" : "0"}"
}

resource null_resource "write_check_worker_script_ad1" {
  connection {
    type        = "ssh"
    host        = "${element(var.nat_public_ips["ad1"],0)}"
    user        = "opc"
    private_key = "${file(var.private_key_path)}"
    timeout     = "40m"
  }

  provisioner "file" {
    content     = "${data.template_file.check_worker_node_status.rendered}"
    destination = "/home/opc/is_worker_active.py"
  }

  count = "${(var.ha["nat_ad1"] == "true" && var.install_istio == "true")   ? "1" : "0"}"
}

resource null_resource "is_worker_active_ad1" {
  depends_on = ["null_resource.write_check_worker_script_ad1", "oci_containerengine_cluster.k8s_cluster"]

  connection {
    type        = "ssh"
    host        = "${element(var.nat_public_ips["ad1"],0)}"
    user        = "opc"
    private_key = "${file(var.private_key_path)}"
    timeout     = "40m"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /home/opc/is_worker_active.py",
      "while [ ! -f /home/opc/node.active ]; do /home/opc/is_worker_active.py; sleep 10; done",
    ]
  }

  count = "${(var.ha["nat_ad1"] == "true"  && var.install_istio == "true")   ? "1" : "0"}"
}

resource null_resource "write_install_istio_ad1" {
  connection {
    type        = "ssh"
    host        = "${element(var.nat_public_ips["ad1"],0)}"
    user        = "opc"
    private_key = "${file(var.private_key_path)}"
    timeout     = "40m"
  }

  provisioner "file" {
    content     = "${data.template_file.install_istio.rendered}"
    destination = "/home/opc/install_istio.sh"
  }

  provisioner "file" {
    content     = "${data.template_file.fluentd.rendered}"
    destination = "/home/opc/fluentd-istio.yaml"
  }

  provisioner "file" {
    content     = "${data.template_file.logging_stack.rendered}"
    destination = "/home/opc/logging-stack.yaml"
  }

  provisioner "file" {
    content     = "${data.template_file.delete_istio.rendered}"
    destination = "/home/opc/delete_istio.sh"
  }

  count = "${(var.ha["nat_ad1"] == "true" && var.install_helm == "true" && var.install_istio == "true")   ? "1" : "0"}"
}

resource null_resource "install_istio_ad1" {
  depends_on = ["null_resource.install_helm_nat1", "null_resource.write_install_istio_ad1", "null_resource.is_worker_active_ad1"]

  connection {
    type        = "ssh"
    host        = "${element(var.nat_public_ips["ad1"],0)}"
    user        = "opc"
    private_key = "${file(var.private_key_path)}"
    timeout     = "40m"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /home/opc/install_istio.sh",
      "chmod +x /home/opc/delete_istio.sh",
      "/home/opc/install_istio.sh",
    ]
  }

  count = "${(var.ha["nat_ad1"] == "true" && var.install_helm == "true" && var.install_istio == "true")   ? "1" : "0"}"
}

resource null_resource "write_check_worker_script_ad2" {
  connection {
    type        = "ssh"
    host        = "${element(var.nat_public_ips["ad2"],0)}"
    user        = "opc"
    private_key = "${file(var.private_key_path)}"
    timeout     = "40m"
  }

  provisioner "file" {
    content     = "${data.template_file.check_worker_node_status.rendered}"
    destination = "/home/opc/is_worker_active.py"
  }

  count = "${(var.ha["nat_ad2"] == "true" && var.install_istio == "true")   ? "1" : "0"}"
}

resource null_resource "is_worker_active_ad2" {
  depends_on = ["null_resource.write_check_worker_script_ad2", "oci_containerengine_cluster.k8s_cluster"]

  connection {
    type        = "ssh"
    host        = "${element(var.nat_public_ips["ad2"],0)}"
    user        = "opc"
    private_key = "${file(var.private_key_path)}"
    timeout     = "40m"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /home/opc/is_worker_active.py",
      "while [ ! -f /home/opc/node.active ]; do /home/opc/is_worker_active.py; sleep 10; done",
    ]
  }

  count = "${(var.ha["nat_ad2"] == "true"  && var.install_istio == "true")   ? "1" : "0"}"
}

resource null_resource "write_install_istio_ad2" {
  connection {
    type        = "ssh"
    host        = "${element(var.nat_public_ips["ad2"],0)}"
    user        = "opc"
    private_key = "${file(var.private_key_path)}"
    timeout     = "40m"
  }

  provisioner "file" {
    content     = "${data.template_file.install_istio.rendered}"
    destination = "/home/opc/install_istio.sh"
  }

  provisioner "file" {
    content     = "${data.template_file.fluentd.rendered}"
    destination = "/home/opc/fluentd-istio.yaml"
  }

  provisioner "file" {
    content     = "${data.template_file.logging_stack.rendered}"
    destination = "/home/opc/logging-stack.yaml"
  }

  provisioner "file" {
    content     = "${data.template_file.delete_istio.rendered}"
    destination = "/home/opc/delete_istio.sh"
  }

  count = "${(var.ha["nat_ad2"] == "true" && var.install_helm == "true" && var.install_istio == "true")   ? "1" : "0"}"
}

resource null_resource "install_istio_ad2" {
  depends_on = ["null_resource.install_helm_nat2", "null_resource.write_install_istio_ad2", "null_resource.is_worker_active_ad2"]

  connection {
    type        = "ssh"
    host        = "${element(var.nat_public_ips["ad2"],0)}"
    user        = "opc"
    private_key = "${file(var.private_key_path)}"
    timeout     = "40m"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /home/opc/install_istio.sh",
      "chmod +x /home/opc/delete_istio.sh",
      "/home/opc/install_istio.sh",
    ]
  }

  count = "${(var.ha["nat_ad2"] == "true" && var.install_helm == "true" && var.install_istio == "true")   ? "1" : "0"}"
}

resource null_resource "write_check_worker_script_ad3" {
  connection {
    type        = "ssh"
    host        = "${element(var.nat_public_ips["ad3"],0)}"
    user        = "opc"
    private_key = "${file(var.private_key_path)}"
    timeout     = "40m"
  }

  provisioner "file" {
    content     = "${data.template_file.check_worker_node_status.rendered}"
    destination = "/home/opc/is_worker_active.py"
  }

  count = "${(var.ha["nat_ad3"] == "true" && var.install_istio == "true")   ? "1" : "0"}"
}

resource null_resource "is_worker_active_ad3" {
  depends_on = ["null_resource.write_check_worker_script_ad3", "oci_containerengine_cluster.k8s_cluster"]

  connection {
    type        = "ssh"
    host        = "${element(var.nat_public_ips["ad3"],0)}"
    user        = "opc"
    private_key = "${file(var.private_key_path)}"
    timeout     = "40m"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /home/opc/is_worker_active.py",
      "while [ ! -f /home/opc/node.active ]; do /home/opc/is_worker_active.py; sleep 10; done",
    ]
  }

  count = "${(var.ha["nat_ad3"] == "true"  && var.install_istio == "true")   ? "1" : "0"}"
}

resource null_resource "write_install_istio_ad3" {
  connection {
    type        = "ssh"
    host        = "${element(var.nat_public_ips["ad3"],0)}"
    user        = "opc"
    private_key = "${file(var.private_key_path)}"
    timeout     = "40m"
  }

  provisioner "file" {
    content     = "${data.template_file.install_istio.rendered}"
    destination = "/home/opc/install_istio.sh"
  }

  provisioner "file" {
    content     = "${data.template_file.fluentd.rendered}"
    destination = "/home/opc/fluentd-istio.yaml"
  }

  provisioner "file" {
    content     = "${data.template_file.logging_stack.rendered}"
    destination = "/home/opc/logging-stack.yaml"
  }

  provisioner "file" {
    content     = "${data.template_file.delete_istio.rendered}"
    destination = "/home/opc/delete_istio.sh"
  }

  count = "${(var.ha["nat_ad3"] == "true" && var.install_helm == "true" && var.install_istio == "true")   ? "1" : "0"}"
}

resource null_resource "install_istio_ad3" {
  depends_on = ["null_resource.install_helm_nat3", "null_resource.write_install_istio_ad3", "null_resource.is_worker_active_ad3"]

  connection {
    type        = "ssh"
    host        = "${element(var.nat_public_ips["ad3"],0)}"
    user        = "opc"
    private_key = "${file(var.private_key_path)}"
    timeout     = "40m"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /home/opc/install_istio.sh",
      "chmod +x /home/opc/delete_istio.sh",
      "/home/opc/install_istio.sh",
    ]
  }

  count = "${(var.ha["nat_ad3"] == "true" && var.install_helm == "true" && var.install_istio == "true")   ? "1" : "0"}"
}

resource null_resource "write_tunnel_ad1" {
  connection {
    type        = "ssh"
    host        = "${element(var.nat_public_ips["ad1"],0)}"
    user        = "opc"
    private_key = "${file(var.private_key_path)}"
    timeout     = "40m"
  }

  provisioner "file" {
    content     = "${data.template_file.tunnel.rendered}"
    destination = "/home/opc/tunnel.sh"
  }

  count = "${(var.ha["nat_ad1"] == "true" && var.install_istio == "true" && var.open_sesame == "true")   ? "1" : "0"}"
}

resource null_resource "open_tunnel_ad1" {
  depends_on = ["null_resource.write_tunnel_ad1", "null_resource.install_istio_ad1"]

  connection {
    type        = "ssh"
    host        = "${element(var.nat_public_ips["ad1"],0)}"
    user        = "opc"
    private_key = "${file(var.private_key_path)}"
    timeout     = "40m"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /home/opc/tunnel.sh",
      "/home/opc/tunnel.sh",
      "sleep 1",
    ]
  }

  count = "${(var.ha["nat_ad1"] == "true"  && var.install_istio == "true" && var.open_sesame == "true")   ? "1" : "0"}"
}

resource "local_file" "write_opensesame_ad1" {
  content  = "${data.template_file.opensesame_nat_ad1.rendered}"
  filename = "${path.root}/demo/opensesame.sh"
  count    = "${(var.ha["nat_ad1"] == "true" && var.install_istio == "true" && var.open_sesame == "true")   ? "1" : "0"}"
}

resource null_resource "write_tunnel_ad2" {
  connection {
    type        = "ssh"
    host        = "${element(var.nat_public_ips["ad2"],0)}"
    user        = "opc"
    private_key = "${file(var.private_key_path)}"
    timeout     = "40m"
  }

  provisioner "file" {
    content     = "${data.template_file.tunnel.rendered}"
    destination = "/home/opc/tunnel.sh"
  }

  count = "${(var.ha["nat_ad2"] == "true" && var.install_istio == "true" && var.open_sesame == "true")   ? "1" : "0"}"
}

resource null_resource "open_tunnel_ad2" {
  depends_on = ["null_resource.write_tunnel_ad2", "null_resource.install_istio_ad2"]

  connection {
    type        = "ssh"
    host        = "${element(var.nat_public_ips["ad2"],0)}"
    user        = "opc"
    private_key = "${file(var.private_key_path)}"
    timeout     = "40m"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /home/opc/tunnel.sh",
      "/home/opc/tunnel.sh",
      "sleep 1",
    ]
  }

  count = "${(var.ha["nat_ad2"] == "true"  && var.install_istio == "true" && var.open_sesame == "true")   ? "1" : "0"}"
}

resource "local_file" "write_opensesame_ad2" {
  content  = "${data.template_file.opensesame_nat_ad2.rendered}"
  filename = "${path.root}/demo/opensesame.sh"
  count    = "${(var.ha["nat_ad2"] == "true" && var.install_istio == "true" && var.open_sesame == "true")   ? "1" : "0"}"
}

resource null_resource "write_tunnel_ad3" {
  connection {
    type        = "ssh"
    host        = "${element(var.nat_public_ips["ad3"],0)}"
    user        = "opc"
    private_key = "${file(var.private_key_path)}"
    timeout     = "40m"
  }

  provisioner "file" {
    content     = "${data.template_file.tunnel.rendered}"
    destination = "/home/opc/tunnel.sh"
  }

  count = "${(var.ha["nat_ad3"] == "true" && var.install_istio == "true" && var.open_sesame == "true")   ? "1" : "0"}"
}

resource null_resource "open_tunnel_ad3" {
  depends_on = ["null_resource.write_tunnel_ad3", "null_resource.install_istio_ad3"]

  connection {
    type        = "ssh"
    host        = "${element(var.nat_public_ips["ad3"],0)}"
    user        = "opc"
    private_key = "${file(var.private_key_path)}"
    timeout     = "40m"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /home/opc/tunnel.sh",
      "/home/opc/tunnel.sh",
      "sleep 1",
    ]
  }

  count = "${(var.ha["nat_ad3"] == "true"  && var.install_istio == "true" && var.open_sesame == "true")   ? "1" : "0"}"
}

resource "local_file" "write_opensesame_ad3" {
  content  = "${data.template_file.opensesame_nat_ad3.rendered}"
  filename = "${path.root}/demo/opensesame.sh"
  count    = "${(var.ha["nat_ad3"] == "true" && var.install_istio == "true" && var.open_sesame == "true")   ? "1" : "0"}"
}
