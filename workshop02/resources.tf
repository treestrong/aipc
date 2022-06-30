data digitalocean_ssh_key dokey {
    name = "do-key"
}

resource local_file dokey_public_key {
    filename = "do-key.pub"
    content = data.digitalocean_ssh_key.dokey.public_key
    file_permission = "0644"
}

output dokey_ssh_key_fingerprint {
    value = data.digitalocean_ssh_key.dokey.fingerprint
}
output dokey_ssh_key_id {
    value = data.digitalocean_ssh_key.dokey.id
}

/* --- to change tfstate to remote 

data terraform_remote_state nginx_droplet {
  backend = "s3"
  config = {
    skip_credentials_validation = true 
    skip_metadata_api_check = true 
    skip_region_validation = true
    endpoint = "https://sgp1.digitaloceanspaces.com"
    region = "sgp1"
    bucket = "bigbucket"
    key = "aipc/terraform.tfstate"
  }
}
--- */

resource digitalocean_droplet code-server {
  name = var.code_server
  image = var.DO_image
  size = var.DO_size
  region = var.DO_region
  ssh_keys = [ data.digitalocean_ssh_key.dokey.id ]
}

/* ---- Set A record in Cloudflare
resource cloudflare_record code-server {
  name = var.code_server
  zone_id = data.cloudflare_zone.chuklee.id 
  type = "A"
  value = digitalocean_droplet.code-server.ipv4_address
  proxied = true
}
---- */

resource local_file inventory_yaml {
  content = templatefile("inventory.yaml.tpl", {
    ssh_private_key = var.DO_private_key
    codeserver = var.code_server
    droplet_ip = digitalocean_droplet.code-server.ipv4_address
    codeserver_domain = "${var.code_server}.${var.cs_domain_name}"
    codeserver_password = var.cs_password
  })
  filename = "inventory.yaml"
  file_permission = "0444"
}

resource local_file root_at_nginx {
  content = ""
  filename = "root@${digitalocean_droplet.code-server.ipv4_address}"
}

output nginx_ip {
  value = digitalocean_droplet.code-server.ipv4_address
}

/*  --- check remote tfstate 
output nginx_from_day03a {
  value = data.terraform_remote_state.nginx_droplet.outputs.nginx_ip
}
--- */



