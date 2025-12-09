# -----------------------------------------------------------
# INITIAL SETUP: Comment this block OUT for the first 'terraform apply'.
# MIGRATION: Uncomment it after resources are created, then run 'terraform init'.
# -----------------------------------------------------------

terraform {
  backend "s3" {
    bucket         = "grp1-ce11-dev-iot-state-bucket" # <--- UPDATE THIS AFTER 1st RUN to match your variables
    key            = "grp1-ce11-dev-iot/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "grp1-ce11-dev-iot-locks"       # <--- UPDATE THIS AFTER 1st RUN
    encrypt        = true
  }
}