# sucho-server-provisioning

Terraform scripts for server provisioning


## Setup

1. Install Terraform locally (<https://www.terraform.io/downloads>) and Ansible locally (<https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html>)

2. Download the terraform-backend-git from <https://github.com/plumber-cd/terraform-backend-git/releases/tag/v0.0.17> and put it somewhere on your `$PATH`

3. Create a Digital Ocean Personal Access Token to use as an API key (<https://docs.digitalocean.com/reference/api/create-personal-access-token/>)

4. Upload an SSH public key to Digital Ocean (<https://docs.digitalocean.com/products/droplets/how-to/add-ssh-keys/to-account/>), and copy the fingerprint that's created

5. Checkout this repo and `cd` into it

6. `/path/to/terraform-backend-git git terraform init`


## Usage

The current state is determined by the `*.yaml` files in `droplets/`.  Adding a new file there (and running `terraform apply`) creates a new droplet.  Removing a file (and running `terraform apply`) destroys that droplet.

1. `export DO_TOKEN=<your-digital-ocean-pat>`

2. `export SSH_FINGERPRINT=<the-fingerprint-of-your-uploaded-ssh-key>`

3. Copy `droplets/droplet.yaml.example` to a new file, and update the values as appopriate

4. `/path/to/terraform-backend-git git terraform apply -var "do_token=${DO_TOKEN}" -var "ssh_fingerprint=${SSH_FINGERPRINT}"`

5. To destroy a droplet, remove the `.yaml` file and run the `terraform apply` command above again.  **Don't run** `terraform destroy`!

6. When files have been added/updated/removed from `droplets/`, the changes should be committed to this repo so that other admins can pull them before making further changes.
  
  