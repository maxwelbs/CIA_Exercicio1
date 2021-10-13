variable  "vpc_id" {
  type        = string
}

variable "subnet_cidr" {
  type        = string
}

variable "tipo_instancia_slack" {
  type        = string
}

variable "tipo_instancia_mongodb" {
  type        = string
}

variable "app_tags" {
    type = map
}

variable "ssh_key" {
    type = string
}

variable "app_name" {
    type = string
}