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

- Model Size
- Context Length
- Max number of batched tokens
- Max number of sequences
- Block Size
- Chunked Prefill

Some other items that can potentially improve SLOs:

- Updated libraries
- Instance Size/GPU Type

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
the [inference-charts](../../inference-charts.md).

### Deploy GuideLLM Test

From the inference charts, we can use the `values-guidellm-llama32-1b-vllm.yaml` to create the pod template and apply it

```bash
cd blueprints/inference/inference-charts/
helm template . --values values-guidellm-llama32-1b-vllm.yaml | kubectl apply -f -
```

This will create a pod called `benchmark-llama-32-1b-vllm` and start the benchmark. The benchmark will run multiple
tests against the model endpoint using a synthetic benchmark. You can also provide your own data to make the benchmark
more indicative of real-world performance by setting the `testing.parameters.data` field according to
the [data documentation](https://github.com/vllm-project/guidellm/blob/main/docs/datasets.md#data-arguments-overview).
Note: the "local" path is local to the benchmarking pod. You will need to make the path available to the pod.

We can get the summary of the benchmark by looking at the logs:

```bash
kubectl logs benchmark-llama-32-1b-vllm
```

We can also get the result of the benchmark off the pod:

```bash
kubectl cp benchmark-llama-32-1b-vllm:/results/benchmarks.json ./benchmarks.json
```

### Interpreting the Results

GuideLLM has a [section](https://github.com/vllm-project/guidellm?tab=readme-ov-file#3-analyze-the-results) on analyzing
the results and how they relate to SLOs.

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
model produces usable results. In this case, an instruction tuned model may be interesting to test. Let's
deploy [Llama 3 8B Instruction tuned](https://huggingface.co/NousResearch/Meta-Llama-3-8B-Instruct) using the inference
charts.

```bash
cd blueprints/inference/inference-charts/
helm template . --values values-llama-3-8b-instruct-vllm.yaml | kubectl apply -f -
```

Once the model is running, we can port forward and send a request

```bash
kubectl port-forward svc/llama-3-8b-instruct-vllm 8000

curl --location 'http://localhost:8000/v1/completions' \
--header 'Content-Type: application/json' \
--data '{
    "model": "NousResearch/Meta-Llama-3-8B-Instruct",
    "prompt": "Alice'\''s parents have three daughters: Amy, Jessy, and what’s the name of the third daughter?"
}'
```

```json
{
  "id": "cmpl-caad43aaafd545d88b248907206033de",
  "object": "text_completion",
  "created": 1759355785,
  "model": "NousResearch/Meta-Llama-3-8B-Instruct",
  "choices": [
    {
      "index": 0,
      "text": " Alice!\nSo, Alice's parents have three daughters, and one of them is",
      "logprobs": null,
      "finish_reason": "length",
      "stop_reason": null,
      "prompt_logprobs": null
    }
  ],
  "usage": {
    "prompt_tokens": 23,
    "total_tokens": 39,
    "completion_tokens": 16,
    "prompt_tokens_details": null
  },
  "kv_transfer_params": null
}
```

Sending the same prompt to a text generation model such as our previously deployed Llama 3.2-1B model would return
something like

```json
{
  "id": "cmpl-f2b12932ecf947c9b411e8efb200862f",
  "object": "text_completion",
  "created": 1759356077,
  "model": "NousResearch/Llama-3.2-1B",
  "choices": [
    {
      "index": 0,
      "text": " And the assumed name of the first daughter is?\nFord, John and Jennifer Fran",
      "logprobs": null,
      "finish_reason": "length",
      "stop_reason": null,
      "prompt_logprobs": null
    }
  ],
  "usage": {
    "prompt_tokens": 23,
    "total_tokens": 39,
    "completion_tokens": 16,
    "prompt_tokens_details": null
  },
  "kv_transfer_params": null
}
```

Not a useful response for answering the question, but maybe a good one if we were trying to generate text? Let's now
test the quality of the model using
the [Databricks Dolly 15K](https://huggingface.co/datasets/databricks/databricks-dolly-15k) dataset. This dataset has
15,000 rows of instructions and their expected responses. We can use GuideLLM to test this using the `data` parameter
set to the Hugging Face dataset id.

```bash
cd blueprints/inference/inference-charts/
helm template . --values values-guidellm-llama3-8b-instruct-vllm.yaml | kubectl apply -f -
```

This will run a test using the Databricks dataset instead of the synthetic one we used before. Let's again get the logs
for the benchmark:

```bash
kubectl logs benchmark-llama-3-8b-instruct-vllm
```

And the result of the benchmark off the pod:

```bash
kubectl cp benchmark-llama-3-8b-instruct-vllm:/results/benchmarks.json ./benchmarks.json
```

If we then open the `benchmarks.json` we can see all of the prompts sent to the model, the responses, and much of the
data about the request. We set the maximum output tokens to 16 during the test to stay consistent with vLLM's default
sampling value, so many of the responses may be incomplete, but we can compare the expectation from the dataset to what
we received from the model. Hugging Face provides
a [viewer](https://huggingface.co/datasets/databricks/databricks-dolly-15k/viewer) to see the dataset. If we look at the
first row, we see the prompt " When did Virgin Australia start operating?". If we look at the `benchmarks.json`, we can
search for this prompt. In our case:

```json
{
  "type_": "generative_text_response",
  "request_id": "f90f365b-16a7-4ce3-8a53-8d37c71458a3",
  "request_type": "text_completions",
  "scheduler_info": {
    "requested": true,
    "completed": true,
    "errored": false,
    "canceled": false,
    "targeted_start_time": 1759354691.715061,
    "queued_time": 1759354684.7064037,
    "dequeued_time": 1759354690.715497,
    "scheduled_time": 1759354690.715647,
    "worker_start": 1759354691.7165263,
    "request_start": 1759354691.7182198,
    "request_end": 1759354695.648075,
    "worker_end": 1759354695.6655831,
    "process_id": 4
  },
  "prompt": "When did Virgin Australia start operating?",
  "output": " Virgin Australia, previously known as Virgin Blue, began operating in 2000.",
  "prompt_tokens": 8,
  "output_tokens": 16,
  "start_time": 1759354691.7182198,
  "end_time": 1759354695.648075,
  "first_token_time": 1759354692.9827628,
  "last_token_time": 1759354695.6479197,
  "request_latency": 3.9298553466796875,
  "time_to_first_token_ms": 1264.543056488037,
  "time_per_output_token_ms": 166.57230257987976,
  "inter_token_latency_ms": 177.67712275187174,
  "tokens_per_second": 6.107095015667043,
  "output_tokens_per_second": 4.0713966771113625
}
```

We can compare that to the expected result from the dataset "Virgin Australia commenced services on 31 August 2000 as
Virgin Blue, with two aircraft on a single route." Our response is technically correct. 
