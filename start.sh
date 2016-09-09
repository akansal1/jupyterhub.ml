#!/bin/bash
source activate py2
ipython kernel install
conda install --yes -c conda-forge tensorflow

source activate py3
ipython kernel install
conda install --yes -c conda-forge tensorflow

# Starts on Port 8764
jupyterhub --config=jupyterhub_config.py
