# /root/main.tf

data "aws_availability_zones" "available" {
  state = "available"
}

# Helper to get Account ID
data "aws_caller_identity" "current" {}

# Create the Cluster (Compute Environment)
resource "aws_ecs_cluster" "main_cluster" {
  name = "iot-factory-cluster"
}

########################################
# Modules
########################################

module "network" {
  source = "./modules/network"

  vpc_cidr           = var.vpc_cidr
  # CHANGE: Match the new variable name inside the module
  public_subnet_cidrs = var.public_subnet_cidrs
  environment         = var.environment
}

module "iot" {
  source = "./modules/iot"

  region      = var.region
  environment = var.environment
  iot_topic   = var.iot_topic
}

# 1. Create the Shared Load Balancer
module "shared_alb" {
  source = "./modules/shared-alb"

  vpc_id         = module.network.vpc_id     # Assuming you have a VPC module
  public_subnets = module.network.public_subnets
  name_prefix    = "iot-project"
}

module "s3_config" {
  source = "./modules/s3_config"

  region           = var.region
  environment      = var.environment
  create_buckets   = var.create_buckets

  # Compose bucket names dynamically
  cert_s3_bucket    = "${var.cert_s3_bucket}-${var.environment}"
  config_s3_bucket  = "${var.config_s3_bucket}-${var.environment}"

    # Add this line
  cert_files        = var.cert_files
}

module "iot_ecs" {
  source = "./modules/iot-simulator-ecs"

  # Infrastructure wiring
  region          = var.region
  account_id      = data.aws_caller_identity.current.account_id
  cluster_id      = aws_ecs_cluster.main_cluster.id
  vpc_id          = module.network.vpc_id
  subnets         = module.network.public_subnets
  security_groups = [module.network.ecs_security_group_id]

# --- Connection to Shared ALB ---
  alb_listener_arn      = module.shared_alb.listener_arn
  alb_security_group_id = module.shared_alb.security_group_id

  # Configuration wiring (From S3 module)
  config_bucket   = module.s3_config.config_bucket_name
  cert_bucket     = module.s3_config.cert_bucket_name

  # App wiring (From IoT module)
  aws_iot_endpoint = module.iot.iot_endpoint
  iot_topic        = "factory/simulator"
  simulator_count  = 5
  iot_endpoint = module.iot.iot_endpoint
  repository_url = module.ecr_simulator.repository_url

  # DOCKER IMAGE
  # Update this URI after running 'docker push'
  app_image_uri    = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${var.region}.amazonaws.com/iot-simulator:latest"
}

# Repository for the Python Simulator Code
module "ecr_simulator" {
  source = "./modules/ecr"

  repository_name = "iot-simulator"
  environment     = var.environment
}

# Repository for Custom Grafana (Optional, only if you customize Grafana)
# module "ecr_grafana" {
#   source = "./modules/ecr"

#   repository_name = "iot-simulator-grafana"
#   environment     = var.environment
# }