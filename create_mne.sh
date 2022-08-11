#!/bin/bash
# This batch file creates a mne-environment
echo "Creating MNE-Environment"

# Use mamba or conda?
solver=mamba

# Install mamba
if [ $solver = mamba]
then
    echo "Installing mamba"
    conda install --channel=conda-forge --name=base mamba
fi

# Get environment name
read -p "Please enter environment-name:" _env_name

# Install mne
echo "Installing MNE"
$solver create --yes --override-channels --channel=conda-forge --name=$_env_name mne
conda activate mne
mne sys_info
