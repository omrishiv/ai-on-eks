# Agentic Community Reference Deployment

This is infrastructure is an implementation of
the [Agentic Community Reference Architecture](https://github.com/agentic-community/wg-operations/pull/1) for running
Agentic AI workloads. It deploys an environment that supports continuously building, deploying, and evaluating agents
using open source tools in a secure, scalable, and reliable manner.

## Overview

This infrastructure will create a VPC with subnets, an Internet Gateway and NAT Gateway. It will create an EKS
environment with Managed Node Groups to run critical addons including Karpenter, which will enable autoscaling of nodes
depending on workload needs. Finally, it deploys AI on EKS's implementation of the Agentic Community architecture. This
infrastructure leverages Gitlab for source control and a container registry and Langfuse for agent observability and
evaluations.

## Prerequisites

While much of the infrastructure is run in an isolated manner, running Gitlab requires a certificate, which requires a
domain. Ahead of deploying the infrastructure, you will need to own a domain. You can use a subdomain from a domain you
already own.

### Create a Hosted Zone

#### (Optional) Add Hosted Zone as Sub Domain

### Create an ACM Certificate

## Deploy the Environment

- `cd infra/agents/terraform`
- Open `blueprints.tfvars`
- Set `acm_certificate_domain` to the domain you will be using for the platform
- Run `./install.sh`

This will take 15 minutes or so.

## Create Langfuse Secret

## Create Gitlab Records

We will create 2 A records aliased to the Network Load Balancer that was created as part of the deployment.

Record Names:
- registry.subdomain.tld
- gitlab.subdomain.tld

Record Type: A
Alias
Endpoint: Alias to Network Load Balancer
Region: us-west-2
Load Balancer Name: k8s-gitlab-gitlabng-...

At this point, Gitlab should be available at `https://gitlab.subdomain.tld`
