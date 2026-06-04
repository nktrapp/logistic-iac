locals {
  catalog_dir = abspath("${path.module}/../../../../catalog/sqs")

  contracts = {
    for file_name in fileset(local.catalog_dir, "*.yaml") :
    trimsuffix(file_name, ".yaml") => yamldecode(file("${local.catalog_dir}/${file_name}"))
  }

  tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
    Layer       = "contracts"
  }
}

module "sqs_contracts" {
  source = "../../../../modules/sqs-contracts"

  project_name      = var.project_name
  environment       = var.environment
  queue_name_prefix = "${var.project_name}-"
  ssm_prefix        = "${var.ssm_root_prefix}/${var.environment}/contracts/sqs"
  contracts         = local.contracts
  alarm_actions     = var.alarm_actions
  tags              = local.tags
}
