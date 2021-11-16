# dl-hub
**A Dockerised JupyterHub environment for Deep Learning with GPUs**

JupyterHub is a customisable, flexible, scalable, portable system for bringing Jupyter notebooks (labs) to groups of users. It gives users access to computing resources (including GPUs!) through a browser without them needing to install, configure or maintain the computing environment. 

| [<img src="https://jupyterhub.readthedocs.io/en/stable/_images/jhub-fluxogram.jpeg" alt="JupyterHub Schematic" width="600">](https://jupyterhub.readthedocs.io/en/stable/) |
| :--: |
| *JupyterHub schematic from the [official documentation](https://jupyterhub.readthedocs.io/en/stable/).* |

This repository builds a hub which spawns isolated, dockerised [JupyterLab](https://jupyterlab.readthedocs.io/en/latest/) environments with mounted GPUs for deep learning acceleration. The containers are spawned from images based on the [Jupyter Docker Stacks](https://github.com/jupyter/docker-stacks) but built using an [NVIDIA CUDA base image](https://hub.docker.com/r/nvidia/cuda). Note that GPUs are currently shared between all spawned JupyterLab environments although it may be possible to allocate them in a round-robin system. 

## Setup
These instructions assume you are using the latest Ubuntu LTS on your server. To install and setup the required packages, execute these commands:

### Install NVIDIA drivers
First update the system and blacklist the `nouveau` drivers.
```bash
# Update the installed packages
sudo apt-get update && sudo apt-get upgrade

# Blacklist noveau
sudo bash -c "echo blacklist nouveau > /etc/modprobe.d/blacklist-nvidia-nouveau.conf"
sudo bash -c "echo options nouveau modeset=0 >> /etc/modprobe.d/blacklist-nvidia-nouveau.conf"
```
It may be necessary to reboot at this stage: `sudo reboot`.
```bash
# Versions default to the last (tested working) versions
# Search here: https://www.nvidia.com/Download/index.aspx?lang=en-uk
NVIDIA_DRIVER_VERSION=470.82.00  # ${1:-460.39}

# Stop X-server
sudo service lightdm stop  # Assuming a lightdm desktop. Alternative: gdm | kdm
# sudo init 3  # This may also be necessary

# Install NVIDIA drivers
sudo apt-get install build-essential gcc-multilib dkms
curl -o nvidia-drivers.run https://uk.download.nvidia.com/XFree86/Linux-x86_64/$NVIDIA_DRIVER_VERSION/NVIDIA-Linux-x86_64-$NVIDIA_DRIVER_VERSION.run
chmod +x nvidia-drivers.run
sudo ./nvidia-drivers.run --dkms --no-opengl-files
# run nvidia-xconfig: Y

# Verify installation
nvidia-smi
# read -p "Press any key to reboot..." -n1 -s
sudo reboot  # Alternative: sudo service lightdm start
```

### Install Docker and nvidia-docker
```bash
# https://docs.docker.com/compose/install/
DOCKER_COMPOSE_VERSION=1.29.2  # ${1:-1.28.2}

# Install Docker
sudo apt-get install \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
# Verify key
sudo apt-key fingerprint 0EBFCD88

# The standard command was changed to avoid /etc/apt/sources.list being purged by Puppet
sudo echo \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable" \
   > /etc/apt/sources.list.d/docker.list
sudo apt-get update && sudo apt-get install docker-ce docker-ce-cli containerd.io
# Verify installation
# sudo docker run hello-world

# Install nvidia-docker. NOTE: nvidia-docker2 is still required for Kubernetes but otherwise only nvidia-container-toolkit
distribution=$(. /etc/os-release;echo $ID$VERSION_ID) \
   && curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | sudo apt-key add - \
   && curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list | sudo tee /etc/apt/sources.list.d/nvidia-docker.list

# NOTE: I had to manually edit /etc/apt/sources.list.d/nvidia-docker.list to change 18.04 to 20.04
# Install nvidia-docker2 to provide the legacy runtime=nvidia for use with docker-compose (see: https://github.com/NVIDIA/nvidia-docker/issues/1268#issuecomment-632692949)
sudo apt-get update && sudo apt-get install -y nvidia-docker2
# sudo apt-get update && sudo apt-get install -y nvidia-container-toolkit
sudo systemctl restart docker
# Verify installation
docker run --rm --gpus all nvidia/cuda:11.4.2-cudnn8-devel-ubuntu20.04 nvidia-smi

# Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/download/$DOCKER_COMPOSE_VERSION/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
# sudo chmod +x /usr/local/bin/docker-compose
sudo chgrp docker /usr/local/bin/docker-compose
sudo chmod 750 /usr/local/bin/docker-compose
```

### Create `.env` file for sensitive configuration details
In addition to these files, create a `.env` file with the necessary secrets set as variables e.g.:

```python
COMPOSE_PROJECT_NAME=dl_hub
AUTH_SERVER_ADDRESS=authenticator.uni.ac.uk
ADMIN_USERS='user1 user2 user3'  # A string of user names separated by spaces
# DOCKER_NETWORK_NAME=${COMPOSE_PROJECT_NAME}_default
```
See [here](https://docs.docker.com/compose/environment-variables/) for documentation on setting and passing environment variables to `docker-compose`.

### Authentication

Depending on your environment, you will probably want to configure a more sophisticated authenticator e.g. the [`PAMAuthenticator` or `ldapauthenticator`](https://github.com/jupyterhub/jupyterhub#configuration). You will need configuration details from the university system administrators for this in order to use the existing user authentication systems. These details should be configured in [`jupyterhub/jupyterhub_config.py`](https://github.com/bdevans/dl-hub/blob/main/jupyterhub/jupyterhub_config.py) (with secrets in `.env` as necessary).

Your organisation may also be able to issue and sign SSL certificates for the server. This repository currently assumes they are in `jupyterhub/cert/`. Appropriate configuration settings then need to be set in [`jupyterhub/jupyterhub_config.py`](https://github.com/bdevans/dl-hub/blob/main/jupyterhub/jupyterhub_config.py) e.g.: 

```python
# Configure SSL
c.JupyterHub.ssl_key = '/srv/jupyterhub/hub.key'
c.JupyterHub.ssl_cert = '/srv/jupyterhub/chain.crt'
c.JupyterHub.port = 443

# Configure configurable-http-proxy to redirect http to https
c.ConfigurableHTTPProxy.command = ['configurable-http-proxy', '--redirect-port', '80']
```

The corresponding lines where the certificates are installed in [`jupyterhub/Dockerfile`](https://github.com/bdevans/dl-hub/blob/main/jupyterhub/Dockerfile) will also need to be edited. 

### Optional additional steps

* Add users to the `docker` group to let them use docker on the server without `sudo`
    - `sudo groupadd docker`  # It may already exist
    - `sudo nano /etc/adduser.conf` then add the following lines
        * `EXTRA_GROUPS="docker"`  # Separate groups with spaces e.g. `"docker users"`
        * `ADD_EXTRA_GROUPS=1`
    - `sudo usermod -aG docker USERNAME`  # Add user account to the `docker` group
    - `newgrp docker`  # Activate changes
    - `docker run --rm hello-world`  # Verify changes
* Mount additional partitions
* Move Docker disk to separate partition
    - `sudo systemctl stop docker`
    - Copy or move the data e.g.: `sudo rsync -aP /var/lib/docker/ /path/to/your/docker_data`
    - Edit `/etc/docker/daemon.json` to add `"data-root": "/path/to/your/docker_data"`
    - `sudo systemctl start docker`
* Customise JupyterHub
    - Edit `jupyterhub_config.py`
* Set up build target of `jupyter/docker-stacks with --build-arg`
* Install extras, e.g.:
    - `screen`
    - `tmux`
    - `htop`
* Create a list or dictionary of allowed images which will be presented as a dropdown list of options for users at logon e.g.:
    - `c.DockerSpawner.allowed_images = {"Latest": "cuda-dl-lab:11.4.2-cudnn8", "Previous": "cuda-dl-lab:11.2.2-cudnn8"}`
    - `c.DockerSpawner.allowed_images = ["cuda-dl-lab:11.4.2-cudnn8", "cuda-dl-lab:11.2.2-cudnn8"]`
* Schedule a backup!

## Updating

### [NVIDIA drivers](https://www.nvidia.co.uk/Download/index.aspx?lang=en-uk)
* Find the latest Linux 64-bit drivers for your graphics cards: https://www.nvidia.co.uk/Download/index.aspx?lang=en-uk
```
sudo service lightdm stop  # or gdm or kdm depending on your display manager
curl -o nvidia-drivers.run https://uk.download.nvidia.com/XFree86/Linux-x86_64/$NVIDIA_DRIVER_VERSION/NVIDIA-Linux-x86_64-$NVIDIA_DRIVER_VERSION.run
chmod +x nvidia-drivers.run
sudo ./nvidia-drivers.run --dkms --no-opengl-files
nvidia-smi
sudo reboot
```
* Confirm the drivers work: `docker run --rm --gpus all nvidia/cuda:11.4.2-base nvidia-smi`

### `docker` and `nvidia-docker`
* `sudo apt update && sudo apt upgrade`

### [`docker-compose`](https://github.com/docker/compose/releases)
```
docker-compose -v  # Check if the installed version is up-to-date
DOCKER_COMPOSE_VERSION=1.29.2
sudo mv /usr/local/bin/docker-compose /usr/local/bin/docker-compose-previous
sudo curl -L "https://github.com/docker/compose/releases/download/$DOCKER_COMPOSE_VERSION/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chown root:docker /usr/local/bin/docker-compose
sudo chmod g+rx /usr/local/bin/docker-compose
```

### [Docker CUDA images](https://hub.docker.com/r/nvidia/cuda/tags?page=1&name=devel-ubuntu)
* Edit `build_images.sh` (or pass arguments) to update:
  * `CUDA_VERSION`
  * `CUDNN_VERSION`
  * Eventually `ubuntu-20.04`

* Edit `cuda-dl-lab/Dockerfile` to update with new versions:
  * [`'tensorflow-gpu==2.6.2'`](https://github.com/tensorflow/tensorflow/releases): [Docs](https://www.tensorflow.org/install/gpu); [Code](https://github.com/tensorflow/tensorflow)
  * [`TF_MODELS_VERSION=v2.6.0`](https://github.com/tensorflow/models/releases): [Code](https://github.com/tensorflow/models)
  * [`'torch==1.10.0'`](https://github.com/pytorch/pytorch/releases): [Docs](https://pytorch.org/get-started/locally/); [Code](https://github.com/pytorch/pytorch)
  * [`magma-cuda112`](https://anaconda.org/search?q=magma): https://anaconda.org/search?q=magma

* `make build`

### [JupyterHub](https://github.com/jupyterhub/jupyterhub/tags)
* Update `JUPYTERHUB_VERSION=1.5.0` in:
  - `docker-compose.yml`
  - `jupyterhub/Dockerfile` (optional)

* Edit `jupyterhub/jupyterhub_config.py` for any additional volumes

### Restart the Hub
* `make clean`
