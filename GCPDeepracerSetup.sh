#!/bin/bash

#install virtual env
sudo apt-get  --yes install python3-venv
#go to your home folder and create a python virtual environment
cd ~
python3 -m venv sagemaker_venv
source ~/sagemaker_venv/bin/activate

#pull down the docker images needed
docker pull crr0004/sagemaker-rl-tensorflow:console 
docker pull crr0004/deepracer_robomaker:console

#pull the extra fun stuff for log analysis etc
git clone https://github.com/aws-samples/aws-deepracer-workshops.git

# pull the main repo
git clone --recurse-submodules https://github.com/crr0004/deepracer.git
cd deepracer
source rl_coach/env.sh

cd ~
#copy the files to where they need to be:
mkdir ~/.sagemaker
mkdir robo
mkdir robo/container
mv ~/deepracer/config.yaml ~/.sagemaker

#chuck this into your .profile and source it
echo "export LOCAL_ENV_VAR_JSON_PATH=$(readlink -f deepracer/rl_coach/env_vars.json)" >> ~/.profile
source ~/.profile

# nip into the deepracer directory and install sagemaker sdk
source ~/sagemaker_venv/bin/activate
cd deepracer

pip install --upgrade pip
pip install wheel 
pip install boto3
pip install -U sagemaker-python-sdk/ awscli pandas

#throw down some pip installs so your virtual env is chock full of goodness and correct some of the libraries that get wonky
#pip install awscli
#pip install pandas
#pip uninstall urllib3
#pip install -U sagemaker-python-sdk/
#pip install --upgrade "urllib3==1.22" awscli
#pip install 'PyYAML==3.13'


#now setup for docker GPU

# Add the package repositories
distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | sudo apt-key add -
curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list | sudo tee /etc/apt/sources.list.d/nvidia-docker.list

#then add docker2
sudo apt-get update
sudo apt-get  --yes  --only-upgrade install docker-ce nvidia-docker2
sudo systemctl restart docker
sudo apt-get update && sudo apt-get  --yes  install -y nvidia-container-toolkit
sudo systemctl restart docker

#check docker still works
docker run --gpus all nvidia/cuda:9.0-base nvidia-smi

#modify rl_deepracer_coach_robomaker.py instance_type to local_gpu
sed -i 's/local-gpu/local_gpu/g' ~/deepracer/rl_coach/rl_deepracer_coach_robomaker.py

#uncommment the line in env.sh that is #export LOCAL_EXTRA_DOCKER_COMPOSE_PATH=$(readlink -f ./docker_compose_extra.json)
sed -i 's/#export LOCAL_EXTRA_DOCKER_COMPOSE_PATH/export LOCAL_EXTRA_DOCKER_COMPOSE_PATH/g' ~/deepracer/rl_coach/env.sh

#pull down minio into the deepracer folder and launch it as a background process
wget https://dl.min.io/server/minio/release/linux-amd64/minio
chmod +x minio
source ~/deepracer/rl_coach/env.sh; ./minio server data &

#connect to minio
#create bucket
#upload the two files using keys to look like folder
cd rl_coach
wget https://raw.githubusercontent.com/fmacrae/AI-Learning/master/s3DeepracerBucketCreate.py
source ~/sagemaker_venv/bin/activate
python s3DeepracerBucketCreate.py



#useful script to control automatic shutdown of VM when not in use
wget https://raw.githubusercontent.com/fmacrae/AI-Learning/master/autoShutdown.sh

echo "have a look at autoShutdown.sh and add to your crontab if you want to script auto shutdown"

echo "#minio launch line"
echo "source ~/deepracer/rl_coach/env.sh; cd deepracer; ./minio server data &"

echo "#sagemaker lauch line"
echo "cd ~/deepracer/rl_coach;  source ./env.sh; source ~/sagemaker_venv/bin/activate; python rl_deepracer_coach_robomaker.py" 

echo "#simulation lauch line"
echo "source ~/deepracer/rl_coach/env.sh;"
echo "docker run --rm --name dr --env-file ./robomaker.env --network sagemaker-local -p 8081:5900 -it crr0004/deepracer_robomaker:console"
