#!/bin/bash

sudo pip install -U git+https://github.com/ltrc/indic-wx-converter.git
sudo pip install -U git+https://github.com/ltrc/indic-tokenizer.git

git submodule foreach --recursive git submodule update --init
git submodule foreach --recursive git pull origin master

make -C ./lib/hin/morph/analyser
