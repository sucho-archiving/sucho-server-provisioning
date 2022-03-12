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
}

output "droplet_ip_address" {
  value = tomap({
    for name, vm in digitalocean_droplet.browsertrix : name => format("%s (%s)", vm.ipv4_address, join(", ", vm.tags))
  })
}

