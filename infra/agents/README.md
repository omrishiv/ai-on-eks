# Agentic Community Reference Deployment

This infrastructure is an implementation of
the [Agentic Community Reference Architecture](https://github.com/agentic-community/wg-operations/pull/1) for running
Agentic AI workloads. It deploys an environment that supports continuously building, deploying, and evaluating agents
using open source tools in a secure, scalable, and reliable manner.

## Overview

This infrastructure will create a VPC with subnets, an Internet Gateway and NAT Gateway. It will create an EKS
environment with Managed Node Groups to run critical addons including Karpenter, which will enable autoscaling of nodes
depending on workload needs. Finally, it deploys AI on EKS's implementation of the Agentic Community architecture. This
infrastructure leverages Gitlab for source control and a container registry,  Langfuse for agent observability and
evaluations, and Milvus as a vector store for memory.

## Prerequisites

While much of the infrastructure is run in an isolated manner, running Gitlab requires a certificate, which requires a
domain. Ahead of deploying the infrastructure, you will need to own a domain. You can use a subdomain from a domain you
already own.

### Create a Hosted Zone

Follow the directions
to [create a hosted zone](https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/CreatingHostedZone.html). If this
will be a sudomain from another domain, name it following the pattern `subdomain.domain.tld`

#### (Optional) Add Hosted Zone as Sub Domain

If you want to use a subdomain off of the domain, add the hosted zone as
a [subdomain](https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/CreatingNewSubdomain.html) to your main domain.

### Create an ACM Certificate

Follow the directions to [create an ACM certificate](https://docs.aws.amazon.com/res/latest/ug/acm-certificate.html)

## Deploy the Environment

- `cd infra/agents/terraform`
- Open `blueprints.tfvars`
- Set `acm_certificate_domain` to the domain you will be using for the platform
- Run `./install.sh`

This will take 20 minutes or so.
