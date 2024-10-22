# elasticsearch
resource "yandex_compute_disk" "bastion-host-disk" {
  name = "bastion-host-disk"
  type = "network-hdd"
  zone = "ru-central1-a"
  size = "10"
  image_id = "fd833v6c5tb0udvk4jo6"
}


resource "yandex_compute_instance" "bastion-host" {
  name = "bastion-host"
  allow_stopping_for_update = true
  platform_id = "standard-v3"
  zone = "ru-central1-a"

  resources {
    cores  = 2
    memory = 2
    core_fraction = 20
  }

  boot_disk {
    disk_id = yandex_compute_disk.bastion-host-disk.id
    }

  scheduling_policy {
    preemptible = true
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.private-subnet-a.id
    security_group_ids = [ yandex_vpc_security_group.ssh.id, yandex_vpc_security_group.output.id ]
    nat = true
  }  

  metadata = {
    ssh-keys = "thrsnknwldgthtsntpwr:ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCsnuVFBIrMkIeCUWkI3sV845WT3gbpeLX7KHnRnriGUXis/w/DV3kNP18wKKjtFFhj5Nfx5n9PmtXPXkf9uOugVKFDVg+j5MN23H0Y+KBA0rR+I7lHGzlSo3dc4TS/JeMChJ4iGVkaUh3w0Y86zd1JKQ4Tl5MB+cST9/aEzAYEMJ1yWRbeFcF0QSQwJMpu6BkOR3GB5ERX63J4U/KmESMbtFwpAt7BPNleGKa/0uEsr6amnhPE43vHsXEF5+l9FOnm0F1bNivira3Aldiia8jxwFXMdLD8qwz5c5/sSD0qLedCOGRazINyTK+3XHYOLohSJ7G0vThhq7QMmjKyDaOKru52rD1q+dRELyQm3fkoLpR1kF2ERe0veHfJ25W75yKQI3ks5SJUQXyyIWylu8RaQs2jlEJV2pUKVEKs/FeznYu0u/bPKMHxwhIou/uYAdLzIQqKdMaiQluvz1iP38kVAWlHzgY8ypd0dyOa6Y9woThHwU5UmYpbND5stjtq6BM= thrsnknwldgthtsntpwr@ubnt"
    user-data = "${file("meta.txt")}"
  }
}

output "bastion-host-public-ip-address" {
  value = yandex_compute_instance.bastion-host.network_interface.0.nat_ip_address
}

output "bastion-host-private-ip-address" {
  value = yandex_compute_instance.bastion-host.network_interface.0.ip_address
}


resource "local_file" "hosts" {
  content = templatefile("../ansible/hosts.tpl",
    {
      nginx1 = yandex_compute_instance.nginx-1.network_interface.0.ip_address
      nginx2 = yandex_compute_instance.nginx-2.network_interface.0.ip_address
      prometheus = yandex_compute_instance.prometheus.network_interface.0.ip_address
      grafana = yandex_compute_instance.grafana.network_interface.0.ip_address
      elk = yandex_compute_instance.elk.network_interface.0.ip_address
    }
  )
  filename = "../ansible/hosts"
}

resource "local_file" "prometheus-cfg" {
  content = templatefile("../ansible/prometheus-cfg.tpl",
    {
      nginx1 = yandex_compute_instance.nginx-1.network_interface.0.ip_address
      nginx2 = yandex_compute_instance.nginx-2.network_interface.0.ip_address
    }
  )
  filename = "../ansible/prometheus-files/prometheus.yml"

}


resource "null_resource" "ansible" {
    connection {
      type        = "ssh"
      user        = local.user
      private_key = file(local.private_key)
      host = yandex_compute_instance.bastion-host.network_interface.0.nat_ip_address
    }

  provisioner "file"{
    source = "../ansible"
    destination = "/tmp"
  }

  provisioner "file"{
    source = "../distrs"
    destination = "/tmp"
  }


  provisioner "remote-exec" {
    inline = [
      "cd /tmp/ansible",
      "sudo apt install ansible -y",
      "sudo chmod 600 id_rsa",
      "ANSIBLE_HOST_KEY_CHECKING=False /usr/bin/ansible-playbook -i /tmp/ansible/hosts -u ${local.user} --private-key /tmp/ansible/id_rsa /tmp/ansible/nginx.yml",
      "ANSIBLE_HOST_KEY_CHECKING=False /usr/bin/ansible-playbook -i /tmp/ansible/hosts -u ${local.user} --private-key /tmp/ansible/id_rsa /tmp/ansible/prometheus.yml",
      "ANSIBLE_HOST_KEY_CHECKING=False /usr/bin/ansible-playbook -i /tmp/ansible/hosts -u ${local.user} --private-key /tmp/ansible/id_rsa /tmp/ansible/grafana.yml",
      "ANSIBLE_HOST_KEY_CHECKING=False /usr/bin/ansible-playbook -i /tmp/ansible/hosts -u ${local.user} --private-key /tmp/ansible/id_rsa /tmp/ansible/elk.yml"
      ]
  }
}
