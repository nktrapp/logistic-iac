# Deploy AWS do zero

Este guia e o caminho oficial para subir a infra na AWS. O Terraform oficial
fica somente neste repositorio, `logistic-iac`.

Se ainda existirem pastas `terraform/` dentro dos repos de servico, trate como
legado. O deploy AWS novo nao usa esses diretorios e nao usa mais
`terraform/base`.

## O que sera criado

Ordem dos stacks:

```text
envs/bootstrap/us-east-1
envs/prod/us-east-1/00-foundation
envs/prod/us-east-1/10-contracts
envs/prod/us-east-1/20-data/package-service
envs/prod/us-east-1/20-data/logistics-service
envs/prod/us-east-1/30-services/package-service
envs/prod/us-east-1/30-services/logistics-service
```

Responsabilidades:

```text
bootstrap        S3 bucket de state, DynamoDB lock e repositorios ECR (um por servico)
foundation       VPC, subnets, ALB, ECS cluster EC2, ASG e IAM base
contracts        SQS, DLQs, alarmes SQS e parametros SSM de contrato
data             MongoDB Atlas M0 (+ Redis Cloud no logistics), secret no Secrets Manager e contrato SSM
package-service  ECS service, target group, IAM task; le o secret do MongoDB via contrato SSM
logistics        ECS service, target group, IAM task; le os secrets de MongoDB e Redis via contrato SSM
```

Os repositorios ECR sao unicos por servico (sem ambiente no nome) e vivem no
stack `bootstrap`.

## Pre-requisitos

Instale e configure:

```bash
aws --version
terraform version
```

Autentique na conta AWS:

```bash
aws configure
aws sts get-caller-identity
```

Use a regiao padrao do projeto:

```bash
export AWS_REGION=us-east-1
export AWS_DEFAULT_REGION=us-east-1
```

No PowerShell:

```powershell
$env:AWS_REGION="us-east-1"
$env:AWS_DEFAULT_REGION="us-east-1"
```

As imagens Docker dos servicos vivem no Amazon ECR e precisam existir antes do
apply dos stacks de servico. Os repositorios sao criados pelo stack `bootstrap`
(passo 1), entao rode o bootstrap antes de tentar publicar imagem.

Formato do endereco da imagem:

```text
<account-id>.dkr.ecr.us-east-1.amazonaws.com/furb-logistics/package-service:<tag>
<account-id>.dkr.ecr.us-east-1.amazonaws.com/furb-logistics/logistics-service:<tag>
```

A task role de execucao do ECS ja tem `AmazonECSTaskExecutionRolePolicy`, que
permite puxar do ECR na mesma conta. Para imagem no ECR voce nao precisa de
`image_pull_secret_arn` (ele so serve para registry privado externo).

### Como a imagem chega no ECR (release dos repos de servico)

Cada repo de servico (`logistics-service`, `package-service`) tem um workflow
`release.yml` que versiona com semantic-release e faz push da imagem para o ECR
via Jib, autenticando na AWS por OIDC.

Para isso funcionar, configure em cada repo de servico no GitHub, em
`Settings -> Secrets and variables -> Actions`, as variables:

```text
AWS_REGION=us-east-1
AWS_ROLE_TO_ASSUME=arn:aws:iam::<account-id>:role/github-actions-ecr-push
```

Na conta AWS, crie (uma vez) o OIDC provider do GitHub Actions e uma role
assumivel pelos repos de servico. Trust policy minima:

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
          "token.actions.githubusercontent.com:sub": [
            "repo:<org>/logistics-service:*",
            "repo:<org>/package-service:*"
          ]
        }
      }
    }
  ]
}
```

Permissoes minimas da role (push no ECR):

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "ecr:GetAuthorizationToken",
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "ecr:BatchCheckLayerAvailability",
        "ecr:InitiateLayerUpload",
        "ecr:UploadLayerPart",
        "ecr:CompleteLayerUpload",
        "ecr:PutImage"
      ],
      "Resource": [
        "arn:aws:ecr:us-east-1:<account-id>:repository/furb-logistics/logistics-service",
        "arn:aws:ecr:us-east-1:<account-id>:repository/furb-logistics/package-service"
      ]
    }
  ]
}
```

### Alternativa: push manual (sem CI)

Depois do bootstrap, da para publicar manualmente a partir do repo do servico:

```bash
aws ecr get-login-password --region us-east-1 \
  | docker login --username AWS --password-stdin <account-id>.dkr.ecr.us-east-1.amazonaws.com

./gradlew :application:jib \
  -Djib.to.image=<account-id>.dkr.ecr.us-east-1.amazonaws.com/furb-logistics/logistics-service \
  -Djib.to.tags=<tag> --no-daemon
```

## Custo esperado

Este desenho foi reduzido para ficar barato, nao para ser production-grade:

```text
ECS EC2       1x t3.micro por ambiente
NAT Gateway   desabilitado por padrao
ALB           1 por ambiente
MongoDB       MongoDB Atlas M0 (gratis, fora da AWS)
Redis         Redis Cloud free (gratis, fora da AWS, so no logistics-service)
SQS/SSM/S3    baixo custo em uso pequeno
CloudWatch    logs com retencao de 1 dia
```

MongoDB e Redis rodam em servicos gerenciados gratuitos fora da AWS (MongoDB
Atlas M0 e Redis Cloud free). Mesmo assim, isto nao e 100% free tier: o ALB pode
gerar cobranca. Suba, valide e destrua o que nao estiver usando.

## 1. Criar o backend remoto

O bootstrap usa state local porque ele cria o proprio bucket remoto. Ele tambem
cria os repositorios ECR de cada servico.

```bash
cd logistic-iac/envs/bootstrap/us-east-1
terraform init
terraform apply
```

Veja as URLs dos repositorios ECR criados:

```bash
terraform output ecr_repository_urls
```

Se o bucket `logistic-iac-terraform-state` ja existir em outra conta, escolha
um nome unico:

```bash
terraform apply -var="state_bucket_name=meu-logistic-iac-state"
```

Nesse caso, atualize o valor `bucket` nos arquivos `versions.tf` dos outros
stacks e o default `terraform_state_bucket` nos stacks de servico.

## 2. Subir foundation

```bash
cd ../../prod/us-east-1/00-foundation
terraform init
terraform plan
terraform apply
```

Por padrao:

```text
create_nat_gateway = false
ecs_instance_type  = "t3.micro"
ecs_desired        = 1
certificate_arn    = ""
```

Com `certificate_arn = ""`, o ALB fica HTTP. Se quiser HTTPS, crie/importe um
certificado ACM na regiao `us-east-1` e informe o ARN.

## 3. Subir contratos SQS

```bash
cd ../10-contracts
terraform init
terraform plan
terraform apply
```

Esse stack cria as filas declaradas em `catalog/sqs/*.yaml` e publica os
parametros:

```text
/logistic/prod/contracts/sqs/package-events/name
/logistic/prod/contracts/sqs/package-events/url
/logistic/prod/contracts/sqs/package-events/arn
/logistic/prod/contracts/sqs/logistics-events/name
/logistic/prod/contracts/sqs/logistics-events/url
/logistic/prod/contracts/sqs/logistics-events/arn
```

Servicos leem esses parametros. Servicos nao criam SQS.

## 4. Subir os dados (MongoDB Atlas + Redis Cloud)

A camada `20-data/<service>` provisiona o banco/cache em provedores gerenciados
gratuitos fora da AWS (MongoDB Atlas M0 e, para o logistics, Redis Cloud free),
cria o secret no Secrets Manager e publica o contrato no SSM (ARN do secret e,
para o Redis, `host`/`port`). Os servicos leem esse contrato; ninguem cola
connection string na mao.

Crie uma vez as chaves de API:

1. MongoDB Atlas: conta gratis em <https://www.mongodb.com/atlas>, uma
   organizacao e uma API key (Public/Private) com permissao de Project Owner.
   Anote o `org_id`.
2. Redis Cloud (so o logistics usa): conta gratis em <https://redis.io/cloud/> e
   uma API key (account key + secret key).

O acesso ao Atlas fica liberado para `0.0.0.0/0` por padrao (as instancias ECS
estao em subnet publica e nao tem IP fixo; o acesso segue protegido por
usuario/senha). Para restringir, seria preciso NAT Gateway + EIP (gera custo).
Nomes de projeto/cluster/banco tem defaults em `variables.tf` e as senhas sao
geradas quando ficam em branco. Se voce ja criou o cluster/DB na mao, faca
`terraform import` (veja o README de cada modulo) para adotar em vez de recriar.

### package-service (so MongoDB)

`terraform.tfvars` em `envs/prod/us-east-1/20-data/package-service`:

```hcl
atlas_public_key  = "<atlas-api-public-key>"
atlas_private_key = "<atlas-api-private-key>"
atlas_org_id      = "<atlas-org-id>"
```

```bash
cd envs/prod/us-east-1/20-data/package-service
terraform init
terraform apply
```

### logistics-service (MongoDB + Redis)

`terraform.tfvars` em `envs/prod/us-east-1/20-data/logistics-service`:

```hcl
atlas_public_key  = "<atlas-api-public-key>"
atlas_private_key = "<atlas-api-private-key>"
atlas_org_id      = "<atlas-org-id>"

rediscloud_api_key    = "<rediscloud-api-key>"
rediscloud_secret_key = "<rediscloud-secret-key>"
```

```bash
cd ../logistics-service
terraform init
terraform apply
```

## 5. Subir package-service

`terraform.tfvars` em `envs/prod/us-east-1/30-services/package-service`:

```hcl
service_image = "<account-id>.dkr.ecr.us-east-1.amazonaws.com/furb-logistics/package-service:<tag>"
desired_count = 1
```

A conexao com o MongoDB vem do contrato SSM publicado pelo `20-data` — sem
connection string aqui. Aplique:

```bash
cd envs/prod/us-east-1/30-services/package-service
terraform init
terraform plan
terraform apply
```

Ao final, veja:

```bash
terraform output package_service_url
```

## 6. Subir logistics-service

`terraform.tfvars` em `envs/prod/us-east-1/30-services/logistics-service`:

```hcl
service_image = "<account-id>.dkr.ecr.us-east-1.amazonaws.com/furb-logistics/logistics-service:<tag>"
desired_count = 1
```

MongoDB e Redis vem do contrato SSM do `20-data`. Aplique:

```bash
cd ../logistics-service
terraform init
terraform plan
terraform apply
```

Ao final, veja:

```bash
terraform output logistics_service_url
```

## 7. Validar se subiu

Pegue as URLs dos outputs e teste:

```bash
curl http://<alb-dns>/api/v1/packages
curl http://<alb-dns>/api/v1/hubs
```

No console AWS, confira:

```text
ECS > cluster furb-logistics-prod-cluster > services RUNNING
EC2 > Target Groups > targets healthy
CloudWatch Logs > /ecs/furb-logistics/prod/package-service
CloudWatch Logs > /ecs/furb-logistics/prod/logistics-service
SQS > filas com prefixo furb-logistics-prod
```

Se a task nao subir, olhe primeiro:

```text
1. A imagem com essa tag ja foi publicada no ECR (release rodou ou push manual)?
2. A task role de execucao consegue puxar do ECR (mesma conta, policy padrao)?
3. O stack 20-data foi aplicado e os parametros SSM existem? O IP da instancia
   esta liberado no Atlas?
4. Target group esta chamando /management/health/liveness na porta 8080?
5. CloudWatch Logs mostra erro de credencial, MongoDB, Redis ou SQS?
```

## Tag de imagem

Use sempre tag imutavel (a mesma imagem ja publicada no ECR pelo release). Nao
use `latest`:

```hcl
service_image = "<account-id>.dkr.ecr.us-east-1.amazonaws.com/furb-logistics/package-service:1.2.3"
```

## Destruir

Para evitar custo, destrua na ordem inversa:

```text
prod/us-east-1/30-services/logistics-service
prod/us-east-1/30-services/package-service
prod/us-east-1/20-data/logistics-service
prod/us-east-1/20-data/package-service
prod/us-east-1/10-contracts
prod/us-east-1/00-foundation
bootstrap/us-east-1
```

Comandos:

```bash
terraform destroy
```

Destruir `20-data` apaga o cluster MongoDB Atlas e o Redis (perda de dados) — e o
esperado, ja que sao gerenciados pelo Terraform. Nunca destrua `bootstrap` antes
dos outros stacks, porque ele guarda o state remoto.
