# MiniStack local

Cada servico roda localmente de forma isolada com seu proprio MiniStack.

O compose do servico executa:

```text
ministack -> terraform-contracts -> app
```

`terraform-contracts` monta este repo e aplica:

```text
envs/local/ministack/contracts
```

contra o endpoint:

```text
http://ministack:4566
```

## Caminho do repo

Por padrao, os composes assumem que este repo esta ao lado dos servicos:

```text
trabalho-final-furb/
  logistic-iac/
  package-service/
  logistics-service/
```

Para outro caminho:

```bash
LOGISTIC_IAC_PATH=/path/to/logistic-iac docker compose up -d --build
```

## Escopo local

O Terraform local cria apenas recursos simulaveis e uteis ao desenvolvimento:

- SQS.
- DLQs.
- SSM parameters.
- Secrets Manager, quando necessario.

VPC, ALB e ECS nao sao simulados por Terraform local. MongoDB e Redis rodam como
containers locais.

Alarmes de DLQ ficam desabilitados no stack local para nao depender da
compatibilidade completa de CloudWatch no emulador.
