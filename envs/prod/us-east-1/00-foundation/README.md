# prod foundation

Authoritative location for shared prod infrastructure.

Apply manually with `terraform apply` after review. This is the base layer:
VPC, ALB, ECS cluster, IAM. Other stacks depend on its remote state.
