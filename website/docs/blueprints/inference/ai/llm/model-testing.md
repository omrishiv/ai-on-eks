---
sidebar_label: Model Testing and Evaluation
---

# Model Testing and Evaluation

Model testing and evaluation refers to the process of understanding whether a model is performing well based on both a
resource perspective (testing): latency, throughput, time to first token, etc., and accurately on your data
(evaluation). The two may sometimes be at odds with one another, for instance, you may need increasingly larger models,
which take longer to run to provide accurate results for your data, or you may need bigger instances to lower the
latency. Being able to baseline models is the first step to being able to evaluate whether tweaking the model parameters
or switching models is necessary to improve the metric you are after.

## Testing

Testing requires a running model endpoint. This may be a single instance of a model or one set up behind a load
balancer. In this case, let's deploy the Llama 3.2-1B model from the [model identification](./model-identification.md)
section.

## Evaluation
