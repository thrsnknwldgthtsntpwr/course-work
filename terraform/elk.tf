# elasticsearch
resource "yandex_compute_disk" "elk-disk" {
  name = "elk-disk"
  type = "network-hdd"
  zone = "ru-central1-a"
  size = "20"
  image_id = "fd833v6c5tb0udvk4jo6"
}


resource "yandex_compute_instance" "elk" {
  name = "elk"
  allow_stopping_for_update = true
  platform_id = "standard-v3"
  zone = "ru-central1-a"

  resources {
    cores  = 2
    memory = 4
    core_fraction = 20
  }

  boot_disk {
    disk_id = yandex_compute_disk.elk-disk.id
    }

  scheduling_policy {
    preemptible = true
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.private-subnet-a.id
    security_group_ids = [ yandex_vpc_security_group.ssh.id, yandex_vpc_security_group.kibana.id, yandex_vpc_security_group.elasticsearch.id, yandex_vpc_security_group.output.id ]
    nat = true
  }  
  metadata = {
    ssh-keys = "thrsnknwldgthtsntpwr:ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDoCNU3rTEFJ7zvDUh93RU+JcdtGATApempNGCaCue9n+eMjELJ8EJqrSJWWeDAgUw9Vx0gRUkJOYbcqKA9Cmh+9thuvESMgi7FBsgVTsn6sCGmNSciK69ICDi7bzXey7WRVvpAMDfP1qwJV4iTkyVOiXh3bHputqkSCQpD4HD4ujoD7AI81R/xKpb5IDE50ZA00sMNv4jZAU4Y9iV131rRoE8d3OsBf815olbWKRXBrjL77b26X/DvNq1hJMNR5VNoUqgQ2xf20rettzsXyIxhMMtxhAt2EW53xX3IbZK9mxh9c8nRSmyCM+uFGzpdiRdKUtBmZNyRfCUQBgxKbYWmMJKNiuB14W4e4AlpsLBIa5fRTYvN+9EXWCZoq5eEDjoYMTTs3vT/sm9Shy1mmni87JCQNe6OY0XjGT2QB+tNOYk+aJezGpC2dzPUs+nJfPbgAbvK+27YCVZ/Pmesf1fM3dhAUesxCMJJAcu8fJ3GSZkoqFUuM74U+REpHNutdbM= thrsnknwldgthtsntpwr@RN"
    user-data = "${file("meta.txt")}"
  }
}

output "elk-ip-address" {
  value = yandex_compute_instance.elk.network_interface.0.nat_ip_address
}
