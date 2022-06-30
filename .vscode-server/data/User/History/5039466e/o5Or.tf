variable DO_token {
    type = string 
    sensitive = true
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


variable mynet {
    type = string
    default = "mynet"
} 

variable DB_user {
    type = string
    default = "root"
}
variable DB_password {
    type = string
    sensitive = true
}

variable nwdb_tag {
    type = string
    default = "v1"
}
variable nwapp_tag {
    type = string
    default = "v1"
}
Footer
© 2022 GitHub, Inc.
Footer navigation
Terms
