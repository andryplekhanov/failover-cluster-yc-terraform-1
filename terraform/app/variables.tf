variable "yc_folder" {
  type        = string
  description = "Yandex Cloud folder"
}

variable "yc_token" {
  type        = string
  description = "Yandex Cloud OAuth token"
  sensitive   = true
}

variable "user" {
  type        = string
  description = "$USER"
}
