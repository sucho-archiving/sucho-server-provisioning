# sucho-server-provisioning

Terraform scripts for server provisioning


## Setup

1. Install Ansible locally (<https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html>)

2. Create a Digital Ocean Personal Access Token to use as an API key (<https://docs.digitalocean.com/reference/api/create-personal-access-token/>)

3. Upload an SSH public key to Digital Ocean (<https://docs.digitalocean.com/products/droplets/how-to/add-ssh-keys/to-account/>), and copy the fingerprint that's created (`<admin-ssh-key-fingerprint>` below)

4. Checkout this repo and `cd` into it


## Usage

1. Create a droplet:

   ```sh
   doctl compute droplet create --region fra1 --image ubuntu-20-04-x64 --size s-8vcpu-16gb <droplet-name> --ssh-keys <admin-ssh-key-fingerprint>
   ```

2. Find the IP address of the newly-created droplet (`<do-droplet-id>` below):

   ```sh
   doctl compute droplet get <droplet-name> --format PublicIPv4

   ```

3. Run the playbook against the droplet:

   ```sh
   ansible-playbook -u root -i '<do-droplet-ip>,' -e "user=<user-to-configure>" -e "pub_key='$(</path-to-ssh-public-key)'" browsertrix.playbook.yaml
   ```

   You can read the SSH public key from a file, as in the example above, or just provide it as a string.

