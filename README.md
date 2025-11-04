# AWS Hello Protocol (Terraform)

Minimal, production-lean template that deploys:
- **API Gateway (HTTP API)** → **Lambda (HTTP)**: POST `/ingest`
- **SQS queue + DLQ** → **Lambda (SQS consumer)**
- Writes documents to **MongoDB Atlas** using a connection string stored in **AWS Secrets Manager**.

## What gets written
Collection: `protocol_logs`
```json
{
  "_id": "uuid-v4",
  "protocolId": "P-123",
  "message": "hello",
  "source": "http|sqs",
  "receivedAt": "2025-11-04T00:00:00.000Z"
}
```

## Prereqs
- AWS account + CLI configured
- Terraform v1.6+
- Node.js 20+ & npm
- A MongoDB Atlas connection string stored in **AWS Secrets Manager**
  - Secret **name** must match `var.mongodb_secret_name` (default: `hello-protocol/mongodb-uri`).
  - Secret value: full connection string, e.g. `mongodb+srv://...`

## Deploy (dev quick start)
```bash
cd infra
terraform init
terraform apply -auto-approve   -var="aws_region=us-east-1"   -var="mongodb_secret_name=hello-protocol/mongodb-uri"   -var="environment=dev"
```
Terraform will run `npm ci` inside each Lambda folder before bundling.

## Test
1) HTTP
```bash
ENDPOINT=$(terraform -chdir=infra output -raw http_api_invoke_url)
curl -X POST "$ENDPOINT/ingest" -H "content-type: application/json"   -d '{"protocolId":"P-9001","message":"hello-from-http"}'
```

2) SQS
```bash
QUEUE_URL=$(terraform -chdir=infra output -raw protocol_queue_url)
aws sqs send-message --queue-url "$QUEUE_URL"   --message-body '{"protocolId":"P-42","message":"hello-from-sqs"}'
```

3) Check MongoDB collection `protocol_logs` for both entries.

## Variables you may change
- `aws_region` (default `us-east-1`)
- `environment` (default `dev`)
- `project` (default `hello-protocol`)
- `mongodb_secret_name` (default `hello-protocol/mongodb-uri`)
- `mongodb_db` (default `app`)

## Notes
- For simplicity, Lambdas **do not** run in a VPC; MongoDB Atlas should be reachable via public endpoint (dev).
- For production, consider VPC + PrivateLink/peering and WAF.
- IAM is least-priv for logs, SQS, and Secrets Manager (read the one secret).
