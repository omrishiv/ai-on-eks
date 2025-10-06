---
sidebar_label: Model Productionization
---

# Model Productionization

Model Productionization is a large topic regarding multiple techniques that support the deployment and
operationalization step of running models in production beyond simple autoscaling. Once simple load balancing techniques
begin to become bottlenecks, managing multiple LoRA adapters becomes necessary, needing to share a KV cache between
models or separating the Prefill and Decode stage of the LLM become necessary, more advanced techniques are needed.
Tools like [Nvidia Dyanmo](https://www.nvidia.com/en-us/ai/dynamo/) and [AIBrix](https://aibrix.readthedocs.io/latest/)
support advanced LLM techniques to ease some of the burden of productionizing these models.

## Model Aware Routing

Model Aware Routing is an advanced routing technique for load balancing requests between model replicas. This is needed
due to the stochastic nature of LLMs where processing times per request become less predictable. Model Aware Routing
uses techniques like KV Cache awareness to know which model replica may have a cache available for the prompt. Other
strategies supporting more intelligent load balancing and routing include routing to replicas with the fewest queued
requests, smallest KV cache, lowest latency, fewest computed tokens, and others.

## LoRA Management

LoRA Management enables a centralized repository of LoRA adapters with the ability to dynamically load/unload the
adapters as needed for the requests. Coupled with Mode Aware Routing, this ability allows for optimized processing of
requests while supporting the ability to tailor a more generic model to a given request. The model productionization
tool is able to take a more generic LLM and enhance it with a LoRA adapter and then unload it when it is no longer
needed.

## Distributed KV Cache

KV Cache enables model replicas to store pre-computed attention values for a given request. Traditionally, each model
replica had to compute and store its own cache. By enabling a distributed KV cache, model replicas are able to look up
this computation rather than perform it (if it is available), significantly speeding up the processing of a given input.
This can have the benefit of requiring fewer model replicas as overall throughput may be increased. The cache
availablility can also be tiered so that more frequent keys can be stored in GPU memory, while less frequently used keys
can be stored on distributed network storage like FSx.

## Prefill-Decode Disaggregation

Prefill-decode disaggregation decouples the prefill and decode phases of LLM generation. This has the benefit of
allowing the decoding phase to happen on larger instances while the prefill phase can happen on smaller instances.
Decoupling the two allows for potential cost optimization and performance improvements as resources can match the
request pattern better. Intelligent disaggregation enables prefill to happen locally on decode workers when the prefill
is small and there are available resources. 
