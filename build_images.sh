#!/bin/bash

usage() { echo "Usage: $0 [-c <x.y.z>] [-d <x>] [-n]" 1>&2; exit 1; }

#CUDA_VERSION=12.1.1
CUDA_VERSION=11.8.0
CUDNN_VERSION=8
OS_BASE=ubuntu22.04
NO_CACHE=""

while getopts ":c:d:b:n" opt; do
	case "${opt}" in
		c)
			CUDA_VERSION="${OPTARG}"
			;;
		d)
			CUDNN_VERSION="${OPTARG}"
			;;
		b)
			OS_BASE="${OPTARG}"
			;;
		n)
			NO_CACHE=--no-cache
			;;
		*)
			echo "Unknown option"
			usage
			;;
	esac
done
shift $((OPTIND-1))

CUDA_BASE=nvidia/cuda:${CUDA_VERSION}-cudnn${CUDNN_VERSION}-devel-${OS_BASE}

# docker rmi cuda-dl-lab:previous
# docker tag cuda-dl-lab:latest cuda-dl-lab:previous
LAST_ID=$(docker images cuda-dl-lab:latest --format "{{.ID}}")
docker tag $LAST_ID cuda-dl-lab:previous
docker build -t cuda-stacks-foundation ${NO_CACHE} --build-arg ROOT_CONTAINER=${CUDA_BASE} https://github.com/jupyter/docker-stacks.git#main:images/docker-stacks-foundation/
docker build -t cuda-base-notebook ${NO_CACHE} --build-arg BASE_CONTAINER=cuda-stacks-foundation https://github.com/jupyter/docker-stacks.git#main:images/base-notebook/
docker build -t cuda-minimal-notebook --build-arg BASE_CONTAINER=cuda-base-notebook https://github.com/jupyter/docker-stacks.git#main:images/minimal-notebook/
docker build -t cuda-scipy-notebook --build-arg BASE_CONTAINER=cuda-minimal-notebook https://github.com/jupyter/docker-stacks.git#main:images/scipy-notebook/
docker build -t cuda-dl-lab -t cuda-dl-lab:${CUDA_VERSION}-cudnn${CUDNN_VERSION} --build-arg BASE_CONTAINER=cuda-scipy-notebook --build-arg CUDA_VERSION=${CUDA_VERSION} --build-arg CUDNN_VERSION=${CUDNN_VERSION} ./cuda-dl-lab/
