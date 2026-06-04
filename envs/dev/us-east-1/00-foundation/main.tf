locals {
  name_prefix = "${var.project_name}-${var.environment}"

  tags = {
    Project     = var.project_name
    Environment = var.environment
    Owner       = var.owner
    ManagedBy   = "terraform"
    Layer       = "foundation"
  }
}

module "network" {
  source = "../../../../modules/foundation-network"

  name_prefix        = local.name_prefix
  vpc_cidr           = var.vpc_cidr
  az_count           = var.az_count
  create_nat_gateway = var.create_nat_gateway
  single_nat_gateway = var.single_nat_gateway
  tags               = local.tags
}

module "alb" {
  source = "../../../../modules/foundation-alb"

  name_prefix         = local.name_prefix
  vpc_id              = module.network.vpc_id
  public_subnet_ids   = module.network.public_subnet_ids
  certificate_arn     = var.certificate_arn
  ingress_cidr_blocks = var.alb_ingress_cidr_blocks
  tags                = local.tags
}

module "ecs" {
  source = "../../../../modules/foundation-ecs"

  name_prefix                   = local.name_prefix
  vpc_id                        = module.network.vpc_id
  public_subnet_ids             = module.network.public_subnet_ids
  alb_security_group_id         = module.alb.alb_security_group_id
  ecs_instance_type             = var.ecs_instance_type
  ecs_instance_min_size         = var.ecs_min_size
  ecs_instance_max_size         = var.ecs_max_size
  ecs_instance_desired_capacity = var.ecs_desired_capacity
  enable_container_insights     = var.enable_container_insights
  tags                          = local.tags
}
