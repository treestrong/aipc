data digitalocean_ssh_key treestrong {
    name = "treestrong-key"
}

resource local_file treestrong_public_key {
    filename = "treestrong.pub"
    content = data.digitalocean_ssh_key.treestrong.public_key
    file_permission = "0644"
}

output treestrong_ssh_key_fingerprint {
    value = data.digitalocean_ssh_key.treestrong.fingerprint
}
output treestrong_ssh_key_id {
    value = data.digitalocean_ssh_key.treestrong.id
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
  ssh_keys = [ data.digitalocean_ssh_key.chuk.id ]
}

resource cloudflare_record code-server {
  name = var.code_server
  zone_id = data.cloudflare_zone.chuklee.id 
  type = "A"
  value = digitalocean_droplet.code-server.ipv4_address
  proxied = true
}

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

output nginx_from_day03a {
  value = data.terraform_remote_state.nginx_droplet.outputs.nginx_ip
}


/////////


data docker_image dov-bear {
    name = "chukmunnlee/dov-bear:v2"
}

resource docker_container dov-bear-container {
    count = length(var.ports)
    name = "dov-bear-${count.index}"
    image = data.docker_image.dov-bear.id
    env = [
        "INSTANCE_NAME=myapp-${count.index}",
        "INSTANCE_HASH=${count.index}"
    ]
    ports {
        internal = 3000
        external = var.ports[count.index]
    }
}


resource docker_container dov-bear-unique {
    for_each = var.containers
    name = each.key
    image = data.docker_image.dov-bear.id
    env = [
        "INSTANCE_NAME=${each.key}"
    ]
    ports {
        internal = 3000
        external = each.value.external_port
    }
}


resource local_file container-name {
    content = join(", ", [ for c in docker_container.dov-bear-container: c.name ])
    filename = "container-names.txt"
    file_permission = "0644"
}

/* ---- */
resource digitalocean_droplet nginx {
    name = "nginx"
    image = var.DO_image
    size = var.DO_size
    region = var.DO_region
    ssh_keys = [ data.digitalocean_ssh_key.treestrong.id ]
    connection {
        type = "ssh"
        user = "root"
        private_key = file("./digitalocean-ts") 
        host = self.ipv4_address
    }
    provisioner remote-exec {
        inline = [
            "apt update",
            "apt install nginx -y",
            "systemctl enable nginx",
            "systemctl start nginx"
        ]
    }
}

resource local_file root_at_nginx {
    content = ""
    filename = "root@${digitalocean_droplet.nginx.ipv4_address}"
}

output nginx_ip {
    value = digitalocean_droplet.nginx.ipv4_address
}
output dov-bar-md5 {
    value = data.docker_image.dov-bear.repo_digest
    description = "SHA of the image"
}

output container-names {
    value = [ for c in docker_container.dov-bear-container: c.name ]
}



