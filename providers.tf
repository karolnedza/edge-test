provider "aviatrix" {
  username = "admin"
  controller_ip = var.ctrl_ip
  password = var.password
}

terraform {
  required_providers {
    aviatrix = {
      source = "AviatrixSystems/aviatrix"
      version = "3.2.1"
    }
  }
}

provider "aws" {
  region  = "us-east-1"
    access_key = var.my-access-key
  secret_key = var.my-secret-key
}
