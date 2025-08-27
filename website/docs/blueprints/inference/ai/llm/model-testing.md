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

With the model running, we can take a look at testing its configuration. We use a project
called [GuideLLM](https://github.com/vllm-project/guidellm). GuideLLM enables model benchmarking using different
scenarios. When testing a model, there are a few objectives:

- Testing: Identify whether the model configuration is able to support the Service Level Objectives (SLOs) for the
  model.
- Evaluation: Identify whether the model is able to address the use case by generating the output as expected.

Some parameters that can be tweaked to improve SLOs:

- Instance Size/GPU Type
- Model Size
- Context Length
- Max number of batched tokens
- Max number of sequences
- Block Size
- Chunked Prefill

Some SLOs to look for:

- Time to First Token (TTFT): Amount of time taken to generate the first token
- Time Per Output Token (TPOT): Amount of time taken between tokens
- E2E Request Latency: End to end request latency
- Queue Time: How long the request was in the queue
- Request Prefill time: How long the request was in the prefill stage
- Request Decode Time: How long the request was in the decode stage.

Testing Parameters:

- Rate Type (constant | poisson | sweep): rate of requests per seconds. What is the expected pattern of requests for
  this model.
- Max Seconds: maximum number of seconds to run for each benchmark
- Max Requests: maximum number of requests to run for each benchmark
- Data: Specifies the dataset source. Synthetic data is also supported, the following are recommended profiles based on
  use case:

```
    Chat: --data "prompt_tokens=512,output_tokens=256"
    RAG: --data "prompt_tokens=4096,output_tokens=512"
    Summarization: --data "prompt_tokens=1024,output_tokens=256"
    Code Generation: --data "prompt_tokens=512,output_tokens=512"
```

A good first step is to benchmark the default inference server arguments. This is very simple to do using
the [inference-charts]()

We can get the summary of the benchmark by looking at the logs:

```bash
kubectl logs llama-32-1b-vllm
```

We can also get the result of the benchmark off the pod:

```bash
kubectl cp llama-32-1b-vllm:/results/benchmarks.json ./benchmarks.json
```

### Interpreting the Results

### Retesting with new Parameters

Let's change the `max_num_batched_tokens`. We are trying to reduce the overall request latency so we will reduce the
batched tokens. This has the effect of reducing the inter-token latency because we are prefilling less. Let's test again
and see if that's true:

...

As you can see from the results, that is in fact true, but has the tradeoff of having processed fewer full requests. If
we were trying to reduce the overall request length, but process as many requests, we may have to add another model
replica and load balance between them. Further tuning of the model parameters may also offset the number of requests
processed. It is important to optimize the model using representative data; otherwise the adjustments made may not
reflect what happens in production. 

## Evaluation

Answering the second question requires having a dataset with which to test the model. The dataset has inputs to the
model
and a set of ground truth expected outputs. The possible options to tweak to improve the output of the model are:

- Change the `Max Model Length`.
- Change the model.

While there are fewer possible things to tweak, comparing the model output to the ground truth is more difficult.

### Qualitative Evaluation

A first step can be to send some inputs to the model and look at the output. A quick glance may highlight whether the
model produces usable results.

### Evaluation Metrics (ROUGE, BLUE)

### LLM As a Judge (context)

