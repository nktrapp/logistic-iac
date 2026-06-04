# Contratos SQS

Cada fila e declarada em YAML dentro de `catalog/sqs`.

```yaml
name: package-events
type: fifo
producer: package-service
consumers:
  - logistics-service
events:
  - package.created
  - package.destination.changed
dlq: true
visibility_timeout_seconds: 60
retention_seconds: 345600
receive_wait_time_seconds: 20
max_receive_count: 3
content_based_deduplication: false
```

## Convencao de nomes

O modulo cria os nomes reais com:

```text
{queue_name_prefix}{name}-queue.fifo
{queue_name_prefix}{name}-dlq.fifo
```

No MiniStack local, `queue_name_prefix` fica vazio para manter compatibilidade
com os defaults dos servicos:

```text
package-events-queue.fifo
logistics-events-queue.fifo
```

Em AWS, `queue_name_prefix` deve usar projeto e ambiente para evitar colisao
entre `dev` e `prod`, por exemplo:

```text
furb-logistics-dev-package-events-queue.fifo
furb-logistics-prod-package-events-queue.fifo
```

## Parametros SSM publicados

Para cada contrato, o stack publica:

```text
/logistic/{env}/contracts/sqs/{name}/name
/logistic/{env}/contracts/sqs/{name}/url
/logistic/{env}/contracts/sqs/{name}/arn
/logistic/{env}/contracts/sqs/{name}/dlq-name
/logistic/{env}/contracts/sqs/{name}/dlq-url
/logistic/{env}/contracts/sqs/{name}/dlq-arn
```

Servicos devem consumir esses parametros. Eles nao devem usar
`data "aws_sqs_queue"` para descobrir filas.
