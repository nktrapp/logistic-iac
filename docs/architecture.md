# Arquitetura IaC

`logistic-iac` e dividido em tres camadas.

## 00-foundation

Contem recursos compartilhados e de baixo nivel:

- VPC, subnets, NAT opcional, rotas e security groups base.
- ALB publico, listeners e certificado ACM opcional.
- ECS cluster e IAM de plataforma.
- State backend, observabilidade compartilhada e integracoes globais quando
  necessarias.

Essa camada e mantida pelo time de plataforma.

## 10-contracts

Contem contratos entre times e servicos. Hoje o contrato principal e SQS FIFO.

Todo contrato publicado deve expor uma interface estavel via SSM Parameter Store.
Servicos podem ler parametros, mas nao podem ler state de outro servico nem fazer
lookup direto de recursos que pertencem a outro time.

## 20-services

Contem recursos especificos de cada servico:

- ECR.
- ECS task definition e service.
- Target group e listener rule.
- IAM da task.
- Secrets proprios.
- Banco/cache exclusivo do servico.

Servicos nao criam SQS. Quando precisam produzir ou consumir eventos, eles
declaram dependencia de um contrato publicado em `10-contracts`.
