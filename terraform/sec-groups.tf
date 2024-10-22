resource "yandex_vpc_security_group" "http" {
    network_id = yandex_vpc_network.my-project-network.id
    name = "http"

    ingress {
        protocol = "TCP"
        port = "80"
        v4_cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "yandex_vpc_security_group" "kibana" {
    network_id = yandex_vpc_network.my-project-network.id
    name = "kibana"

    ingress {
        protocol = "TCP"
        port = "5601"
        v4_cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "yandex_vpc_security_group" "elasticsearch" {
    network_id = yandex_vpc_network.my-project-network.id
    name = "elasticsearch"

    ingress {
        protocol = "TCP"
        port = "9200"
        v4_cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "yandex_vpc_security_group" "ssh" {
    name = "ssh"
    network_id = yandex_vpc_network.my-project-network.id
    ingress {
        protocol = "TCP"
        port = "22"
        v4_cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "yandex_vpc_security_group" "grafana" {
    name = "grafana"
    network_id = yandex_vpc_network.my-project-network.id
    ingress {
        protocol = "TCP"
        port = "3000"
        v4_cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "yandex_vpc_security_group" "prometheus" {
    name = "prometheus"
    network_id = yandex_vpc_network.my-project-network.id
    ingress {
        protocol = "TCP"
        port = "9090"
        v4_cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "yandex_vpc_security_group" "node-exporter" {
    name = "node-exporter"
    network_id = yandex_vpc_network.my-project-network.id
    ingress {
        protocol = "TCP"
        port = "9100"
        v4_cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "yandex_vpc_security_group" "nginxlog-exporter" {
    name = "nginxlog-exporter"
    network_id = yandex_vpc_network.my-project-network.id
    ingress {
        protocol = "TCP"
        port = "4040"
        v4_cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "yandex_vpc_security_group" "output" {
    name = "output"
    network_id = yandex_vpc_network.my-project-network.id
    egress {
        protocol = "any"
        v4_cidr_blocks = ["0.0.0.0/0"]
    }
}
