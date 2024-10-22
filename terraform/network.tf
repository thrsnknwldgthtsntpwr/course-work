# Сеть

# VPC
resource "yandex_vpc_network" "my-project-network" {
  name = "my-project-network"
  folder_id = "b1gc7skp45alnkd81b8v"
}

# Приватные подсети
resource "yandex_vpc_subnet" "private-subnet-a" {
  name = "private-subnet-a"
  description = "Приватная подсеть в зоне доступности ru-central1-a"
  v4_cidr_blocks = ["192.168.10.0/24"]
  zone = "ru-central1-a"
  network_id = yandex_vpc_network.my-project-network.id
  route_table_id = yandex_vpc_route_table.private-subnets-routing-table.id
}

resource "yandex_vpc_subnet" "private-subnet-b" {
  name = "private-subnet-b"
  description = "Приватная подсеть в зоне доступности ru-central1-b"
  v4_cidr_blocks = ["192.168.20.0/24"]
  zone = "ru-central1-b"
  network_id = yandex_vpc_network.my-project-network.id
  route_table_id = yandex_vpc_route_table.private-subnets-routing-table.id
}

# NAT шлюз для приватных подсетей

resource "yandex_vpc_gateway" "private-subnets-nat-gw" {
  folder_id = "b1gc7skp45alnkd81b8v"
  name = "private-subnets-nat-gw"
  shared_egress_gateway {}
}

# Таблица маршрутизации для приватных сетей

resource "yandex_vpc_route_table" "private-subnets-routing-table" {
  folder_id = "b1gc7skp45alnkd81b8v"
  name = "private-subnets-routing-table"
  network_id = yandex_vpc_network.my-project-network.id

  static_route {
    destination_prefix = "0.0.0.0/0"
    gateway_id = yandex_vpc_gateway.private-subnets-nat-gw.id
  }
}
