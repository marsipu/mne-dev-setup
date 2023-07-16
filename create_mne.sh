#!/bin/bash
# This batch file creates a mne-environment
# It has to be run with bash -i to source .bashrc
echo "Creating MNE-Environment"

# Use mamba or conda?
read -p "Do you want to use mamba? [y/n]:" _solver
if [ $_solver = y ]
then
    solver=mamba
else
    solver=conda
fi

# Install mamba
if [ $solver = mamba ]
then
    echo "Installing mamba"
    conda install --yes --channel=conda-forge --name=base mamba
fi

# Get environment name
read -p "Please enter environment-name:" _env_name

# Install mne
echo "Installing MNE"
$solver create --yes --override-channels --channel=conda-forge --name=$_env_name mne
conda activate mne
mne sys_info
