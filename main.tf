terraform {
  required_providers {
    digitalocean = {
      source = "digitalocean/digitalocean"
    }
  }
}

provider "digitalocean" {
  token = var.do_token
}

locals {
  yaml_files = fileset(path.module, "droplets/*.yaml")
  yaml_data  = [for f in local.yaml_files : yamldecode(file("${path.module}/${f}"))]
}

resource "digitalocean_volume" "browsertrix" {
  for_each                = { for o in local.yaml_data : o.droplet_name => o }
  region                  = var.droplet_region
  name                    = "${lower(each.value.droplet_name)}-volume"
  size                    = each.value.volume_size
  initial_filesystem_type = "ext4"
  tags                    = []
}

resource "digitalocean_droplet" "browsertrix" {
  for_each   = { for o in local.yaml_data : o.droplet_name => o }
  image      = var.droplet_image
  name       = each.value.droplet_name
  region     = var.droplet_region
  size       = var.droplet_size
  tags       = [each.value.user]
  backups    = false
  monitoring = false
  ssh_keys = [
    var.ssh_fingerprint
  ]

  volume_ids = ["${digitalocean_volume.browsertrix[each.key].id}"]

  provisioner "remote-exec" {
    inline = ["apt-mark hold linux-virtual", "apt update", "apt upgrade -y", "echo Done!"]

    connection {
      host = self.ipv4_address
      type = "ssh"
      user = "root"
    }
  }

  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command     = <<-EOT
    ANSIBLE_HOST_KEY_CHECKING=False \
    ansible-playbook \
      -u root \
      -i '${self.ipv4_address},' \
      -e 'user=${each.value.user}' \
      -e 'pub_key="${each.value.public_key}"' \
      -e 'volume_name="${lower(each.value.droplet_name)}-volume"' \
      browsertrix.playbook.yaml
    EOT
  }
}

output "droplet_ip_address" {
  value = tomap({
    for name, vm in digitalocean_droplet.browsertrix : name => format("%s (%s)", vm.ipv4_address, join(", ", vm.tags))
  })
}

