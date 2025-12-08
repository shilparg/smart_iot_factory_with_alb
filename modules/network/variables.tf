# modules/network/variables.tf

variable "vpc_cidr" {
  type        = string
  description = "CIDR block for the VPC"
  default     = "10.0.0.0/16"
}

variable "environment" {
  type    = string
  default = "dev"
  description = "Deployment environment (e.g., dev, staging, prod)"
}

variable "allowed_cidr" {
  type        = string
  default     = "0.0.0.0/0"
  description = "CIDR block allowed to access EC2/ECS services (e.g., SSH, Grafana, Prometheus)"
}

# --- CHANGE THIS ---
variable "public_subnet_cidrs" {
  type        = list(string)
  description = "List of CIDR blocks for public subnets (e.g. ['10.0.1.0/24', '10.0.2.0/24'])"
  default     = ["10.0.1.0/24", "10.0.2.0/24"] # Default to 2 subnets
}