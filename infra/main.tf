terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_ecr_repository" "lab_repo_terraform" {
  name                 = "meu-repo-gerado-pelo-terraform"
  image_tag_mutability = "MUTABLE"
  
  # Esta linha de nivel Senior garante que possamos apagar 
  # o repositorio depois, mesmo se houver imagens dentro dele!
  force_delete = true 
}
