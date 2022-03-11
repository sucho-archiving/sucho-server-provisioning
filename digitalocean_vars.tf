variable "do_token" {
  description = "DigitalOcean API token"
}

variable "ssh_fingerprint" {
  description = "Fingerprint of SSH key already uploaded to DO (will allow access to the root account)"
}

variable "droplet_image" {
  description = "Image identifier for the OS in DigitalOcean"
  default     = "debian-11-x64"
}

variable "droplet_region" {
  description = "Region identifier where the droplet will be created"
  default     = "sfo3"
}

variable "droplet_size" {
  description = "Droplet size identifier"
  default     = "s-1vcpu-1gb"
}
