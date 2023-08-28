#!/bin/bash
# This batch file creates a mne-environment
# It has to be run with bash -i to source .bashrc
echo "Creating MNE-Dev-Environment"
root="/Users/martinschulz"
conda_root="$root/anaconda3"
script_root="$root/PycharmProjects"

# Check for path existence
paths=($root $conda_root $script_root)
for path in ${paths[@]};
do
    if [ ! -d $path ]
    then
        echo "Path $path does not exist"
        exit 1
    fi
done

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

# Remove existing environment
echo "Removing existing environment"
conda env remove -n mnedev_minimal

echo "Creating environment"
$solver create --yes --name mnedev_minimal python
conda activate mnedev_minimal

echo "Installing IPython"
$solver install ipython

echo "Installing mne"
pip install mne
mne sys_info

echo "Installing Qt"
pip install PyQt5

# Install dev-version of mne-python
echo "Installing mne dependencies"
cd "$script_root/mne-python"
python -m pip uninstall -y mne
pip install -e . --config-settings editable_mode=strict
pip install -r requirements_testing.txt
pre-commit install

# Install dev-version of mne-qt-browser
cd "$script_root/mne-qt-browser"
python -m pip uninstall -y mne_qt_browser
call pip install -e .[opengl,tests] --config-settings editable_mode=strict

# Install dev-version of mne-pipeline-hd
cd "$script_root/mne-pipeline-hd"
call pip install -e .[tests] --config-settings editable_mode=strict
