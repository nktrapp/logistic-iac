# logistic-iac

Repositorio central de IaC do dominio logistico.

Este repo separa infraestrutura compartilhada, contratos entre servicos e stacks
especificos de runtime. A regra mais importante e simples: servicos nao criam
filas SQS. Filas sao contratos compartilhados e pertencem ao stack
`10-contracts`.

## Layout

```text
catalog/sqs/                         # Contratos SQS declarativos
modules/sqs-contracts/               # Modulo que materializa contratos SQS
envs/local/ministack/contracts/       # Terraform local contra MiniStack
envs/bootstrap/us-east-1/             # Bootstrap do backend remoto
envs/prod/us-east-1/                 # Stacks AWS de prod
docs/                                # Fluxos, decisoes e guias operacionais
```

## Camadas

- `bootstrap`: S3 bucket de state (lock nativo via S3, sem DynamoDB).
- `00-foundation`: rede, ALB, ECS cluster, IAM base, KMS, DNS e recursos
  compartilhados.
- `10-contracts`: SQS, DLQs, parametros SSM, alarmes e catalogo de eventos.
- `20-data/*`: banco/cache gerenciado de cada servico (MongoDB Atlas M0, Redis
  Cloud free). Cria o secret e publica ARN/host/port no SSM. Opcional e aplicado
  antes do servico.
- `30-services/*`: recursos de cada servico, sem ownership de SQS. Le a conexao
  do contrato SSM publicado por `20-data`.

## Deploy AWS oficial

O caminho oficial de deploy AWS fica neste repositorio. Nao use mais
`terraform/base` nem os Terraform legados dentro dos repos de servico para subir
a AWS.

Leia o passo a passo:

- [Deploy AWS do zero](DEPLOY_AWS_FROM_ZERO.md)

## Desenvolvimento local

Os `compose.yml` dos servicos executam um container one-shot
`terraform-contracts`. Ele monta este repositorio, aplica
`envs/local/ministack/contracts` contra o MiniStack e cria as filas declaradas em
`catalog/sqs`.

Por padrao, os composes esperam este repo em `../logistic-iac` a partir de cada
servico. Para usar outro caminho:

```bash
LOGISTIC_IAC_PATH=/path/to/logistic-iac docker compose up -d --build
```

## Regra de ouro para SQS

Para adicionar uma fila, altere somente `catalog/sqs/*.yaml` e o servico que vai
usar o contrato. Nao crie `aws_sqs_queue` dentro do Terraform de servico.

Leia:

- [Arquitetura](docs/architecture.md)
- [Fluxo de desenvolvimento](docs/development-flow.md)
- [Contratos SQS](docs/sqs-contracts.md)
- [MiniStack local](docs/local-ministack.md)
- [AWS CLI e Terraform via Docker](docs/tools-docker.md)
