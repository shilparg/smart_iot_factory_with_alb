# module/shared-alb/variables.tf

variable "vpc_id" {}
variable "public_subnets" { type = list(string) }
variable "name_prefix" { default = "shared" }