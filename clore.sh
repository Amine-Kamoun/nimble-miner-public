#!/bin/bash

# Update system and install Go

sudo apt update
sudo apt install tmux -y && sudo apt install build-essential -y && sudo apt install make -y
wget https://go.dev/dl/go1.22.1.linux-amd64.tar.gz
sudo rm -rf /usr/local/go && tar -C /usr/local -xzf go1.22.1.linux-amd64.tar.gz
export PATH=$PATH:/usr/local/go/bin

# Install python3 environment

sudo apt install python3-venv -y

# Clone into miner and compile

mkdir $HOME/nimble && cd $HOME/nimble
git clone https://github.com/nimble-technology/nimble-miner-public.git
cd nimble-miner-public

# Edit requirements.txt to run lower version of numpy

sudo rm requirements.txt

echo '
requests==2.31.0
torch==2.2.1
accelerate==0.27.0
transformers==4.38.1
datasets==2.17.1
numpy==1.24
gitpython==3.1.42' > requirements.txt

# Update git files and install miner

git pull
make install

# Change fsspec version

pip uninstall fsspec -y

pip install 'fsspec==2023.10.0'


# Prompt the user for the number of miners
read -p "Enter the number of miners (maximum 10): " num_miners

if [[ $num_miners -gt 10 ]]; then
    echo "Maximum number of miners allowed is 10. Setting the number of miners to 10."
    num_miners=10
fi

# Activate the miners
for ((i=1; i<=$num_miners; i++)); do
    read -p "Enter the address for miner $i: " addr
    tmux new-session -d -s Nimble$i "cd /root/nimble/nimble-miner-public/ && source ./nimenv_localminers/bin/activate && export CUDA_VISIBLE_DEVICES=$((i-1)) && make run addr=$addr"
    tmux detach -s Nimble$i
done
