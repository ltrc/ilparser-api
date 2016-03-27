#!/bin/bash
set -e

git submodule update --recursive --init
git submodule foreach --recursive git pull origin master

sudo -E pip install -U ./lib/common/indic-wx-converter
sudo -E pip install -U ./lib/common/indic-tokenizer
sudo -E pip install -U ./lib/common/ilparser

make -C ./lib/hin/morph/analyser
