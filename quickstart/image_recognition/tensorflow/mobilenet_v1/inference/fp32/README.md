# MobileNet V1 FP32 Inference

This document has instructions for running MobileNet V1 FP32 inference using
Intel-optimized TensorFlow.

Note that the ImageNet dataset is used in these MobileNet V1 examples. To download and preprocess
the ImageNet dataset, see the [scripts and instructions](https://github.com/tensorflow/models/tree/master/research/slim#an-automated-script-for-processing-imagenet-data)
from the TensorFlow models repo.

## Quick Start Scripts

| Script name | Description |
|-------------|-------------|
| [`fp32_online_inference.sh`](fp32_online_inference.sh) | Runs online inference (batch_size=1). |
| [`fp32_batch_inference.sh`](fp32_batch_inference.sh) | Runs batch inference (batch_size=100). |
| [`fp32_accuracy.sh`](fp32_accuracy.sh) | Measures the model accuracy (batch_size=100). |

These quickstart scripts can be run in different environments:
* [Bare Metal](#bare-metal)
* [Docker](#docker)

## Bare Metal

To run on bare metal, the following prerequisites must be installed in your environment:
* Python 3
* [intel-tensorflow==2.1.0](https://pypi.org/project/intel-tensorflow/)
* numactl

Download and untar the model package and then run a [quickstart script](#quick-start-scripts).

```
DATASET_DIR=<path to the preprocessed imagenet dataset>
OUTPUT_DIR=<directory where log files will be written>

wget https://ubit-artifactory-or.intel.com/artifactory/list/cicd-or-local/model-zoo/mobilenet-v1-fp32-inference.tar.gz
tar -xzf mobilenet_v1_fp32_inference.tar.gz
cd mobilenet_v1_fp32_inference

quickstart/<script name>.sh
```

## Docker

The model container `model-zoo:2.1.0-mobilenet-v1-fp32-inference` includes the scripts 
and libraries needed to run MobileNet V1 FP32 inference. To run one of the model
inference quickstart scripts using this container, you'll need to provide volume mounts for
the ImageNet dataset and an output directory where checkpoint files will be written.

```
DATASET_DIR=<path to the preprocessed imagenet dataset>
OUTPUT_DIR=<directory where log files will be written>

docker run \
  --env DATASET_DIR=${DATASET_DIR} \
  --env OUTPUT_DIR=${OUTPUT_DIR} \
  --env http_proxy=${http_proxy} \
  --env https_proxy=${https_proxy} \
  --volume ${DATASET_DIR}:${DATASET_DIR} \
  --volume ${OUTPUT_DIR}:${OUTPUT_DIR} \
  --privileged --init -t \
  amr-registry.caas.intel.com/aipg-tf/model-zoo:2.1.0-image-recognition-mobilenet-v1-fp32-inference \
  /bin/bash quickstart/<script name>.sh
```

## Advanced Options

See the [Advanced Options for Model Packages and Containers](ModelPackagesAdvancedOptions.md)
document for more advanced use cases.