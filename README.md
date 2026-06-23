# Laboratório de GitOps com Ansible e Terraform na AWS

Este repositório contém um laboratório prático projetado para demonstrar a orquestração do Terraform através do Ansible para provisionamento e destruição automatizados de infraestrutura na AWS.

## Arquitetura de Orquestração

A arquitetura deste laboratório combina as forças do **Ansible** (como ferramenta de orquestração de fluxo/pipeline de tarefas e configuração) com o **Terraform** (como ferramenta declarativa de Infraestrutura como Código - IaC).

```
[ Usuário / CI/CD ] 
       │
       ▼
 ┌──────────┐      1. Baixa/Extrai Terraform      ┌──────────────┐
 │ Ansible  ├────────────────────────────────────►│ /tmp/        │ (Binário local)
 │ Playbook │                                     └──────┬───────┘
 └─────┬────┘                                            │
       │                                                 │
       │ 2. Executa comandos (init, apply, destroy)      │
       └─────────────────────────────────────────────────┼────────┐
                                                         ▼        ▼
                                                   ┌──────────┐ ┌──────────┐
                                                   │  AWS ECR │ │  AWS S3  │
                                                   │  Repo    │ │  Bucket  │
                                                   └──────────┘ └──────────┘
```

### Como Funciona a Orquestração (Ansible + Terraform)
1. **Ambiente Isolado e Portável:** Os playbooks do Ansible são executados na máquina local (`connection: local`, `hosts: localhost`). Eles não exigem que o Terraform esteja pré-instalado no sistema hospedeiro.
2. **Ciclo de Vida do Binário:** 
   - O Ansible faz o download do binário do Terraform (versão `1.9.0`) em formato ZIP diretamente dos servidores da HashiCorp.
   - Extrai o executável utilizando módulos Python nativos (`zipfile`).
   - Concede permissão de execução (`0755`) ao binário no diretório temporário `/tmp`.
3. **Execução de Passos do Terraform:** O Ansible gerencia as etapas de inicialização e aplicação através do módulo `command`, navegando até o diretório da infraestrutura (`infra/`) e fornecendo de forma segura as variáveis de ambiente necessárias para a autenticação com a AWS.

---

## Estrutura de Arquivos

* **`deploy-infra.yml`**: Playbook do Ansible responsável por baixar o Terraform, inicializar o provedor e executar o `terraform apply` para provisionar os recursos na AWS.
* **`destroy-infra.yml`**: Playbook do Ansible que executa o fluxo reverso, realizando o download do binário e executando o `terraform destroy` para remover de forma limpa os recursos criados.
* **`infra/main.tf`**: Arquivo de configuração declarativo do Terraform contendo a definição da infraestrutura desejada na AWS.

---

## Recursos Provisionados na AWS

Definidos em `infra/main.tf`, os seguintes recursos são criados no provedor AWS (região `us-east-1`):

1. **Repositório AWS ECR (`aws_ecr_repository.lab_repo_terraform`)**:
   - Nome: `meu-repo-gerado-pelo-terraform`
   - Mutabilidade de tags: `MUTABLE`
   - Configuração de remoção forçada (`force_delete = true`) para permitir exclusão mesmo que haja imagens armazenadas.

2. **Bucket AWS S3 (`aws_s3_bucket.lab_bucket`)**:
   - Nome dinâmico utilizando prefixo (`bucket_prefix = "meu-lab-dados-"`) para garantir unicidade global.
   - Tag: `Ambiente` mapeada com o valor `Laboratorio`.

---

## Variáveis de Autenticação Necessárias

Os playbooks do Ansible esperam receber credenciais da AWS para autenticar e autorizar a criação de recursos. Essas credenciais devem ser repassadas como variáveis do Ansible (`--extra-vars` ou via arquivos de variáveis seguras/Ansible Vault):

* `minha_chave_aws`: ID da chave de acesso AWS (`AWS_ACCESS_KEY_ID`).
* `meu_segredo_aws`: Chave de acesso secreta AWS (`AWS_SECRET_ACCESS_KEY`).

---

## Como Executar o Laboratório

### 1. Provisionar a Infraestrutura
Para executar o provisionamento, execute o seguinte comando Ansible substituindo pelas suas credenciais AWS:

```bash
ansible-playbook deploy-infra.yml --extra-vars "minha_chave_aws=SUA_ACCESS_KEY meu_segredo_aws=SEU_SECRET_KEY"
```

### 2. Destruir a Infraestrutura
Para limpar todos os recursos criados na AWS e evitar custos indesejados, execute:

```bash
ansible-playbook destroy-infra.yml --extra-vars "minha_chave_aws=SUA_ACCESS_KEY meu_segredo_aws=SEU_SECRET_KEY"
```
