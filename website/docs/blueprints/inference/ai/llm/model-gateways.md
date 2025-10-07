---
sidebar_label: Model Gateways
---

# Model Gateways

Model Gateways provide a single entrypoint to standardize access to models across your infrastructure. These gateways
offer many feature and allow consolidating self-hosted models as well as those provided by an external provider. LLM
Gateways enable a number of useful features

## Model Centralization

At the heart of Model Gateways is the philosophy of consolidating the entrypoint to one location. Rather than having to
distribute locations of models, tokens, and enforce security and usage, centralizing models and making them discoverable
enables a single source of truth for which models are available for which team and their usage. Gateways enable a
consistent API for models and manage the provider specific configuration so teams are able to focus on their
application.

## Routing Optimizations

As the gateway becomes the entrypoint for all the models provided by the organization, optimizations can now be made for
different purposes. For instance, if a request is made to a gateway for a specific model, the gateway may try that
model. If the model is down for any reason, the gateway can chose to send the request to a different model as a
failover. The gateway may also analyze the request and decide whether to send the request to a large model or a small
model for cost purposes. Not all requests need to be sent to the largest Foundation Models, but given the request and
importance, it may be possible to send the request to a smaller model for a minor accuracy tradeoff.

## Guardrails

Centralizing models has the benefit of enabling a common place to put guardrails. For instance, a platform team may want
to ensure that all requests go through a Personally Identifiable Information (PII) guardrail to ensure that PII data
does not get exposed. Another common guardrail may be one that ensures prompt injection or other LLM exploits are not
occurring by any bad actors. This eases the burden of security from application teams and allows the platform teams to
manage this in a more consistent manner. 

## Governance and Observability

### Prompt Management

### Logs and Tracing

