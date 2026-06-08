# security-group

Reusable, data-driven security group. Ingress/egress rules are passed as typed
objects and materialized with `dynamic` blocks, so the same module backs the
ALB SG, the ECS instance SG and any future data-plane SG without duplicating the
resource.

Each rule may source/target `cidr_blocks`, `source_security_group_ids`, or both.
The caller owns the `Name` tag and passes it through `tags`. The resource uses
`name_prefix`, so the caller passes the full prefix (for example
`"${var.name_prefix}-alb-"`).

## Example

```hcl
module "sg" {
  source = "../security-group"

  name_prefix = "${var.name_prefix}-alb-"
  vpc_id      = var.vpc_id

  ingress_rules = [
    { from_port = 80, to_port = 80, protocol = "tcp", cidr_blocks = ["0.0.0.0/0"] },
  ]

  egress_rules = [
    { from_port = 0, to_port = 0, protocol = "-1", cidr_blocks = ["0.0.0.0/0"] },
  ]

  tags = merge(var.tags, { Name = "${var.name_prefix}-alb-sg" })
}
```
