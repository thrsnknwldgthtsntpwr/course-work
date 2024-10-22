resource "yandex_compute_disk" "nginx-2-disk" {
  name = "nginx-2-disk"
  type = "network-hdd"
  zone = "ru-central1-b"
  size = "10"
  image_id = "fd833v6c5tb0udvk4jo6"
}

resource "yandex_compute_instance" "nginx-2" {
  name = "nginx-2"
  allow_stopping_for_update = true
  platform_id = "standard-v3"
  zone = "ru-central1-b"

  resources {
    cores  = "2"
    memory = "1"
    core_fraction = "20"
  }

  boot_disk {
    disk_id = yandex_compute_disk.nginx-2-disk.id
  }

  scheduling_policy {
    preemptible = true
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.private-subnet-b.id
    security_group_ids = [ yandex_vpc_security_group.output.id, yandex_vpc_security_group.http.id, yandex_vpc_security_group.node-exporter.id, yandex_vpc_security_group.ssh.id,yandex_vpc_security_group.nginxlog-exporter.id ]
    nat = false
  }

  metadata = {
    ssh-keys = "thrsnknwldgthtsntpwr:ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCsnuVFBIrMkIeCUWkI3sV845WT3gbpeLX7KHnRnriGUXis/w/DV3kNP18wKKjtFFhj5Nfx5n9PmtXPXkf9uOugVKFDVg+j5MN23H0Y+KBA0rR+I7lHGzlSo3dc4TS/JeMChJ4iGVkaUh3w0Y86zd1JKQ4Tl5MB+cST9/aEzAYEMJ1yWRbeFcF0QSQwJMpu6BkOR3GB5ERX63J4U/KmESMbtFwpAt7BPNleGKa/0uEsr6amnhPE43vHsXEF5+l9FOnm0F1bNivira3Aldiia8jxwFXMdLD8qwz5c5/sSD0qLedCOGRazINyTK+3XHYOLohSJ7G0vThhq7QMmjKyDaOKru52rD1q+dRELyQm3fkoLpR1kF2ERe0veHfJ25W75yKQI3ks5SJUQXyyIWylu8RaQs2jlEJV2pUKVEKs/FeznYu0u/bPKMHxwhIou/uYAdLzIQqKdMaiQluvz1iP38kVAWlHzgY8ypd0dyOa6Y9woThHwU5UmYpbND5stjtq6BM= thrsnknwldgthtsntpwr@ubnt"
    user-data = "${file("meta.txt")}"
  }
}

output "nginx-2-ip-address" {
  value = yandex_compute_instance.nginx-2.network_interface.0.ip_address
}
