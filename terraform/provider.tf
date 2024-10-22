## Конфиг провайдера
terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.13"
}

provider "yandex" {
  zone = "ru-central1-a"
  token = var.cloud-token
  cloud_id  = "b1gmrdbulmjk5vov6tbl"
  folder_id = "b1gc7skp45alnkd81b8v"
}

variable "cloud-token" {
  type = string

}
