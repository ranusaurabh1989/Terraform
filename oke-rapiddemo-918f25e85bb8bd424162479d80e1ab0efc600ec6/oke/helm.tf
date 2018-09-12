data "template_file" "install_helm" {
  template = "${file("${path.module}/scripts/install_helm.template.sh")}"

  vars = {
    helm_version = "${var.helm_version}"
  }
}

resource null_resource "install_helm_nat1" {
  depends_on = ["null_resource.generate_kubeconfig_nat1"]

  connection {
    type        = "ssh"
    host        = "${element(var.nat_public_ips["ad1"],0)}"
    user        = "opc"
    private_key = "${file(var.private_key_path)}"
    timeout     = "40m"
  }

  provisioner "file" {
    content     = "${data.template_file.install_helm.rendered}"
    destination = "/home/opc/install_helm.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /home/opc/install_helm.sh",
      "/home/opc/install_helm.sh",
    ]
  }

  count = "${(var.ha["nat_ad1"] == "true" && var.install_helm == "true")   ? "1" : "0"}"
}

resource null_resource "install_helm_nat2" {
  depends_on = ["null_resource.generate_kubeconfig_nat2"]

  connection {
    type        = "ssh"
    host        = "${element(var.nat_public_ips["ad2"],0)}"
    user        = "opc"
    private_key = "${file(var.private_key_path)}"
    timeout     = "40m"
  }

  provisioner "file" {
    content     = "${data.template_file.install_helm.rendered}"
    destination = "/home/opc/install_helm.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /home/opc/install_helm.sh",
      "/home/opc/install_helm.sh",
    ]
  }

  count = "${(var.ha["nat_ad2"] == "true" && var.install_helm == "true")   ? "1" : "0"}"
}

resource null_resource "install_helm_nat3" {
  depends_on = ["null_resource.generate_kubeconfig_nat3"]

  connection {
    type        = "ssh"
    host        = "${element(var.nat_public_ips["ad3"],0)}"
    user        = "opc"
    private_key = "${file(var.private_key_path)}"
    timeout     = "40m"
  }

  provisioner "file" {
    content     = "${data.template_file.install_helm.rendered}"
    destination = "/home/opc/install_helm.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /home/opc/install_helm.sh",
      "/home/opc/install_helm.sh",
    ]
  }

  count = "${(var.ha["nat_ad3"] == "true" && var.install_helm == "true")   ? "1" : "0"}"
}
