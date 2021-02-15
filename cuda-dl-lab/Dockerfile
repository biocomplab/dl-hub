ARG BASE_CONTAINER=cuda-scipy-notebook
FROM ${BASE_CONTAINER}

# Pass --build-arg values to set library versions
ARG CUDA_VERSION
ENV CUDA_VERSION=${CUDA_VERSION}
ARG CUDNN_VERSION
ENV CUDNN_VERSION=${CUDNN_VERSION}

# Install Tensorflow
RUN pip install --quiet \
    'tensorflow-gpu==2.4.1' \
    tf-explain && \
    fix-permissions $CONDA_DIR && \
    fix-permissions /home/$NB_USER

#ARG TF_MODELS_VERSION=master
# ARG TF_MODELS_VERSION=${TENSORFLOW_VERSION}
#ENV TF_MODELS_VERSION=${TF_MODELS_VERSION}
#RUN git clone -b ${TF_MODELS_VERSION} https://github.com/tensorflow/models.git /src/models

RUN pip install --quiet \
    'torch==1.7.1' \
    torchvision \
    torchaudio \
    pytorch-ignite && \
    fix-permissions $CONDA_DIR && \
    fix-permissions /home/$NB_USER

# Install extenstions
RUN conda install --quiet --yes \
    watermark \
    papermill && \
    #jupyterlab-git && \
    conda clean --all -f -y && \
    pip install --quiet \
        jupyterlab-git && \
    jupyter labextension install @jupyter-widgets/jupyterlab-manager --no-build && \
    jupyter lab build && \
    #npm cache clean --force && \
    #jupyter lab clean && \
    #rm -rf /home/$NB_USER/.cache/yarn && \
    fix-permissions $CONDA_DIR && \
    fix-permissions /home/$NB_USER

#RUN conda install --quiet --yes -c pytorch \
#    pytorch \
#    torchvision \
#    torchaudio \
#    ignite \
#    magma-cuda110 && \
#    conda clean --all -f -y && \
#    npm cache clean --force && \
#    jupyter notebook --generate-config && \
#    jupyter lab clean && \
#    rm -rf /home/$NB_USER/.cache/yarn && \
#    fix-permissions $CONDA_DIR && \
#    fix-permissions /home/$NB_USER

LABEL maintainer="ben.d.evans@gmail.com" \
    name="Deep learning image" \
    description="A Python based GPU-accelerated Jupyter image for deep learning." \
    org.opencontainers.image.authors="Ben Evans" \
    org.opencontainers.image.url="https://github.com/mmrl/dl"
