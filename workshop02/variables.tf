variable DO_token {
    type = string 
    sensitive = true
}

variable DO_private_key {
    type = string 
    sensitive = true
    default = "../.ssh/do-key" 
}

variable DO_image {
    type = string
    default = "ubuntu-20-04-x64"
}
variable DO_region {
    type = string
    default = "sgp1"
}
variable DO_size {
    type = string
    default = "s-1vcpu-1gb"
}

variable ports {
    type = list(number)
    default = [ 8080, 8081, 8082, 8083 ]
}

variable containers {
    type = map(object({
        external_port = number
    }))

    default = {
        abc = {
            external_port = 1234
        }
        xyz = {
            external_port = 9090
        }
    }
}

variable docker_host_ip {
  type = string
}

variable app_instances {
  type = number
  default = 4
}

variable code_server {
  type = string
  default = "codeserver"
}

variable cs_domain_name {
  type = string
  default = "treestrong.com"
}

variable cs_password {
  type = string
}