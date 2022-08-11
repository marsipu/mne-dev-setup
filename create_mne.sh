#!/bin/bash
# This batch file creates a mne-environment
# It has to be run with bash -i to source .bashrc
echo "Creating MNE-Environment"

# Use mamba or conda?
solver=mamba

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
