ARG JUPYTERHUB_VERSION=1.3
FROM jupyterhub/jupyterhub:${JUPYTERHUB_VERSION}
RUN pip install --upgrade pip
RUN pip install \
	dockerspawner \
	jupyterhub-dummyauthenticator \
	#oauthenticator \
	jupyterhub-ldapauthenticator
	#jupyterhub-kerberosauthenticator
#COPY jupyterhub_config.py .
#RUN jupyterhub --generate-config
#RUN cat jupyterhub_config.py

# WORKDIR /srv/jupyterhub/
COPY jupyterhub_config.py .
#ENV DOCKER_JUPYTER_CONTAINER=gpu-lab-container \
    #DOCKER_JUPYTER_IMAGE=mmrl/dl:PT1.6_TF2.2 \
#    DOCKER_JUPYTER_IMAGE='jupyterhub/singleuser:latest' \
    #DOCKER_NETWORK_NAME=bridge \
#    DOCKER_NETWORK_NAME=hub_default
    #HUB_IP=''
CMD ["jupyterhub", "-f", "jupyterhub_config.py"]
