# ifcopenshell-jupyterhub
A jupyterhub setup script with IfcOpenShell and PythonOCC modules

![jupyterhub IfcOpenShell pythonOCC screen-shot](https://raw.githubusercontent.com/IfcOpenShell/ifcopenshell-jupyterhub/master/static/screenshot.png)

This is a reference implementation to setup a dockerized multi-user jupyter notebook environment ideal for classroom, company or individual usage. Additional details on the jupyterhub setup including necessary precautions can be found here https://github.com/jupyterhub/jupyterhub-deploy-docker

The script builds a notebook image with recent versions of IfcOpenShell and pythonOCC to interactively visualize, analyse and manipulate IFC building models. The environment comes preloaded with examples scripts and models. The steps below for Ubuntu are indicative to setup the server.

~~~bash
# Prerequisites: make, docker, certbot
sudo apt-get update
sudo apt install -y make

curl -fsSL get.docker.com -o get-docker.sh
sudo sh get-docker.sh

curl -L https://github.com/docker/machine/releases/download/v0.13.0/docker-machine-`uname -s`-`uname -m` -o /tmp/docker-machine
chmod +x /tmp/docker-machine
sudo cp /tmp/docker-machine /usr/local/bin/docker-machine

curl -L https://github.com/docker/compose/releases/download/1.18.0/docker-compose-`uname -s`-`uname -m` -o /tmp/docker-compose
chmod +x /tmp/docker-compose
sudo cp /tmp/docker-compose /usr/local/bin/docker-compose

sudo apt-get install software-properties-common
sudo add-apt-repository -y ppa:certbot/certbot
sudo apt-get update
sudo apt-get install -y certbot

# Clone this repository
git clone --recursive https://github.com/IfcOpenShell/ifcopenshell-jupyterhub
cd ifcopenshell-jupyterhub/jupyterhub

# Create an empty userlist, every authenticated user can login
touch userlist

# Generate SSL certificate, for example (this simply copies, so disabled the certbot auto-update)
sudo certbot certonly --standalone --cert-name jupyterhub --agree-tos --no-eff-email --work-dir cert --logs-dir cert --config-dir cert
mkdir secrets
sudo cp cert/live/jupyterhub/fullchain.pem secrets/jupyterhub.crt
sudo cp cert/live/jupyterhub/privkey.pem secrets/jupyterhub.key

# Github app OAUTH settings:
# GITHUB_CLIENT_ID=
# GITHUB_CLIENT_SECRET=
# OAUTH_CALLBACK_URL=
vi secrets/oauth.env

# Build docker images
sudo make notebook_image
patch -p1 < ../env.patch
sudo make build

# Build ifcopenshell image
sudo docker build -t jupyterhub-image-ifcopenshell ..

# Start the server, only command necessary for subsequent runs
sudo docker-compose up -d
~~~
