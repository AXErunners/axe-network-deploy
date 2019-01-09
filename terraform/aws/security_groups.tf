resource "aws_security_group" "default" {
  name        = "${terraform.workspace}-ssh"
  description = "ssh access"
  vpc_id      = "${aws_vpc.default.id}"

  # SSH access from anywhere
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    description = "SSH"

    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }

  # Docker API
  ingress {
    from_port   = "${var.docker_port}"
    to_port     = "${var.docker_port}"
    protocol    = "tcp"
    description = "Docker API"

    cidr_blocks = [
      "${var.private_subnet}",
      "${aws_eip.vpn.public_ip}/32",
    ]
  }

  # outbound internet access
  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"

    cidr_blocks = [
      "0.0.0.0/0",
      "${var.private_subnet}",
    ]
  }

  tags = {
    Name        = "dn-${terraform.workspace}-default"
    AxeNetwork = "${terraform.workspace}"
  }
}

# axed nodes not accessible from the public internet
resource "aws_security_group" "axed_private" {
  name        = "${terraform.workspace}-axed-private"
  description = "axed private node"
  vpc_id      = "${aws_vpc.default.id}"

  # Axe Core access
  ingress {
    from_port   = "${var.axed_port}"
    to_port     = "${var.axed_port}"
    protocol    = "tcp"
    description = "AxeCore P2P"

    cidr_blocks = [
      "${var.private_subnet}",
    ]
  }

  # AxeCore RPC access
  ingress {
    from_port   = "${var.axed_rpc_port}"
    to_port     = "${var.axed_rpc_port}"
    protocol    = "tcp"
    description = "AxeCore RPC"

    cidr_blocks = [
      "${var.private_subnet}",
      "${aws_eip.vpn.public_ip}/32",
    ]
  }

  # AxeCore ZMQ acess
  ingress {
    from_port   = "${var.axed_zmq_port}"
    to_port     = "${var.axed_zmq_port}"
    protocol    = "tcp"
    description = "AxeCore ZMQ"

    cidr_blocks = [
      "${var.private_subnet}",
      "${aws_eip.vpn.public_ip}/32",
    ]
  }

  tags = {
    Name        = "dn-${terraform.workspace}-axed-private"
    AxeNetwork = "${terraform.workspace}"
  }
}

# axed node accessible from the public internet
resource "aws_security_group" "axed_public" {
  name        = "${terraform.workspace}-axed-public"
  description = "axed public network"
  vpc_id      = "${aws_vpc.default.id}"

  # Axe Core access
  ingress {
    from_port   = "${var.axed_port}"
    to_port     = "${var.axed_port}"
    protocol    = "tcp"
    description = "AxeCore P2P"

    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }

  # AxeCore RPC access
  ingress {
    from_port   = "${var.axed_rpc_port}"
    to_port     = "${var.axed_rpc_port}"
    protocol    = "tcp"
    description = "AxeCore RPC"

    cidr_blocks = [
      "${var.private_subnet}",
      "${aws_eip.vpn.public_ip}/32",
    ]
  }

  # AxeCore ZMQ acess
  ingress {
    from_port   = "${var.axed_zmq_port}"
    to_port     = "${var.axed_zmq_port}"
    protocol    = "tcp"
    description = "AxeCore ZMQ"

    cidr_blocks = [
      "${var.private_subnet}",
      "${aws_eip.vpn.public_ip}/32",
    ]
  }

  tags = {
    Name        = "dn-${terraform.workspace}-axed-public"
    AxeNetwork = "${terraform.workspace}"
  }
}

resource "aws_security_group" "http" {
  name        = "${terraform.workspace}-http"
  description = "web node"
  vpc_id      = "${aws_vpc.default.id}"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    description = "Faucet"

    cidr_blocks = [
      "${var.private_subnet}",
      "${aws_eip.vpn.public_ip}/32",
    ]
  }

  ingress {
    from_port   = "${var.insight_port}"
    to_port     = "${var.insight_port}"
    protocol    = "tcp"
    description = "Insight Explorer"

    cidr_blocks = [
      "${var.private_subnet}",
      "${aws_eip.vpn.public_ip}/32",
    ]
  }

  tags = {
    Name        = "dn-${terraform.workspace}-http"
    AxeNetwork = "${terraform.workspace}"
  }
}

# axed node accessible from the public internet
resource "aws_security_group" "masternode" {
  name        = "${terraform.workspace}-masternode"
  description = "masternode"
  vpc_id      = "${aws_vpc.default.id}"

  # IPFS swarm
  ingress {
    from_port   = "${var.ipfs_swarm_port}"
    to_port     = "${var.ipfs_swarm_port}"
    protocol    = "tcp"
    description = "IPFS swarm"

    cidr_blocks = [
      "${var.private_subnet}",
    ]
  }

  # IPFS API
  ingress {
    from_port   = "${var.ipfs_api_port}"
    to_port     = "${var.ipfs_api_port}"
    protocol    = "tcp"
    description = "IPFS API"

    cidr_blocks = [
      "${var.private_subnet}",
      "${aws_eip.vpn.public_ip}/32",
    ]
  }

  # Insight API access
  ingress {
    from_port   = "${var.insight_port}"
    to_port     = "${var.insight_port}"
    protocol    = "tcp"
    description = "Insight API"

    cidr_blocks = [
      "${var.private_subnet}",
      "${aws_eip.vpn.public_ip}/32",
    ]
  }

  # Drive
  ingress {
    from_port   = "${var.drive_port}"
    to_port     = "${var.drive_port}"
    protocol    = "tcp"
    description = "Drive"

    cidr_blocks = [
      "${var.private_subnet}",
      "${aws_eip.vpn.public_ip}/32",
    ]
  }

  # DAPI
  ingress {
    from_port   = "${var.dapi_port}"
    to_port     = "${var.dapi_port}"
    protocol    = "tcp"
    description = "DAPI"

    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }

  tags = {
    Name        = "dn-${terraform.workspace}-masternode"
    AxeNetwork = "${terraform.workspace}"
  }
}

# A security group for the ELB so it is accessible via the web
resource "aws_security_group" "elb" {
  name   = "${terraform.workspace}-elb"
  vpc_id = "${aws_vpc.default.id}"

  # HTTP access from anywhere
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    description = "HTTP"

    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }

  # Insight Explorer
  ingress {
    from_port   = "${var.insight_port}"
    to_port     = "${var.insight_port}"
    protocol    = "tcp"
    description = "Insight Explorer"

    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }

  # outbound internet access
  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"

    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }

  tags = {
    Name        = "dn-${terraform.workspace}-elb"
    AxeNetwork = "${terraform.workspace}"
  }
}

resource "aws_security_group" "vpn" {
  count = "${var.vpn_enabled ? 1 : 0}"

  name        = "${terraform.workspace}-vpn"
  description = "vpn client access"
  vpc_id      = "${aws_vpc.default.id}"

  # SSH access from anywhere
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    description = "SSH"

    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }

  # VPN Client
  ingress {
    from_port   = "${var.vpn_port}"
    to_port     = "${var.vpn_port}"
    protocol    = "udp"
    description = "VPN client"

    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }

  # outbound internet access
  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"

    cidr_blocks = [
      "0.0.0.0/0",
      "${var.private_subnet}",
    ]
  }

  tags = {
    Name        = "dn-${terraform.workspace}-vpn"
    AxeNetwork = "${terraform.workspace}"
  }
}
