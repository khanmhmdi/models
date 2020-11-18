<!--- 0. Title -->
# ResNet50 v1.5 FP32 inference

<!-- 10. Description -->

This document has instructions for running ResNet50 v1.5 FP32 inference using
Intel® Optimizations for TensorFlow* on Kubernetes*.



<!--- 20. Download link -->
## Download link

[resnet50v1-5-fp32-inference-k8s.tar.gz](https://storage.googleapis.com/intel-optimized-tensorflow/models/v2_1_0/resnet50v1-5-fp32-inference-k8s.tar.gz)

<!--- 30. Datasets -->
## Dataset

OPTIONAL: The ImageNet dataset can be used in these ResNet50 v1.5 Kubernetes examples.
You can download and preprocess the ImageNet dataset using the [instructions here](/datasets/imagenet/README.md).
After running the conversion script you should have a directory with the
ImageNet dataset in the TF records format.


<!--- 40. Quick Start Scripts -->
## Quick Start Scripts

| Script name | Description |
|-------------|-------------|
| [`run_tf_serving_client.py`](run_tf_serving_client.py) | Runs gRPC client for multi-node batch and online inference. |
| [`multi_client.sh`](multi_client.sh) | Runs multiple parallel gRPC clients for multi-node batch and online inference. |

These quickstart scripts can be run in this environment:
* [Kubernetes](#kubernetes)


<!--- 70. Kubernetes -->
## Kubernetes

Download and untar the ResNet50 v1.5 FP32 inference package.
```
wget https://storage.googleapis.com/intel-optimized-tensorflow/models/v2_1_0/resnet50v1-5-fp32-inference-k8s.tar.gz
tar -xvf resnet50v1-5-fp32-inference-k8s.tar.gz
```

### Execution

The Kubernetes* package for `ResNet50 v1.5 FP32 inference` includes a kubernetes serving deployment.
The directory tree within the model package is shown below, where the serving directory is below the
[mlops](https://en.wikipedia.org/wiki/MLOps) directory:

```
quickstart
└── mlops
    └── serving
```

#### prerequisites

Both single and multi-node deployments use [kustomize-v3.8.4](https://github.com/kubernetes-sigs/kustomize/releases/tag/kustomize%2Fv3.8.4) to configure deployment parameters. This archive should be downloaded, extracted and the kustomize command should be moved to a directory within your PATH. You can verify the correct version of kustomize has been installed by typing `kustomize version`. On MACOSX you would see

```
{Version:kustomize/v3.8.4 GitCommit:8285af8cf11c0b202be533e02b88e114ad61c1a9 BuildDate:2020-09-19T15:39:21Z GoOs:darwin GoArch:amd64}
```


The kustomization files that the kustomize command references are located withing the following directory:

```
resnet50v1-5-fp32-inference-k8s/quickstart/mlops/serving/kustomization.yaml
```

#### TensorFlow Serving

The multi-node serving use case makes the following assumptions:
- the model directory is a shared volume mounted cluster wide
- a saved model has been generated and saved under the model directory volume

TensorFlow Serving is run by submitting a deployment and service yaml file to the k8s api-server,
which results in the creation of pod replicas, each serving the model on a different node of the cluster.

The steps follow the
[TensorFlow Serving with Kubernetes instructions](https://www.tensorflow.org/tfx/serving/serving_kubernetes)
with the exception that it does not use a Google Cloud Kubernetes
cluster. Since the Kubernetes cluster being used does not have a load
balancer, the configuration is setup for NodePort, which will allow
external requests.

Make sure you are inside the serving directory:

```
cd resnet50v1-5-fp32-inference-k8s/quickstart/mlops/serving
```

The parameters that can be changed within the serving resources are shown in the table[^1] below:

|            NAME             |                  VALUE                   |    SET BY     |         DESCRIPTION         | COUNT | REQUIRED |
|-----------------------------|------------------------------------------|---------------|-----------------------------|-------|----------|
| FS_ID                       | 0                                        | model-builder | owner id of mounted volumes | 1     | Yes      |
| GROUP_ID                    | 0                                        | model-builder | process group id            | 2     | Yes      |
| GROUP_NAME                  | root                                     | model-builder | process group name          | 1     | Yes      |
| IMAGE_SUFFIX                |                                          | model-builder | appended to image name      | 1     | No       |
| MODEL_BASE_NAME             | savedmodels                              | model-builder | base directory name         | 1     | Yes      |
| MODEL_DIR                   | /models                                  | model-builder | mounted model directory     | 3     | Yes      |
| MODEL_NAME                  | resnet50v1_5                             | model-builder | model name                  | 1     | No       |
| MODEL_PORT                  | 8500                                     | model-builder | model container port        | 2     | Yes      |
| MODEL_SERVICE_PORT          | 8501                                     | model-builder | model service port          | 1     | Yes      |
| MODEL_SERVING_IMAGE_NAME    | intel/intel-optimized-tensorflow-serving | model-builder | image name                  | 1     | No       |
| MODEL_SERVING_IMAGE_VERSION | 2.3.0                                    | model-builder | image tag                   | 1     | No       |
| MODEL_SERVING_LABEL         | resnet50v1-5-fp32-server                 | model-builder | selector label              | 4     | No       |
| MODEL_SERVING_NAME          | resnet50v1-5-fp32-inference              | model-builder | model serving name          | 2     | No       |
| REGISTRY                    | docker.io                                | model-builder | image location              | 1     | No       |
| REPLICAS                    | 3                                        | model-builder | number of replicas          | 1     | Yes      |
| USER_ID                     | 0                                        | model-builder | process owner id            | 2     | Yes      |
| USER_NAME                   | root                                     | model-builder | process owner name          | 1     | Yes      |

[^1]: The serving parameters table is generated by `kustomize cfg list-setters . --markdown`. See [list-setters](https://github.com/kubernetes-sigs/kustomize/blob/master/cmd/config/docs/commands/list-setters.md) for explanations of each column.

For example to change the MODEL_SERVICE_PORT from 8500 to 9500

```
kustomize cfg set . MODEL_SERVICE_PORT 9500
```

The required column that contains a 'Yes' indicates values that are often changed by the user.
The 'No' values indicate that the default values are fine, and seldom changed. Note that the mlops user may run the
serving process with their own uid/gid permissions by using kustomize to change the securityContext in the deployment.yaml file.
This is done by running the following:

```
kustomize cfg set . FS_ID <Group ID>
kustomize cfg set . GROUP_ID <Group ID>
kustomize cfg set . GROUP_NAME <Group Name>
kustomize cfg set . USER_ID <User ID>
kustomize cfg set . USER_NAME <User Name>
```

Finally, the namespace can be changed by the user from the default namespace by running the kustomize command:

```
kustomize edit set namespace $USER
```

Note: if the namespace is changed from default, it should be created prior to deployment.
Once the user has changed parameter values they can then deploy the serving manifests by running:

```
kustomize build > serving.yaml
kubectl apply -f serving.yaml
```

Once the kubernetes workflow has been submitted, the status can be
checked using (you will need to substitute a pod's name in the second line):
```
kubectl get pods
kubectl logs -f <pod name>
```

##### TensorFlow Serving Client

Once all the pods are running, the TensorFlow
Serving gRPC client can be used to run inference on the served model.

Prior to running the client script, install the following dependency in
your environment:
* tensorflow-serving-api

The client script accepts an optional argument `--data_dir` pointing to a directory of images in TF records format. 
If the argument is not present, dummy data will be used instead. Then the script formats the data as a gRPC request object and
calls the served model API. Benchmarking metrics are printed out.

Run the [run_tf_serving_client.py](run_tf_serving_client.py) script with
the `--help` flag to see the argument options:
```
$ python resnet50v1-5-fp32-inference-k8s.tar.gz/quickstart/run_tf_serving_client.py --help
Send TF records or simulated image data to tensorflow_model_server loaded with ResNet50v1_5 model.

flags:

run_tf_serving_client.py:
  --batch_size: Batch size to use
    (default: '1')
    (an integer)
  --data_dir: Path to images in TF records format
    (default: '')
  --server: PredictionService host:port
    (default: 'localhost:8500')
```

1. Find the `INTERNAL-IP` of one of the nodes in your cluster using
   `kubectl get nodes -o wide`. This IP should be used as the server URL
   in the `--server` arg.

1. Get the `NodePort` using `kubectl describe service`. This `NodePort`
   should be used as the port in the `--server` arg.

1. Run the client script with your preferred parameters. For example:
   ```
   python resnet50v1-5-fp32-inference-k8s.tar.gz/quickstart/run_tf_serving_client.py --server <Internal IP>:<Node Port> --data_dir <path to TF records> --batch_size <batch size>
   ```
   The script will call the served model using data from the `data_dir` path or simulated data
   and output performance metrics.
   
1. If you want to send multiple parallel calls to the server, you can use the `multi_client.sh` script.
   Its options are:
   ```
   --model: Model to be inferenced
   --batch_size: Number of samples per batch (default 1)
   --servers: "server1:port;server2:port" (default "localhost:8500")
   --clients: Number of clients per server (default 1)
   ```
   
   You must be in the quickstart folder to run it, and the script does not currently support a `data_dir` argument (only runs with simulated data).
   Example:
   
   ```
   cd resnet50v1-5-fp32-inference-k8s.tar.gz/quickstart
   bash multi_client.sh --model=resnet50v1_5 --servers="<Internal IP>:<Node Port>" --clients=5
   cd ../../
   ```

##### Clean up the pipeline

To clean up the served model, delete the service,
deployment, and other resources using the following commands:
```
kubectl delete -f serving.yaml
```

<!--- 80. License -->
## License

[LICENSE](/LICENSE)
