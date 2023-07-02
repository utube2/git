variable "region"{}

variable "profile"{}

variable "cidr_block"{
    type = list(string)
}

variable "name" {
    type = list(string)
}

variable "key_name"{}

variable "instance_type"{}

#variable "each" {
#    type = list(string)
#}
