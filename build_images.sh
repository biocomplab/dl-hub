#!/bin/bash

CUDA_VERSION=${1:-11.2.2}
CUDNN_VERSION=${2:-8}
CUDA_BASE=nvidia/cuda:${CUDA_VERSION}-cudnn${CUDNN_VERSION}-devel-ubuntu20.04
# docker rmi cuda-dl-lab:previous
# docker tag cuda-dl-lab:latest cuda-dl-lab:previous
LAST_ID=$(docker images cuda-dl-lab:latest --format "{{.ID}}")
docker tag $LAST_ID cuda-dl-lab:previous
docker build -t cuda-base-notebook --build-arg ROOT_CONTAINER=${CUDA_BASE} https://github.com/jupyter/docker-stacks.git#master:base-notebook/
docker build -t cuda-minimal-notebook --build-arg BASE_CONTAINER=cuda-base-notebook https://github.com/jupyter/docker-stacks.git#master:minimal-notebook/
docker build -t cuda-scipy-notebook --build-arg BASE_CONTAINER=cuda-minimal-notebook https://github.com/jupyter/docker-stacks.git#master:scipy-notebook/
docker build -t cuda-dl-lab -t cuda-dl-lab:${CUDA_VERSION}-cudnn${CUDNN_VERSION} --build-arg BASE_CONTAINER=cuda-scipy-notebook --build-arg CUDA_VERSION=${CUDA_VERSION} --build-arg CUDNN_VERSION=${CUDNN_VERSION} ./cuda-dl-lab/
docker tag cuda-dl-lab mmrl/cuda-dl-lab
docker image push mmrl/cuda-dl-lab
