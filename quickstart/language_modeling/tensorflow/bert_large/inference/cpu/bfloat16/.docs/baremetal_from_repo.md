<!--- 50. Bare Metal -->
## Bare Metal

> If you are running using AI Kit, first follow the
> [instructions here](/docs/general/tensorflow/AIKit.md) to get your environment setup.

To run on bare metal, the following prerequisites must be installed in your enviornment.
If you are using AI Kit, your TensorFlow conda environment should already have Python and
TensorFlow installed.
* Python 3
* [intel-tensorflow==2.4.0](https://pypi.org/project/intel-tensorflow/)
* git
* numactl
* unzip
* wget

Clone the Model Zoo repo:
```
git clone https://github.com/IntelAI/models.git
```

Download and unzip the pretrained model. The path to this directory should
be set as the `CHECKPOINT_DIR` before running quickstart scripts.
```
wget https://storage.googleapis.com/intel-optimized-tensorflow/models/v1_8/bert_large_checkpoints.zip
unzip bert_large_checkpoints.zip
```

Once the dependencies have been installed, set environment variables,
and then run a quickstart script. See the [datasets](#datasets) and
[list of quickstart scripts](#quick-start-scripts) for more details on
the different options.

The snippet below shows how to run a quickstart script:
```
# cd to your model zoo directory
cd models

export DATASET_DIR=<path to the dataset being used>
export CHECKPOINT_DIR=<path to the unzipped checkpoints>
export OUTPUT_DIR=<directory where log files will be saved>

# Run a script for your desired usage
./quickstart/language_modeling/tensorflow/bert_large/inference/cpu/bfloat16/<script name>.sh
```