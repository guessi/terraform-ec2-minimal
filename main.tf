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
    sudo apt update
    sudo apt install -y apache2
    EOF
  }
}

// an ec2 instance with boot up script defined
// - ref: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance

resource "aws_instance" "default" {
  instance_type    = var.instance_type
  key_name         = var.key_name
  ami              = data.aws_ami.default.id
  user_data_base64 = data.cloudinit_config.default.rendered
}
