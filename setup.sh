#!/bin/bash

git submodule foreach --recursive git submodule update --init
git submodule foreach --recursive git pull origin master

sudo pip install -U ./lib/common/indic-wx-converter
sudo pip install -U ./lib/common/indic-tokenizer
sudo pip install -U ./lib/common/ilparser

make -C ./lib/hin/morph/analyser
