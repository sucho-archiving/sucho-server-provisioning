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
  name                    = "${each.value.droplet_name}-volume"
  size                    = each.value.volume_size
  initial_filesystem_type = "ext4"
  description             = "an example volume"
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

  provisioner "remote-exec" {
    inline = ["apt update", "apt-mark hold linux-image-amd64", "apt upgrade -y", "echo Done!"]

    connection {
      host = self.ipv4_address
      type = "ssh"
      user = "root"
      # private_key = file(var.pvt_key)
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
      browsertrix.playbook.yaml
    EOT
  }
}

resource "digitalocean_volume_attachment" "browsertrix" {
  for_each   = { for o in local.yaml_data : o.droplet_name => o }
  droplet_id = digitalocean_droplet.browsertrix[each.key].id
  volume_id  = digitalocean_volume.browsertrix[each.key].id
}

output "droplet_ip_address" {
  value = tomap({
    for name, vm in digitalocean_droplet.browsertrix : name => format("%s (%s)", vm.ipv4_address, join(", ", vm.tags))
  })
}

