# modules/ecr/variables.tf

variable "repository_name" {
  description = "The name of the ECR repository"
  type        = string
  default     = "iot-simulator"
}

variable "environment" {
  type        = string
  description = "The deployment environment (e.g., dev, prod)"
}

variable "image_mutability" {
  type        = string
  default     = "MUTABLE" # 'MUTABLE' allows overwriting tags (good for dev). Use 'IMMUTABLE' for prod.
  description = "The tag mutability setting for the repository"
}