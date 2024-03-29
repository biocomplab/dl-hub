ARG BASE_CONTAINER=cuda-scipy-notebook
FROM ${BASE_CONTAINER}

# Install extra packages
USER root
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        texlive-latex-extra \
        texlive-fonts-recommended \
        dvipng \
        cm-super \
	rsync && \
    apt-get clean && rm -rf /var/lib/apt/lists/*
USER ${NB_UID}
WORKDIR "${HOME}"

# Pass --build-arg values to set library versions
ARG CUDA_VERSION
ENV CUDA_VERSION=${CUDA_VERSION}
ARG CUDNN_VERSION
ENV CUDNN_VERSION=${CUDNN_VERSION}

# Install Tensorflow
RUN pip install --quiet \
    'pyyaml>=6.0.1' \
    'tensorflow==2.15.*' \
    'tf-models-official' \
    tf-explain && \
    fix-permissions "${CONDA_DIR}" && \
    fix-permissions "${HOME}"

RUN pip install --quiet \
    'torch==2.1.*' \
    torchvision \
    torchaudio \
    pytorch-ignite && \
    fix-permissions "${CONDA_DIR}" && \
    fix-permissions "/home/${NB_USER}"
# --index-url https://download.pytorch.org/whl/cu118

# Install extenstions
RUN conda install --quiet --yes \
    opencv \
    watermark \
    papermill && \
    #jupyterlab-git && \
    conda clean --all -f -y && \
    # Use --pre flag to get beta
    pip install --quiet --pre \
        jupyterlab-git && \
    pip install \
        jupyterlab-drawio && \
    jupyter labextension install @jupyter-widgets/jupyterlab-manager --no-build && \
    jupyter lab build && \
    #npm cache clean --force && \
    #jupyter lab clean && \
    #rm -rf /home/$NB_USER/.cache/yarn && \
    fix-permissions "${CONDA_DIR}" && \
    fix-permissions "/home/${NB_USER}"

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
    org.opencontainers.image.url="https://github.com/biocomplab/dl-hub"
