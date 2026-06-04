# ADR 0001: Centralizar contratos SQS

## Status

Accepted

## Contexto

Os servicos `package-service` e `logistics-service` publicam e consomem eventos
por SQS FIFO. Quando cada servico cria sua propria fila e tambem faz lookup da
fila do outro, surge uma dependencia circular de bootstrap.

## Decisao

Filas SQS passam a pertencer ao stack `10-contracts` do repo `logistic-iac`.
Servicos consomem nome, URL e ARN por parametros SSM.

## Consequencias

- Bootstrap passa a ter ordem clara: `foundation -> contracts -> services`.
- Times de servico nao quebram o outro ao alterar Terraform proprio.
- Adicao e remocao de filas passam por fluxo de contrato.
