# Bedrock Access Gateway Docker

Automated Docker builds for the official [AWS Bedrock Access Gateway](https://github.com/aws-samples/bedrock-access-gateway).

**Docker Hub:** [warfront1bag/bedrock-access-gateway](https://hub.docker.com/r/warfront1bag/bedrock-access-gateway)

### Quick Start

Run the container with your AWS credentials:

```bash
docker run \
  -e AWS_ACCESS_KEY_ID=<access key id> \
  -e AWS_SECRET_ACCESS_KEY=<access key secret> \
  -e AWS_REGION=us-east-1 \
  -p 54123:80 \
  -d warfront1bag/bedrock-access-gateway:latest
```

## Configuration in third party tools (e.g., Open WebUI)
- **Base URL:** `http://localhost:54123/api/v1`
- **API Key:** `bedrock`

*Inspired by: [Enable Amazon Bedrock in 3rd party GenAI tools and plug-ins](https://repost.aws/articles/AR7BozdUxEQ6SItr2p2pxTCQ/enable-amazon-bedrock-in-3rd-party-genai-tools-and-plug-ins)*
