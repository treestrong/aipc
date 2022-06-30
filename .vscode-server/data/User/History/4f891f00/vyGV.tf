resource docker_image nwdb-image {
    name = "stackupiss/northwind-db:${var.nwdb_tag}"
}
resource docker_image nwapp-image {
    name = "stackupiss/northwind-app:${var.nwapp_tag}"
}

resource docker_network mynet {
    name = var.mynet
}

resource docker_volume nwdb-vol {
    name = "nwdb-vol"
}

resource docker_container nwdb {
    name = "nwdb"
    image = docker_image.nwdb-image.latest
    networks_advanced {
        name = docker_network.mynet.name
    }
    volumes {
        volume_name = docker_volume.nwdb-vol.name
        container_path = "/var/lib/mysql"
    }
    ports {
        internal = 3306
        external = 3306
    }
}

resource docker_container nwapp {
    name = "nwapp"
    image = docker_image.nwapp-image.latest
    networks_advanced {
        name = docker_network.mynet.name
    }
    env = [
        "DB_USER=${var.DB_user}",
        "DB_PASSWORD=${var.DB_password}",
        "DB_HOST=${docker_container.nwdb.name}",
    ]
    ports {
        internal = 3000
        external = 3000
    }
}
