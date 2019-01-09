data "template_file" "web_hosts" {
  count    = "${aws_instance.web.count}"
  template = "${file("${path.module}/templates/inventory/hostname.tpl")}"

  vars {
    index      = "${count.index + 1}"
    name       = "${element(aws_instance.web.*.tags.Hostname, count.index)}"
    public_ip  = "${element(aws_instance.web.*.public_ip, count.index)}"
    private_ip = "${element(aws_instance.web.*.private_ip, count.index)}"
  }
}

data "template_file" "wallet_node_hosts" {
  count    = "${aws_instance.axed_wallet.count}"
  template = "${file("${path.module}/templates/inventory/hostname.tpl")}"

  vars {
    index      = "${count.index + 1}"
    name       = "${element(aws_instance.axed_wallet.*.tags.Hostname, count.index)}"
    public_ip  = "${element(aws_instance.axed_wallet.*.public_ip, count.index)}"
    private_ip = "${element(aws_instance.axed_wallet.*.private_ip, count.index)}"
  }
}

data "template_file" "full_node_hosts" {
  count    = "${aws_instance.axed_full_node.count}"
  template = "${file("${path.module}/templates/inventory/hostname.tpl")}"

  vars {
    index      = "${count.index + 1}"
    name       = "${element(aws_instance.axed_full_node.*.tags.Hostname, count.index)}"
    public_ip  = "${element(aws_instance.axed_full_node.*.public_ip, count.index)}"
    private_ip = "${element(aws_instance.axed_full_node.*.private_ip, count.index)}"
  }
}

data "template_file" "miner_hosts" {
  count    = "${aws_instance.miner.count}"
  template = "${file("${path.module}/templates/inventory/hostname.tpl")}"

  vars {
    index      = "${count.index + 1}"
    name       = "${element(aws_instance.miner.*.tags.Hostname, count.index)}"
    public_ip  = "${element(aws_instance.miner.*.public_ip, count.index)}"
    private_ip = "${element(aws_instance.miner.*.private_ip, count.index)}"
  }
}

data "template_file" "masternode_hosts" {
  count    = "${aws_instance.masternode.count}"
  template = "${file("${path.module}/templates/inventory/hostname.tpl")}"

  vars {
    index      = "${count.index + 1}"
    name       = "${element(aws_instance.masternode.*.tags.Hostname, count.index)}"
    public_ip  = "${element(aws_instance.masternode.*.public_ip, count.index)}"
    private_ip = "${element(aws_instance.masternode.*.private_ip, count.index)}"
  }
}

data "template_file" "vpn" {
  count    = "${var.vpn_enabled ? 1 : 0}"
  template = "${file("${path.module}/templates/inventory/hostname.tpl")}"

  vars {
    index      = "${count.index + 1}"
    name       = "${element(aws_instance.vpn.*.tags.Hostname, count.index)}"
    public_ip  = "${aws_eip.vpn.public_ip}"
    private_ip = "${element(aws_instance.vpn.*.private_ip, count.index)}"
  }
}

data "template_file" "ansible_inventory" {
  template = "${file("${path.module}/templates/inventory/ansible_inventory.tpl")}"

  vars {
    all_hosts = "${join("\n",concat(
      data.template_file.web_hosts.*.rendered,
      data.template_file.wallet_node_hosts.*.rendered,
      data.template_file.full_node_hosts.*.rendered,
      data.template_file.miner_hosts.*.rendered,
      data.template_file.masternode_hosts.*.rendered,
      data.template_file.vpn.*.rendered))}"

    web_hosts         = "${join("\n", concat(aws_instance.web.*.tags.Hostname))}"
    wallet_node_hosts = "${join("\n", concat(aws_instance.axed_wallet.*.tags.Hostname))}"
    full_node_hosts   = "${join("\n", concat(aws_instance.axed_full_node.*.tags.Hostname))}"
    miner_hosts       = "${join("\n", concat(aws_instance.miner.*.tags.Hostname))}"
    masternode_hosts  = "${join("\n", concat(aws_instance.masternode.*.tags.Hostname))}"
  }
}

output "ansible_inventory" {
  value = "${data.template_file.ansible_inventory.rendered}"
}
