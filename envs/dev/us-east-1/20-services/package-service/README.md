# dev package-service

Authoritative Terraform stack for package-service runtime resources in dev.

This stack must consume SQS contracts through SSM parameters published by
`10-contracts`. It must not create `aws_sqs_queue`.
