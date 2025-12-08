# modules/iot/variables.tf

variable "region" {
  type        = string
  description = "AWS region where resources will be deployed (e.g., ap-southeast-1)"
}

variable "environment" {
  type        = string
  description = "Deployment environment identifier (e.g., dev, staging, prod)"
}

variable "iot_topic" {
  type        = string
  description = "IoT Core MQTT topic used by simulator instances for publishing messages"
}