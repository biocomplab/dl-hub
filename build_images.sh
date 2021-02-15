#!/bin/bash

CUDA_VERSION=11.0.3
CUDNN_VERSION=8
CUDA_BASE=nvidia/cuda:${CUDA_VERSION}-cudnn${CUDNN_VERSION}-devel-ubuntu20.04
docker build -t cuda-base-notebook --build-arg ROOT_CONTAINER=${CUDA_BASE} https://github.com/jupyter/docker-stacks.git#master:base-notebook/
docker build -t cuda-minimal-notebook --build-arg BASE_CONTAINER=cuda-base-notebook https://github.com/jupyter/docker-stacks.git#master:minimal-notebook/
docker build -t cuda-scipy-notebook --build-arg BASE_CONTAINER=cuda-minimal-notebook https://github.com/jupyter/docker-stacks.git#master:scipy-notebook/
docker build -t cuda-dl-lab --build-arg BASE_CONTAINER=cuda-scipy-notebook --build-arg CUDA_VERSION=${CUDA_VERSION} --build-arg CUDNN_VERSION=${CUDNN_VERSION} ./cuda-dl-lab/
