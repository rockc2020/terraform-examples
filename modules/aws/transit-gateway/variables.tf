variable "name" {
  type        = string
  description = "Name to use when creating resources. May be used as a prefix."
}

variable "description" {
  type        = string
  description = "Descrption to set on the TGW"
}

variable "vpc_attachments" {
  type = map(object({
    vpc_id           = string
    subnet_ids       = list(string)
    route_table_ids  = list(string)
    destination_cidr = string
  }))
  description = "VPC attachments to the TGW"
}
