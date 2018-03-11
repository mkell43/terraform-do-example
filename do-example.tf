variable "do_token" {}

provider "digitalocean" {
  token = "${var.do_token}"
}

resource "digitalocean_ssh_key" "default" {
  name       = "Terraform Test"
  public_key = "${file("./terraform-key.pub")}"
}

/* All three are the same except for name.  The SSH key fingerprint is taken
from the one just uploaded. */
resource "digitalocean_droplet" "bastion" {
  image              = "ubuntu-14-04-x64"
  name               = "bastion"
  region             = "nyc3"
  size               = "s-1vcpu-1gb"
  private_networking = "true"
  ssh_keys           = ["${digitalocean_ssh_key.default.fingerprint}"]
}

resource "digitalocean_droplet" "web" {
  image              = "ubuntu-14-04-x64"
  name               = "web-1"
  region             = "nyc3"
  size               = "s-1vcpu-1gb"
  private_networking = "true"
  ssh_keys = ["${digitalocean_ssh_key.default.fingerprint}"]
}

resource "digitalocean_droplet" "mysql" {
  image              = "ubuntu-14-04-x64"
  name               = "mysql-1"
  region             = "nyc3"
  size               = "s-1vcpu-1gb"
  private_networking = "true"
  ssh_keys = ["${digitalocean_ssh_key.default.fingerprint}"]
}

# Only allow SSH from the world.
resource "digitalocean_firewall" "bastion" {
  name = "bastion"

  droplet_ids = ["${digitalocean_droplet.bastion.id}"]

  inbound_rule = [
    {
      protocol           = "tcp"
      port_range         = "22"
      source_addresses   = ["0.0.0.0/0", "::/0"]
    },
  ]

  outbound_rule = [
    {
      protocol                = "tcp"
      port_range              = "all"
      destination_addresses   = ["0.0.0.0/0", "::/0"]
    },
    {
      protocol                = "udp"
      port_range              = "all"
      destination_addresses   = ["0.0.0.0/0", "::/0"]
    },
  ]
}

# Only allow HTTP/S traffic from the world and SSH from the bastion host.
resource "digitalocean_firewall" "web" {
  name = "web"

  droplet_ids = ["${digitalocean_droplet.web.id}"]

  inbound_rule = [
    {
      protocol           = "tcp"
      port_range         = "80"
      source_addresses   = ["0.0.0.0/0", "::/0"]
    },
    {
      protocol           = "tcp"
      port_range         = "443"
      source_addresses   = ["0.0.0.0/0", "::/0"]
    },
    {
      protocol           = "tcp"
      port_range         = "22"
      source_addresses   = ["${digitalocean_droplet.bastion.ipv4_address_private}"]
    }
  ]

  outbound_rule = [
    {
      protocol                = "tcp"
      port_range              = "all"
      destination_addresses   = ["0.0.0.0/0", "::/0"]
    },
    {
      protocol                = "udp"
      port_range              = "all"
      destination_addresses   = ["0.0.0.0/0", "::/0"]
    },
  ]
}

# Only allow MySQL from the world and SSH from the bastion host.
resource "digitalocean_firewall" "mysql" {
  name = "mysql"

  droplet_ids = ["${digitalocean_droplet.mysql.id}"]

  inbound_rule = [
    {
      protocol           = "tcp"
      port_range         = "3306"
      source_addresses   = ["0.0.0.0/0", "::/0"]
    },
    {
      protocol           = "tcp"
      port_range         = "22"
      source_addresses   = ["${digitalocean_droplet.bastion.ipv4_address_private}"]
    }
  ]

  outbound_rule = [
    {
      protocol                = "tcp"
      port_range              = "all"
      destination_addresses   = ["0.0.0.0/0", "::/0"]
    },
    {
      protocol                = "udp"
      port_range              = "all"
      destination_addresses   = ["0.0.0.0/0", "::/0"]
    },
  ]
}
