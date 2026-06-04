locals {
  normalized_contracts = {
    for key, contract in var.contracts : key => {
      name                        = contract.name
      type                        = try(contract.type, "fifo")
      producer                    = try(contract.producer, null)
      consumers                   = try(contract.consumers, [])
      events                      = try(contract.events, [])
      dlq                         = try(contract.dlq, true)
      visibility_timeout_seconds  = try(contract.visibility_timeout_seconds, 60)
      retention_seconds           = try(contract.retention_seconds, 345600)
      receive_wait_time_seconds   = try(contract.receive_wait_time_seconds, 20)
      max_receive_count           = try(contract.max_receive_count, 3)
      content_based_deduplication = try(contract.content_based_deduplication, false)
      deprecated                  = try(contract.deprecated, false)
    }
  }

  fifo_contracts = {
    for key, contract in local.normalized_contracts : key => merge(contract, {
      fifo = contract.type == "fifo"
    })
  }

  dlq_contracts = {
    for key, contract in local.fifo_contracts : key => contract
    if contract.dlq
  }
}

resource "aws_sqs_queue" "dlq" {
  for_each = local.dlq_contracts

  name                        = "${var.queue_name_prefix}${each.value.name}-dlq${each.value.fifo ? ".fifo" : ""}"
  fifo_queue                  = each.value.fifo
  content_based_deduplication = each.value.fifo ? each.value.content_based_deduplication : null
  message_retention_seconds   = 1209600

  tags = merge(var.tags, {
    Name        = "${var.queue_name_prefix}${each.value.name}-dlq${each.value.fifo ? ".fifo" : ""}"
    Layer       = "contracts"
    Contract    = each.value.name
    QueueRole   = "dlq"
    Producer    = coalesce(each.value.producer, "")
    Deprecated  = tostring(each.value.deprecated)
  })
}

resource "aws_sqs_queue" "main" {
  for_each = local.fifo_contracts

  name                        = "${var.queue_name_prefix}${each.value.name}-queue${each.value.fifo ? ".fifo" : ""}"
  fifo_queue                  = each.value.fifo
  content_based_deduplication = each.value.fifo ? each.value.content_based_deduplication : null
  visibility_timeout_seconds  = each.value.visibility_timeout_seconds
  message_retention_seconds   = each.value.retention_seconds
  receive_wait_time_seconds   = each.value.receive_wait_time_seconds

  redrive_policy = each.value.dlq ? jsonencode({
    deadLetterTargetArn = aws_sqs_queue.dlq[each.key].arn
    maxReceiveCount     = each.value.max_receive_count
  }) : null

  tags = merge(var.tags, {
    Name       = "${var.queue_name_prefix}${each.value.name}-queue${each.value.fifo ? ".fifo" : ""}"
    Layer      = "contracts"
    Contract   = each.value.name
    QueueRole  = "main"
    Producer   = coalesce(each.value.producer, "")
    Consumers  = join(",", each.value.consumers)
    Events     = join(",", each.value.events)
    Deprecated = tostring(each.value.deprecated)
  })
}

locals {
  main_ssm_parameters = merge(
    { for key, queue in aws_sqs_queue.main : "${key}/name" => queue.name },
    { for key, queue in aws_sqs_queue.main : "${key}/url" => queue.url },
    { for key, queue in aws_sqs_queue.main : "${key}/arn" => queue.arn }
  )

  dlq_ssm_parameters = merge(
    { for key, queue in aws_sqs_queue.dlq : "${key}/dlq-name" => queue.name },
    { for key, queue in aws_sqs_queue.dlq : "${key}/dlq-url" => queue.url },
    { for key, queue in aws_sqs_queue.dlq : "${key}/dlq-arn" => queue.arn }
  )

  ssm_parameters = merge(local.main_ssm_parameters, local.dlq_ssm_parameters)
}

resource "aws_ssm_parameter" "contract" {
  for_each = var.create_ssm_parameters ? local.ssm_parameters : {}

  name        = "${var.ssm_prefix}/${each.key}"
  description = "SQS contract parameter managed by logistic-iac"
  type        = "String"
  value       = each.value
  overwrite   = true

  tags = merge(var.tags, {
    Layer = "contracts"
  })
}

resource "aws_cloudwatch_metric_alarm" "dlq_not_empty" {
  for_each = var.create_dlq_alarms ? aws_sqs_queue.dlq : {}

  alarm_name          = "${var.project_name}-${var.environment}-${each.key}-dlq-not-empty"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "ApproximateNumberOfMessagesVisible"
  namespace           = "AWS/SQS"
  period              = 300
  statistic           = "Sum"
  threshold           = 0
  alarm_description   = "SQS DLQ ${each.value.name} has visible messages"
  alarm_actions       = var.alarm_actions

  dimensions = {
    QueueName = each.value.name
  }

  tags = merge(var.tags, {
    Layer    = "contracts"
    Contract = each.key
  })
}
