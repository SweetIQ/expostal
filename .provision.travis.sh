#! /bin/bash

sudo apt-get -y install curl libsnappy-dev autoconf automake libtool pkg-config

if [ ! -f $HOME/libpostal/bootstrap.sh ]; then
  mkdir -p $HOME/libpostal 
  mkdir -p $HOME/libpostal_data
  cd $HOME
  git clone https://github.com/openvenues/libpostal
  cd $HOME/libpostal
  git checkout v1.0.0
  ./bootstrap.sh
  ./configure --datadir=$HOME/libpostal_data --prefix=/usr
  make
fi

cd $HOME/libpostal
sudo make install