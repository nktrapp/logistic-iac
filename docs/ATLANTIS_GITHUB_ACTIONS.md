# Atlantis via GitHub Actions

Este repositorio roda Atlantis a partir de GitHub Actions.

O Atlantis oficial e uma aplicacao self-hosted que escuta webhooks de pull
request e comenta o resultado de `terraform plan` e `terraform apply`. Neste
repo, o workflow `.github/workflows/atlantis.yml` sobe o container oficial do
Atlantis de forma efemera dentro do job, encaminha o payload do GitHub para o
endpoint local `/events` e preserva o diretorio de dados em cache por PR.

## Quando usar este modelo

Use este modelo quando voce quer evitar manter um servidor Atlantis dedicado
agora, mas ainda quer:

- comandos de PR como `atlantis plan` e `atlantis apply`;
- configuracao por projeto em `atlantis.yaml`;
- comentarios de plan/apply no PR;
- execucao com credenciais temporarias via OIDC.

Para uso corporativo pesado, o desenho preferencial continua sendo Atlantis
persistente em ECS/EKS/VM com Redis/S3 para locks e plano. O workflow atual e
uma ponte boa para evoluir sem abandonar o contrato do `atlantis.yaml`.

## Arquivos relevantes

```text
.github/workflows/atlantis.yml   # sobe Atlantis e encaminha eventos GitHub
atlantis.yaml                     # define projetos, dependencias e requisitos
CODEOWNERS                        # define ownership por camada/time
catalog/sqs/*.yaml                # fonte dos contratos SQS
```

## Secrets e variables

Configure no GitHub em:

```text
Repository -> Settings -> Secrets and variables -> Actions
```

Secrets obrigatorios:

```text
ATLANTIS_WEBHOOK_SECRET
```

`ATLANTIS_WEBHOOK_SECRET` pode ser qualquer string aleatoria forte. Exemplo para
gerar localmente:

```bash
openssl rand -hex 32
```

Variables recomendadas:

```text
AWS_REGION=us-east-1
AWS_ROLE_TO_ASSUME=arn:aws:iam::<account-id>:role/github-actions-logistic-iac
```

Se `AWS_ROLE_TO_ASSUME` nao estiver configurado, o workflow ainda executa checks
estaticos, mas `terraform plan/apply` contra AWS falhara por falta de
credenciais.

## IAM/OIDC na AWS

Crie um Identity Provider do GitHub Actions na conta AWS e uma role assumivel
por este repositorio.

Trust policy minima:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::<account-id>:oidc-provider/token.actions.githubusercontent.com"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "token.actions.githubusercontent.com:aud": "sts.amazonaws.com"
        },
        "StringLike": {
          "token.actions.githubusercontent.com:sub": "repo:<org>/logistic-iac:*"
        }
      }
    }
  ]
}
```

Permissoes minimas da role:

- acesso ao bucket S3 de state;
- acesso a tabela DynamoDB de lock;
- permissoes AWS necessarias para os stacks planejados/aplicados;
- `ssm:GetParameter`, `ssm:PutParameter` para contratos;
- `sqs:*` restrito aos prefixos de filas do projeto;
- `cloudwatch:*` necessario para alarmes do stack de contratos.

Para producao, prefira policies por ambiente e role separada por conta.

## Branch protection

Configure branch protection em `main`:

```text
Require a pull request before merging
Require approvals
Require review from Code Owners
Require status checks to pass
Require branches to be up to date
```

Status check esperado:

```text
Atlantis / Atlantis via GitHub Actions
```

## Fluxo de PR

Ao abrir ou atualizar um PR, o workflow encaminha o evento `pull_request` para o
Atlantis. O `autoplan` do `atlantis.yaml` decide quais projetos planejar.

Comandos em comentario de PR:

```text
atlantis plan
atlantis plan -p dev-contracts
atlantis apply -p dev-contracts
```

Prod possui `apply_requirements` em `atlantis.yaml`:

```text
approved
mergeable
undiverged
```

Ou seja, `apply` de prod so deve passar depois de aprovacao, PR mergeavel e
branch atualizada.

## Como o workflow funciona

1. Roda checks estaticos com o container do Atlantis.
2. Restaura cache do diretorio de dados do Atlantis para o PR.
3. Sobe `ghcr.io/runatlantis/atlantis:v0.43.0`.
4. Assina o payload do GitHub com `ATLANTIS_WEBHOOK_SECRET`.
5. Faz `POST` local em `http://127.0.0.1:4141/events`.
6. Mantem o container vivo por `ATLANTIS_EVENT_WAIT_SECONDS`.
7. Salva novamente o diretorio de dados em cache.

O tempo padrao e 900 segundos. Ajuste `ATLANTIS_EVENT_WAIT_SECONDS` no workflow
se os planos ficarem maiores.

## Limitacoes conhecidas

- GitHub Actions e efemero; se o job for cancelado, o Atlantis para junto.
- O cache preserva dados por PR, mas nao substitui um backend persistente como
  Redis/S3 em ambientes grandes.
- Plan/apply longos podem exigir aumentar `timeout-minutes` e
  `ATLANTIS_EVENT_WAIT_SECONDS`.
- PRs vindos de forks normalmente nao recebem secrets/OIDC; esse fluxo foi
  pensado para um repo interno.

## Migracao futura para servidor persistente

Quando o time quiser migrar para Atlantis persistente, mantenha:

```text
atlantis.yaml
CODEOWNERS
catalog/sqs
envs/*
modules/*
```

Substitua apenas `.github/workflows/atlantis.yml` por uma implantacao em
ECS/EKS/VM e configure o webhook do GitHub para apontar para o endpoint publico
do Atlantis.

Referencias oficiais:

- https://github.com/runatlantis/atlantis
- https://www.runatlantis.io/docs/deployment.html
- https://www.runatlantis.io/docs/server-configuration
