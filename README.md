---
layout: default
title: Home
nav_order: 1
---

---

## Get started - Daily's mediapipe fork

Here is a list of build commands for reference. These commands are to be run from the root folder of mediapipe-fork. The root folder is the folder with the WORKSPACE file

1. Build a selfie-segmentation unix executable

`bazel build -c opt --define MEDIAPIPE_DISABLE_GPU=1 //mediapipe/examples/desktop/selfie_segmentation:selfie_segmentation_cpu`

The built files can be found inside a folder called `bazel-bin`

2. To run the built executable with a processing graph

```
GLOG_logtostderr=1 \
./bazel-bin/mediapipe/examples/desktop/selfie_segmentation/selfie_segmentation_cpu \
--calculator_graph_config_file=./mediapipe/graphs/selfie_segmentation/selfie_segmentation_cpu.pbtxt
```
