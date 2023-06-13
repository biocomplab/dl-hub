import os


c.JupyterHub.hub_ip = os.environ["HUB_IP"]
c.JupyterHub.spawner_class = "dockerspawner.DockerSpawner"

# Configure Docker Spawner
c.DockerSpawner.image = os.environ["DOCKER_JUPYTER_IMAGE"] # or 'jupyterhub/singleuser:latest'
c.DockerSpawner.network_name = os.environ["DOCKER_NETWORK_NAME"]
# https://jupyterhub-dockerspawner.readthedocs.io/en/latest/spawner-types.html#using-docker-swarm-not-swarm-mode
# c.DockerSpawner.host_ip = "0.0.0.0"
c.DockerSpawner.host_ip = os.environ["DOCKER_NETWORK_NAME"]
# NOTE: This may need nvidia-docker2
c.DockerSpawner.extra_host_config = {'runtime': 'nvidia'}
# c.DockerSpawner.extra_host_config = {'gpus': 'all'}
c.DockerSpawner.remove_containers = True

# Set up volumes and mounts within spawned containers
notebook_dir = os.environ.get('DOCKER_NOTEBOOK_DIR') or '/home/jovyan/work'
c.DockerSpawner.notebook_dir = notebook_dir
# Mount the real user's Docker volume on the host to the notebook user's
# notebook directory in the container
c.DockerSpawner.volumes = {
    'jupyterhub-user-{username}': notebook_dir,
    #'jupyterhub-shared': '/home/jovyan/work/shared',
    #'/shared': '/home/jovyan/work/shared',
    '/shared': '/shared',
    #'jupyterhub-data': '/home/jovyan/work/data'
    '/home/{username}': '/home/jovyan/work/data'
}

# This is the simplest authenticator for setup and testing
c.JupyterHub.authenticator_class = 'dummyauthenticator.DummyAuthenticator'
# Set the password by adding PASSWORD="<password>" in the .env file
c.DummyAuthenticator.password = os.environ.get("PASSWORD")

# SSH Authenticator
#c.JupyterHub.authenticator_class = 'sshauthenticator.SSHAuthenticator'
#c.SSHAuthenticator.server_address = os.environ["AUTH_SERVER_ADDRESS"]
#c.SSHAuthenticator.server_port = 22

c.Authenticator.admin_users = set(os.environ.get("ADMIN_USERS").split(" "))
# c.JupyterHub.admin_access = True  # Admins can log in as other users

# TODO: Configure SSL
#c.JupyterHub.ssl_key = '/srv/jupyterhub/titan.key'
#c.JupyterHub.ssl_cert = '/srv/jupyterhub/chain.crt'
#c.JupyterHub.port = 443
c.JupyterHub.port = 80
# Configure configurable-http-proxy to redirect http to https
#c.ConfigurableHTTPProxy.command = ['configurable-http-proxy', '--redirect-port', '80']

c.Spawner.environment = {'GRANT_SUDO': 'yes'}
# c.Spawner.default_url = '/lab'
c.Spawner.cmd=["jupyter-labhub"]
