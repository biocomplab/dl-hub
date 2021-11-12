# dl-hub
A Dockerised JupyterHub environment for Deep Learning with GPUs

In addition to these files, create an `.env` file with the necessary secrets set as variables e.g.:

```python
COMPOSE_PROJECT_NAME=mmrl_hub
AUTH_SERVER_ADDRESS=authenticator.uni.ac.uk
ADMIN_USERS='user1 user2 user3'  # A string of user names seperated by spaces
# DOCKER_NETWORK_NAME=${COMPOSE_PROJECT_NAME}_default
```
