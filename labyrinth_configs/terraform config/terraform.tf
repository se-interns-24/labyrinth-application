terraform {

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.57.0"
    }
    /*
    hcp = {
      source  = "hashicorp/hcp"
      version = "0.17.0"
    }
    */
  }
  /*
  cloud {
    organization = "sofia_test"
    workspaces {
      name = "path-to-packer"
    }
  }
  */
  required_version = "~> 1.2"
}
