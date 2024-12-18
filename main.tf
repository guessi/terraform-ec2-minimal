// get the latest ubuntu server 22.04 cloud image
// - ref: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami

data "aws_ami" "default" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

// IAM setup for Instance Connect

resource "aws_iam_instance_profile" "default" {
  name = "instance-profile-demo"
  role = aws_iam_role.default.name
}

data "aws_iam_policy_document" "default" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

data "aws_iam_policy" "AmazonSSMManagedInstanceCore" {
  arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "AmazonSSMManagedInstanceCore" {
  role       = aws_iam_role.default.name
  policy_arn = data.aws_iam_policy.AmazonSSMManagedInstanceCore.arn
}

resource "aws_iam_role" "default" {
  name               = "instance-profile-role-demo"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.default.json
}

// render boot up scripts with `cloudinit_config`
// - ref: https://registry.terraform.io/providers/hashicorp/cloudinit/latest/docs/data-sources/config

data "cloudinit_config" "default" {
  gzip          = true
  base64_encode = true

  part {
    filename     = "cloud-init.sh"
    content_type = "text/x-shellscript"

    content = <<-EOF
    #!/bin/bash

    # https://docs.aws.amazon.com/systems-manager/latest/userguide/agent-install-ubuntu-64-snap.html
    sudo snap install amazon-ssm-agent --classic
    sudo snap list amazon-ssm-agent
    sudo snap start amazon-ssm-agent
    sudo snap services amazon-ssm-agent

    sudo apt update
    sudo apt install -y apache2
    EOF
  }
}

// an ec2 instance with boot up script defined
// - ref: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance

resource "aws_instance" "default" {
  instance_type               = var.instance_type
  key_name                    = var.key_name
  ami                         = data.aws_ami.default.id
  associate_public_ip_address = true
  user_data_base64            = data.cloudinit_config.default.rendered

  root_block_device {
    volume_size = var.volume_size
    volume_type = var.volume_type
  }

  # follow security best practices to enfore IMDSv2
  # - ref: https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/configuring-instance-metadata-options.html
  metadata_options {
    http_endpoint               = "enabled"
    http_protocol_ipv6          = "disabled"
    http_put_response_hop_limit = "1"
    http_tokens                 = "required"
    instance_metadata_tags      = "disabled"
  }

  iam_instance_profile = aws_iam_instance_profile.default.id
}
