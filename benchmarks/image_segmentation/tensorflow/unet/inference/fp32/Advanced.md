<!--- 0. Title -->
<!-- This document is auto-generated using markdown fragments and the model-builder -->
<!-- To make changes to this doc, please change the fragments instead of modifying this doc directly -->
# UNet FP32 inference - Advanced Instructions

<!-- 10. Description -->
This document has advanced instructions for running UNet FP32
inference, which provides more control over the individual parameters that
are used. For more information on using [`/benchmarks/launch_benchmark.py`](/benchmarks/launch_benchmark.py),
see the [launch benchmark documentation](/docs/general/tensorflow/LaunchBenchmark.md).

Prior using these instructions, please follow the setup instructions from
the model's [README](README.md) and/or the
[AI Kit documentation](/docs/general/tensorflow/AIKit.md) to get your environment
setup (if running in bare metal) and download the dataset, pretrained model, etc.
If you are using AI Kit, please exclude the `--docker-image` flag from the
commands below, since you will be running the the TensorFlow conda environment
instead of docker.

<!-- 55. Docker arg -->
Any of the `launch_benchmark.py` commands below can be run on bare metal by
removing the `--docker-image` arg. Ensure that you have all of the
[required prerequisites installed](README.md#bare-metal) in your environment
before running without the docker container.

<!-- 50. Launch benchmark instructions -->
Once your environment is setup, navigate to the `benchmarks` directory of
the model zoo and set environment variables pointing to the directory for the
pretrained model, model repository, and an output directory where log
files will be written.

```
# cd to the benchmarks directory in the model zoo
cd benchmarks

export OUTPUT_DIR=<directory where log files will be written>
export PRETRAINED_MODEL=<path to the pretrained model>
export TF_UNET_DIR=<path to the TF UNet directory tf_unet>
```

UNet FP32 inference can be run to test batch and online inference using the
following command:
```
python launch_benchmark.py \
  --model-name unet \
  --precision fp32 \
  --mode inference \
  --framework tensorflow \
  --benchmark-only \
  --batch-size 1 \
  --socket-id 0 \
  --checkpoint ${PRETRAINED_MODEL} \
  --model-source-dir ${TF_UNET_DIR} \
  --output-dir ${OUTPUT_DIR} \
  --docker-image intel/intel-optimized-tensorflow:1.15.2 \
  -- checkpoint_name=model.ckpt
```

Below is an example of the log file tail:

```
Time spent per BATCH: ... ms
Total samples/sec: ... samples/s
Ran inference with batch size 1
Log location outside container: {--output-dir value}/benchmark_unet_inference_fp32_20190201_205601.log
```
