#!/bin/sh

# tf_config.ah
#
# This bash script fixes up a tensorflow image on an Azure VM.  
# This runs on an NV6 VM. This script is actually executed on the VM.
# 
# v0.1 Pelle Olsson  This includes all major areas that require change.
#

PASSWD=$1

# The nodebooks directory ships with the particular image used
# when the VM was created.
NOTEBOOK_DIR=notebooks
DATA_DIR=data

###########################################################################
# INSTALLATION AND CONFIGURATION OF JUPYTER NOTEBOOK COMPONENTS
###########################################################################

# Run empty command to set sudo password.
echo $PASSWD | sudo -S echo "" 
cd $HOME/$NOTEBOOK_DIR

# The following git command creates a directory 'courses' in $NOTEBOOK_DIR
# and copies.  This is where the tensorflow lesson are located (deeplearning1/nbs).
if [ ! -d ./courses ]; then
   git clone https://github.com/fastai/courses.git
fi

# Get training data (dogscats.zip).
cd $HOME/$NOTEBOOK_DIR/courses/deeplearning1/nbs/
mkdir -p $DATA_DIR
cd $DATA_DIR
if [ ! -e ./dogscats.zip ]; then
   #wget http://files.fast.ai/data/dogscats.zip
   wget https://pelleotensorflow.blob.core.windows.net/data/dogscats.zip
   unzip dogscats.zip
fi

# Force use of TensorFlow GPU backend.
cd $HOME
sudo -i conda install bcolz

# Fix Python import error in Jupyter notebook lesson1, which necessitates
# installing python-pip.
sudo apt install python-pip
pip2 install keras==1.2.2

# Recommendation is to upgrade pip to latest version.
sudo pip install --upgrade pip

# In addition to the previous configurations you need to open the 
# jupyter notebook, lesson1, and make the following changes:
#
# 1. Replace
#
#     batch_size=64 => batch_size=32
#
# 2. Add the following Python code snippet after the batch_size code snippet:
#
#     from keras import backend as K  
#     K.set_image_dim_ordering('th')
#
# to fix a runtime exception.

