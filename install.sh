#!/bin/bash
set -x

PROFILE=/etc/profile.d/k8s-dev.sh
GOTAR=go1.7.5.linux-amd64.tar.gz

sudo truncate -s 0 ${PROFILE}

wget https://storage.googleapis.com/golang/${GOTAR} 
sudo tar -C /usr/local -xzf ${GOTAR}
rm $GOTAR
sudo sh -c "echo 'export PATH=\$PATH:/usr/local/go/bin' >> ${PROFILE}"
. ${PROFILE}

sudo apt-get install git

mkdir -p ${HOME}/workspace
mkdir -p ${HOME}/workspace/bin
mkdir -p ${HOME}/workspace/src
sudo sh -c "echo 'export GOPATH=${HOME}/workspace' >> ${PROFILE}"
sudo sh -c "echo 'export PATH=\$PATH:\$GOPATH/bin' >> ${PROFILE}"
. ${PROFILE}

sudo apt-get update
sudo apt-get install apt-transport-https ca-certificates
sudo apt-key adv \
               --keyserver hkp://ha.pool.sks-keyservers.net:80 \
               --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
DOCKER_REPO="deb https://apt.dockerproject.org/repo ubuntu-xenial main"
echo ${DOCKER_REPO} | sudo tee /etc/apt/sources.list.d/docker.list
sudo apt-cache policy docker-engine
sudo apt-get update 
sudo apt-get install linux-image-extra-$(uname -r) linux-image-extra-virtual
sudo apt-get update
sudo apt-get install docker-engine=1.12.3-0~xenial
sudo groupadd docker
sudo usermod -aG docker $USER

sudo apt-get install vim
sudo apt-get install exuberant-ctags
git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
VIMRC="${HOME}/.vimrc"
cat > $VIMRC <<EOM
set nocompatible
syntax enable
set softtabstop=4
set number
set showcmd
set cursorline
set lazyredraw
set ignorecase
set showmatch
set incsearch
set hlsearch
filetype plugin indent on 
map <C-j> <C-W>j
map <C-k> <C-W>k
map <C-h> <C-W>h
map <C-l> <C-W>l
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
Plugin 'VundleVim/Vundle.vim'
Plugin 'fatih/vim-go'
Plugin 'Shougo/neocomplete.vim'
Plugin 'scrooloose/nerdtree'
Plugin 'majutsushi/tagbar'
call vundle#end()
nmap <C-\> :TagbarToggle<CR>
nmap <C-]> :NERDTreeToggle<CR>
EOM
vim +PluginInstall +qall
vim +GoInstallBinaries +qall

mkdir -p ${GOPATH}/src/k8s.io 
cd ${GOPATH}/src/k8s.io
git clone https://github.com/kubernetes/kubernetes.git

mkdir -p ${GOPATH}/src/github.com/tools
cd ${GOPATH}/src/github.com/tools
git clone https://github.com/tools/godep.git
cd ${GOPATH}/src/github.com/tools/godep
git pull
git checkout v79
go install
