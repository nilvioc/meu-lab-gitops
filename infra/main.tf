terraform {
  required_providers {
    local = {
      source = "hashicorp/local"
      version = "~> 2.4.0"
    }
  }
}

resource "local_file" "ola_terraform" {
  content  = "Missao Cumprida! Arquivo gerado pelo Terraform sob o comando do Semaphore!"
  filename = "${path.module}/resultado.txt"
}
