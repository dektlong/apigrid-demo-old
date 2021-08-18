#!/usr/bin/env bash

cd ~/Dropbox/Work/code/Dog-facts-API

python3 -m venv .env

source .env/bin/activate

pip install -r dekt.txt

python3 app.py