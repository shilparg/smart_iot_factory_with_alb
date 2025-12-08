# modules/iot-simulator-ecs/variables.tf

variable "region" {}
variable "cluster_id" {}
variable "vpc_id" {}
variable "subnets" { type = list(string) }
variable "security_groups" { type = list(string) }
variable "app_image_uri" {}

# Passed from S3 Module
variable "config_bucket" {}
variable "cert_bucket" {}

# Passed from IoT Module
variable "aws_iot_endpoint" {}

# App Specifics
variable "simulator_count" { default = 5 }
variable "iot_topic" { default = "factory/simulator" }
variable "account_id" {}

variable "iot_endpoint" {
  description = "The AWS IoT Core endpoint (e.g., xxxxx-ats.iot.us-east-1.amazonaws.com)"
  type        = string
}

variable "repository_url" {
  description = "The URL of the ECR repository"
  type        = string
}

# Connection details from the Shared ALB module
variable "alb_listener_arn" {
  description = "ARN of the shared ALB listener"
  type        = string
}

variable "alb_security_group_id" {
  description = "Security Group ID of the ALB (to allow traffic)"
  type        = string
}