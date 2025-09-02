---
sidebar_label: Model Scaling
---

# Model Scaling

Once a model is identified, tested on representative data, optimized, and deployed, it may come time to use more
advanced scaling techniques to 1) save cost on only running the amount of model replicas you need to serve the request
throughput you have, and 2) facilitate scaling up model replicas so your users are not left waiting due to a rush of
requests. The process for dynamically scaling replicas based on demand is known as autoscaling. In this section, we talk
about both Node and Pod autoscaling and how to ensure our service keeps up with the demand placed on it.

# Node Autoscaling

Node autoscaling ensures we do not run more compute than is necessary for our requirements. Node autoscaling is a bit
easier to understand as it is handled entirely by [Karpenter](#). Karpenter is available as part of
the [inference ready cluster](#), but it can also be deployed in other clusters following the instructions. Karpenter
will watch for Kubernetes pods that are not scheduled and will request a new node from AWS that will fulfill the
requests needed. Karpenter does this in a cost-efficient manner as it will look for the most cost-effective node to
faciliate the resource request. If resources are removed from an instance due to workloads terminating, Karpenter will
attempt to scale back the node to stop incurring costs on resources that are no longer needed. 

# Pod Autoscaling



# Challenges

- Cold Start
- Resource Skew
