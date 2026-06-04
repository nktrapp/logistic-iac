# Fluxo de desenvolvimento

## Adicionar uma fila SQS

1. Criar ou alterar um arquivo em `catalog/sqs`.
2. Rodar o compose do servico afetado para validar o contrato no MiniStack.
3. Abrir PR no `logistic-iac`.
4. Atlantis executa plan para `10-contracts`.
5. Aplicar em `dev`.
6. Atualizar o servico para consumir o nome/URL/ARN publicado via SSM.
7. Promover para `prod` apos validacao.

## Remover uma fila SQS

1. Marcar o contrato como `deprecated: true`.
2. Remover produtores e consumidores dos servicos.
3. Confirmar que nenhum stack de servico referencia o contrato.
4. Remover o arquivo do catalogo em outro PR.

Remocao direta de fila usada por produtor ou consumidor deve ser bloqueada por
policy check.

## Adicionar recurso de servico

O time do servico altera apenas a propria pasta em `20-services/<service>`.
Mudancas em `foundation`, `contracts` ou `modules` exigem revisao do time de
plataforma.

## Checks minimos

```bash
terraform fmt -check -recursive
terraform validate
tflint
checkov
conftest test
```

Policies obrigatorias:

- Servico nao pode criar `aws_sqs_queue`.
- Servico nao pode ler remote state de outro servico.
- Fila usada nao pode ser removida diretamente.
- Prioridade de ALB listener rule nao pode repetir.
- Prod nao pode usar imagem `latest`.
