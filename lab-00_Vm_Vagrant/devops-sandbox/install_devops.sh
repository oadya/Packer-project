#!/bin/bash
set -e
# ENABLE TOOLS
GIT=ON # supported value [ON, OFF]
ZSH=ON # supported value [ON, OFF]
PYTHON=ON # supported value [ON, OFF, X.X.X]
NODE=18 # supported value [ON, OFF, X]
JAVA=16 # supported value [ON, OFF, X]
VSCODE=ON # supported value [ON, OFF]
GO=1.17 # supported value [ON, OFF, X.X] 
AWSCLI=ON # supported value [ON, OFF]
BOTO3=ON # supported value [ON, OFF]
FIREFOX=ON # supported value [ON, OFF]
TERRAFORM=1.5.0 # supported value [ON, OFF, X.X.X]
TERRAGRUNT=0.48.0 # supported value [ON, OFF, vX.X.X]
DOCKER=19.03 # supported value [ON, OFF, X.X] 
KEYPAIR=ON # supported value [ON, OFF]
ANSIBLE=2.10.0 # supported value [ON, OFF, X.X.X]
PACKER=ON # supported value [ON, OFF]


apt-get update

# keyboard settings
apt-get install x11-xkb-utils
echo "setxkbmap fr" >> /home/vagrant/.bashrc
apt-get install -y x11-xkb-utils
chown vagrant:vagrant /home/vagrant/.bashrc
timedatectl set-timezone Europe/Paris
sed -i  "s/'de/'fr/g" /etc/xdg/autostart/input-source.desktop
sed -i  "s/'us/'fr/g" /etc/xdg/autostart/input-source.desktop

# install GIT
case $GIT in
  ON)
    apt-get install -y git
    ;;
  OFF)
    echo "skip GIT installation"	
    ;;
  *)
    echo "Only ON and OFF value supported"
    ;;
esac	

# Install ZSH
case $ZSH in
  ON)
    # Install zsh for bash
    apt-get -y install zsh git
    echo "vagrant" | chsh -s /bin/zsh vagrant
    su - vagrant  -c  'echo "Y" | sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"'
    su - vagrant  -c "git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting"
    sed -i 's/^plugins=/#&/' /home/vagrant/.zshrc
    echo "plugins=(git docker docker-compose helm kubectl kubectx minikube colored-man-pages aliases copyfile  copypath dotenv zsh-syntax-highlighting jsontools)" >> /home/vagrant/.zshrc
    sed -i "s/^ZSH_THEME=.*/ZSH_THEME='agnoster'/g"  /home/vagrant/.zshrc
    apt-get install -y fonts-powerline
    ;;
  OFF)
    echo "skip ZSH installation"	
    ;;
  *)
    echo "Only ON and OFF value supported"
    ;;
esac	

# install Python
case $PYTHON in
  ON)
    apt-get install python3 -y
    apt-get install python3-pip -y
    apt-get install -y idle3
    ;;
  OFF)
    echo "skip python installation"
    ;;
  *)
    echo "install $PYTHON version"
	  apt-get install -y libssl-dev openssl zlib1g-dev libffi-dev curl wget
    curl https://sh.rustup.rs -sSf | RUSTUP_INIT_SKIP_PATH_CHECK=yes sh -s -- -y
    ln -s /root/.cargo/bin/rustc /usr/bin/rustc && ln -s  /root/.cargo/bin/cargo /usr/bin/cargo
    wget https://www.python.org/ftp/python/${PYTHON}/Python-${PYTHON}.tgz
    tar xzvf Python-${PYTHON}.tgz
    cd Python-${PYTHON}
    ./configure
    make
    make install
    ;;
	
esac	

# install Node
case $NODE in
  ON)
    curl -fsSL https://raw.githubusercontent.com/tj/n/master/bin/n | bash -s latest
    ;;
  OFF)
    echo "skip node installation"	
    ;;
  *)
    curl -fsSL https://raw.githubusercontent.com/tj/n/master/bin/n | bash -s $NODE
    ;;
esac	

# install JAVA
case $JAVA in
  ON)
    apt-get install default-jdk -y
    ;;
  OFF)
    echo "skip java installation"
    ;;
  *)
    echo "install $JAVA version"
	  apt-get install openjdk-${JAVA}-jre -y
    ;;
	
esac	

# install vscode
case $VSCODE in
  ON)
    apt-get install snapd -y
    snap install --classic code
    ;;
  OFF)
    echo "skip vscode installation"	
    ;;
  *)
    echo "Only ON and OFF value supported"
    ;;
esac	

# install Go
case $GO in
  ON)
    apt-get install snapd -y
    snap install go --classic
    ;;
  OFF)
    echo "skip go installation"	
    ;;
  *)
    apt-get install snapd -y
    snap install go --channel=${GO}/stable --classic
    ;;
esac	

# install cloud tools
## AWS CLI
case $AWSCLI in
  ON)
    apt-get install -y unzip
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    unzip awscliv2.zip
    ./aws/install
    ;;
  OFF)
    echo "skip aws cli installation"
    ;;
  *)
    echo "Only ON and OFF value supported"
    ;;
esac

## Terraform
case $TERRAFORM in
  ON)
    git clone https://github.com/tfutils/tfenv.git /home/vagrant/.tfenv
    ln -s /home/vagrant/.tfenv/bin/tfenv  /usr/bin/tfenv 
    tfenv install latest
    tfenv use latest
    
    ;;
  OFF)
    echo "skip terraform installation"
    ;;
  *)
    git clone https://github.com/tfutils/tfenv.git /home/vagrant/.tfenv
    ln -s /home/vagrant/.tfenv/bin/*  /usr/bin
    tfenv install  $TERRAFORM
    tfenv use  $TERRAFORM
    
    ;;
esac

## Terragrunt
case $TERRAGRUNT in
  ON)
    git clone https://github.com/cunymatthieu/tgenv.git /home/vagrant/.tgenv
    ln -s /home/vagrant/.tgenv/bin/*  /usr/bin
    tgenv install latest
    tgenv use latest
  ;;
  OFF)
    echo "skip terragrunt installation"
  ;;
  *)
    git clone https://github.com/cunymatthieu/tgenv.git /home/vagrant/.tgenv
    ln -s /home/vagrant/.tgenv/bin/*  /usr/bin
    tgenv install $TERRAGRUNT
    tgenv use  $TERRAGRUNT
  ;;
esac


## install boto3
if [[ "$(python3 -V)" =~ "Python 3" ]]
then
  case $BOTO3 in
    ON)
      pip3 install boto3
    ;;
    OFF)
      echo "skip boto3 installation"
    ;;
    *)
      echo "Only ON and OFF value supported"
    ;;
  esac
else
  echo "boto3 need python3 to be installed"  
fi


# install firefox
case $FIREFOX in
  ON)
    apt-get install firefox -y
    ;;
  OFF)
    echo "skip firefox installation"
    ;;
  *)
    echo "Only ON and OFF value supported"
    ;;
esac


# Install docker
case $DOCKER in
  ON)
    echo "Only ON and OFF value supported"
    curl -fsSL get.docker.com -o get-docker.sh && sh get-docker.sh
    usermod -aG docker vagrant
    systemctl enable docker
    systemctl start docker
    ;;
  OFF)
    echo "skip docker installation"
    ;;
  *)
    echo "Only ON and OFF value supported"
    curl -fsSL get.docker.com -o get-docker.sh && sh get-docker.sh --version $DOCKER
    usermod -aG docker vagrant
    systemctl enable docker
    systemctl start docker
    ;;
esac

# create keypair for ssh connection and git+ssh
case $KEYPAIR in
  ON)
    su - vagrant  -c "ssh-keygen -q -t rsa -N '' -f ~/.ssh/id_rsa <<<y >/dev/null 2>&1"
    ;;
  OFF)
    echo "skip keypair creation"
    ;;
  *)
    echo "Only ON and OFF value supported"
    ;;
esac

# install ansible
if [[ "$(python3 -V)" =~ "Python 3" ]]
then
  case $BOTO3 in
    ON)
      pip3 install ansible
    ;;
    OFF)
      echo "skip ansible installation"
    ;;
    *)
      echo "install ansible version $ANSIBLE"
      pip3 install ansible==$ANSIBLE
    ;;
  esac
else
  echo "ansible need python3 to be installed"  
fi

# install packer
case $PACKER in
  ON)
    curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
	sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
	sudo apt-get update && sudo apt-get install packer
    ;;
  OFF)
    echo "skip packer creation"
    ;;
  *)
    echo "Only ON and OFF value supported"
    ;;
esac

echo "##############"
echo "## VM ready ##"
echo "##############"
echo "For this Stack, you will use $(ip -f inet addr show enp0s8 | sed -En -e 's/.*inet ([0-9.]+).*/\1/p') IP Address"
echo "The VM will restart, please wait until 2 minutes before connection the VM"
reboot