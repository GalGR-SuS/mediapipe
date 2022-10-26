#!/bin/bash

export GLOG_logtostderr=1
# GG: Bug workaround
export PYTHON_BIN_PATH="C:\Program Files\Python310\python.exe"
# Need bazel flag 'MEDIAPIPE_DISABLE_GPU=1' as desktop GPU is not supported currently.
bazel run --define MEDIAPIPE_DISABLE_GPU=1 \
    mediapipe/examples/desktop/hello_world:hello_world

# It should print 10 rows of Hello World!
# Hello World!
# Hello World!
# Hello World!
# Hello World!
# Hello World!
# Hello World!
# Hello World!
# Hello World!
# Hello World!
# Hello World!