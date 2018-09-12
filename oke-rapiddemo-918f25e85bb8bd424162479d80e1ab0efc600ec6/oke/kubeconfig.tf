data "oci_containerengine_cluster_kube_config" "kube_config" {
  cluster_id    = "${oci_containerengine_cluster.k8s_cluster.id}"
  expiration    = "${var.cluster_kube_config_expiration}"
  token_version = "${var.cluster_kube_config_token_version}"
}

resource null_resource "create_local_kubeconfig" {
  provisioner "local-exec" {
    command = "rm -rf generated"
  }

  provisioner "local-exec" {
    command = "mkdir generated"
  }

  provisioner "local-exec" {
    command = "touch generated/kubeconfig"
  }
}

resource "local_file" "kube_config_file" {
  depends_on = ["null_resource.create_local_kubeconfig", "oci_containerengine_cluster.k8s_cluster"]
  content    = "${data.oci_containerengine_cluster_kube_config.kube_config.content}"
  filename   = "${path.root}/generated/kubeconfig"
}

data "template_file" "install_kubectl" {
  template = "${file("${path.module}/scripts/install_kubectl.template.sh")}"
}

resource null_resource "write_install_kubectl_nat1" {
  connection {
    type        = "ssh"
    host        = "${element(var.nat_public_ips["ad1"],0)}"
    user        = "opc"
    private_key = "${file(var.private_key_path)}"
    timeout     = "40m"
  }

  provisioner "file" {
    content     = "${data.template_file.install_kubectl.rendered}"
    destination = "/home/opc/install_kubectl.sh"
  }

  count = "${var.ha["nat_ad1"] == "true"   ? "1" : "0"}"
}

resource null_resource "install_kubectl_nat1" {
  depends_on = ["null_resource.write_install_kubectl_nat1"]

  connection {
    type        = "ssh"
    host        = "${element(var.nat_public_ips["ad1"],0)}"
    user        = "opc"
    private_key = "${file(var.private_key_path)}"
    timeout     = "40m"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /home/opc/install_kubectl.sh",
      "/home/opc/install_kubectl.sh",
    ]
  }

  count = "${var.ha["nat_ad1"] == "true"   ? "1" : "0"}"
}

resource null_resource "generate_kubeconfig_nat1" {
  depends_on = ["oci_containerengine_cluster.k8s_cluster"]

  connection {
    type        = "ssh"
    host        = "${element(var.nat_public_ips["ad1"],0)}"
    user        = "opc"
    private_key = "${file(var.private_key_path)}"
    timeout     = "40m"
  }

  provisioner "remote-exec" {
    inline = [
      "oci ce cluster create-kubeconfig --cluster-id ${oci_containerengine_cluster.k8s_cluster.id} --file /home/opc/.kube/config",
    ]
  }

  count = "${var.ha["nat_ad1"] == "true"   ? "1" : "0"}"
}

resource null_resource "write_install_kubectl_nat2" {
  connection {
    type        = "ssh"
    host        = "${element(var.nat_public_ips["ad2"],0)}"
    user        = "opc"
    private_key = "${file(var.private_key_path)}"
    timeout     = "40m"
  }

  provisioner "file" {
    content     = "${data.template_file.install_kubectl.rendered}"
    destination = "/home/opc/install_kubectl.sh"
  }

  count = "${var.ha["nat_ad2"] == "true"   ? "1" : "0"}"
}

resource null_resource "install_kubectl_nat2" {
  depends_on = ["null_resource.write_install_kubectl_nat2"]

  connection {
    type        = "ssh"
    host        = "${element(var.nat_public_ips["ad2"],0)}"
    user        = "opc"
    private_key = "${file(var.private_key_path)}"
    timeout     = "40m"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /home/opc/install_kubectl.sh",
      "/home/opc/install_kubectl.sh",
    ]
  }

  count = "${var.ha["nat_ad2"] == "true"   ? "1" : "0"}"
}

resource null_resource "generate_kubeconfig_nat2" {
  depends_on = ["oci_containerengine_cluster.k8s_cluster"]

  connection {
    type        = "ssh"
    host        = "${element(var.nat_public_ips["ad2"],0)}"
    user        = "opc"
    private_key = "${file(var.private_key_path)}"
    timeout     = "40m"
  }

  provisioner "remote-exec" {
    inline = [
      "oci ce cluster create-kubeconfig --cluster-id ${oci_containerengine_cluster.k8s_cluster.id} --file /home/opc/.kube/config",
    ]
  }

  count = "${var.ha["nat_ad2"] == "true"   ? "1" : "0"}"
}

resource null_resource "write_install_kubectl_nat3" {
  connection {
    type        = "ssh"
    host        = "${element(var.nat_public_ips["ad3"],0)}"
    user        = "opc"
    private_key = "${file(var.private_key_path)}"
    timeout     = "40m"
  }

  provisioner "file" {
    content     = "${data.template_file.install_kubectl.rendered}"
    destination = "/home/opc/install_kubectl.sh"
  }

  count = "${var.ha["nat_ad3"] == "true"   ? "1" : "0"}"
}

resource null_resource "install_kubectl_nat3" {
  depends_on = ["null_resource.write_install_kubectl_nat3"]

  connection {
    type        = "ssh"
    host        = "${element(var.nat_public_ips["ad3"],0)}"
    user        = "opc"
    private_key = "${file(var.private_key_path)}"
    timeout     = "40m"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /home/opc/install_kubectl.sh",
      "/home/opc/install_kubectl.sh",
    ]
  }

  count = "${var.ha["nat_ad3"] == "true"   ? "1" : "0"}"
}

resource null_resource "generate_kubeconfig_nat3" {
  depends_on = ["oci_containerengine_cluster.k8s_cluster"]

  connection {
    type        = "ssh"
    host        = "${element(var.nat_public_ips["ad3"],0)}"
    user        = "opc"
    private_key = "${file(var.private_key_path)}"
    timeout     = "40m"
  }

  provisioner "remote-exec" {
    inline = [
      "oci ce cluster create-kubeconfig --cluster-id ${oci_containerengine_cluster.k8s_cluster.id} --file /home/opc/.kube/config",
    ]
  }

  count = "${var.ha["nat_ad3"] == "true"   ? "1" : "0"}"
}

data "template_file" "install_weavescope" {
  template = "${file("${path.module}/scripts/install_weavescope.template.sh")}"

  vars = {
    user_ocid = "${var.user_ocid}"
  }

  count = "${var.install_weavescope == "true"   ? "1" : "0"}"
}

resource null_resource "write_install_weavescope_ad1" {
  connection {
    type        = "ssh"
    host        = "${element(var.nat_public_ips["ad1"],0)}"
    user        = "opc"
    private_key = "${file(var.private_key_path)}"
    timeout     = "40m"
  }

  provisioner "file" {
    content     = "${data.template_file.install_weavescope.rendered}"
    destination = "/home/opc/install_weavescope.sh"
  }

  count = "${(var.ha["nat_ad1"] == "true" && var.install_weavescope == "true")   ? "1" : "0"}"
}

resource null_resource "install_weavescope_ad1" {
  depends_on = ["null_resource.generate_kubeconfig_nat1", "null_resource.write_install_weavescope_ad1"]

  connection {
    type        = "ssh"
    host        = "${element(var.nat_public_ips["ad1"],0)}"
    user        = "opc"
    private_key = "${file(var.private_key_path)}"
    timeout     = "40m"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /home/opc/install_weavescope.sh",
      "/home/opc/install_weavescope.sh",
    ]
  }

  count = "${var.ha["nat_ad1"] == "true"   ? "1" : "0"}"
}

resource null_resource "write_install_weavescope_ad2" {
  connection {
    type        = "ssh"
    host        = "${element(var.nat_public_ips["ad2"],0)}"
    user        = "opc"
    private_key = "${file(var.private_key_path)}"
    timeout     = "40m"
  }

  provisioner "file" {
    content     = "${data.template_file.install_weavescope.rendered}"
    destination = "/home/opc/install_weavescope.sh"
  }

  count = "${(var.ha["nat_ad2"] == "true" && var.install_weavescope == "true")   ? "1" : "0"}"
}

resource null_resource "install_weavescope_ad2" {
  depends_on = ["null_resource.generate_kubeconfig_nat2", "null_resource.write_install_weavescope_ad2"]

  connection {
    type        = "ssh"
    host        = "${element(var.nat_public_ips["ad2"],0)}"
    user        = "opc"
    private_key = "${file(var.private_key_path)}"
    timeout     = "40m"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /home/opc/install_weavescope.sh",
      "/home/opc/install_weavescope.sh",
    ]
  }

  count = "${var.ha["nat_ad2"] == "true"   ? "1" : "0"}"
}

resource null_resource "write_install_weavescope_ad3" {
  connection {
    type        = "ssh"
    host        = "${element(var.nat_public_ips["ad3"],0)}"
    user        = "opc"
    private_key = "${file(var.private_key_path)}"
    timeout     = "40m"
  }

  provisioner "file" {
    content     = "${data.template_file.install_weavescope.rendered}"
    destination = "/home/opc/install_weavescope.sh"
  }

  count = "${(var.ha["nat_ad3"] == "true" && var.install_weavescope == "true")   ? "1" : "0"}"
}

resource null_resource "install_weavescope_ad3" {
  depends_on = ["null_resource.generate_kubeconfig_nat3", "null_resource.write_install_weavescope_ad2"]

  connection {
    type        = "ssh"
    host        = "${element(var.nat_public_ips["ad3"],0)}"
    user        = "opc"
    private_key = "${file(var.private_key_path)}"
    timeout     = "40m"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /home/opc/install_weavescope.sh",
      "/home/opc/install_weavescope.sh",
    ]
  }

  count = "${var.ha["nat_ad3"] == "true"   ? "1" : "0"}"
}
