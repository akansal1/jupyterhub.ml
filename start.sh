#!/bin/bash
source activate py2
ipython kernel install

source activate py3
ipython kernel install

# Starts on Port 8764
jupyterhub --config=jupyterhub_config.py
