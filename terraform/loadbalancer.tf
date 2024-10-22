# Параметры целевой группы

resource "yandex_alb_target_group" "nginx-target-group" {
  name           = "nginx-target-group"
  folder_id = "b1gc7skp45alnkd81b8v"
  target {
    subnet_id    = yandex_vpc_subnet.private-subnet-a.id
    ip_address   = yandex_compute_instance.nginx-1.network_interface.0.ip_address
  }

  target {
    subnet_id    = yandex_vpc_subnet.private-subnet-b.id
    ip_address   = yandex_compute_instance.nginx-2.network_interface.0.ip_address
  }
}

# Группа бэкэндов

resource "yandex_alb_backend_group" "nginx-backend-group" {
  name = "nginx-backend-group"
  folder_id = "b1gc7skp45alnkd81b8v"
  http_backend {
    name = "nginx-http-backend"
    port = "80"
  target_group_ids = [yandex_alb_target_group.nginx-target-group.id]
    healthcheck {
      timeout = "10s"
      interval = "10s"
      http_healthcheck {
        path = "/"
      }
    }
  }
}


# HTTP роутер
resource "yandex_alb_http_router" "nginx-http-router" {
  name      = "nginx-http-router"
  folder_id = "b1gc7skp45alnkd81b8v"
}

# Application load balancer

resource "yandex_alb_load_balancer" "nginx-load-balancer" {
  name = "nginx-load-balancer"
  folder_id = "b1gc7skp45alnkd81b8v"
  network_id = yandex_vpc_network.my-project-network.id
  allocation_policy {
    location {
      zone_id = "ru-central1-a"
      subnet_id = yandex_vpc_subnet.private-subnet-a.id
    }
    location {
      zone_id = "ru-central1-b"
      subnet_id = yandex_vpc_subnet.private-subnet-b.id
    }
  }
  listener {
    name = "nginx-load-balancer-listener"
    endpoint {
      address {
        external_ipv4_address {
        }
      }
      ports = [ 80 ]
    }
    http {
      handler {
        http_router_id = yandex_alb_http_router.nginx-http-router.id
      }
    }
  }
}

# Virtual host
resource "yandex_alb_virtual_host" "alb-virtual-host" {
  name = "alb-virtual-host"
  http_router_id = yandex_alb_http_router.nginx-http-router.id
  route {
    name = "http-route"
    http_route {
      http_route_action {
        backend_group_id = yandex_alb_backend_group.nginx-backend-group.id
        timeout = "3s"
      }
    }
  }
}

output "nginx-load-balancer-ip-address" {
  value = yandex_alb_load_balancer.nginx-load-balancer.listener.0.endpoint.0.address.0.external_ipv4_address[0].address
}
