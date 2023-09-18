ARG JUPYTERHUB_VERSION=4.0.2
FROM jupyterhub/jupyterhub:${JUPYTERHUB_VERSION}
RUN pip install --upgrade pip
RUN pip install \
	dockerspawner \
    #https://github.com/andreas-h/sshauthenticator/archive/v0.1.zip
	#oauthenticator \
	jupyterhub-dummyauthenticator \
	#jupyterhub-ldapauthenticator \
	#jupyterhub-kerberosauthenticator \
	nbgrader

WORKDIR /srv/jupyterhub/
#RUN jupyterhub --generate-config
COPY jupyterhub_config.py .
#COPY cert/chain.crt .
#COPY cert/key/titan.key .
#ENV DOCKER_JUPYTER_CONTAINER=gpu-lab-container \
#    DOCKER_JUPYTER_IMAGE='jupyterhub/singleuser:latest' \
#    DOCKER_NETWORK_NAME=hub_default \
#    HUB_IP=''
CMD ["jupyterhub", "-f", "jupyterhub_config.py"]
