#!/bin/bash
# This script runs inside an activated conda environment for normal MNE installation

echo "Running normal MNE installation inside activated environment..."
echo "Current environment: $CONDA_DEFAULT_ENV"
echo "Environment path: $CONDA_PREFIX"

# Check if we're in the base environment
if [[ "$CONDA_DEFAULT_ENV" == "base" ]]; then
    echo
    echo "ERROR: You are currently in the base environment!"
    echo "This script should be run in the MNE environment you created."
    echo
    echo "Please activate your MNE environment first:"
    echo "  conda activate <your-environment-name>"
    echo
    echo "Then run this script again."
    exit 1
fi

# Check if CONDA_DEFAULT_ENV is empty (not in any conda environment)
if [[ -z "$CONDA_DEFAULT_ENV" ]]; then
    echo
    echo "ERROR: No conda environment is currently activated!"
    echo "This script should be run in the MNE environment you created."
    echo
    echo "Please activate your MNE environment first:"
    echo "  conda activate <your-environment-name>"
    echo
    echo "Then run this script again."
    exit 1
fi

echo "Environment check passed. Proceeding with installation..."

# Get version preference
read -p "Do you want to install a specific version of mne-python? (<version>/n): " _mne_version

if [[ -z "$_mne_version" || "$_mne_version" == "n" ]]; then
    _mne_core=mne-base
    _mne_full=mne
    echo "No version entered, proceeding with latest version..."
else
    _mne_core=mne-base==$_mne_version
    _mne_full=mne==$_mne_version
fi

# Get core dependencies preference
read -p "Do you want to install only core dependencies? (y/n): " _core

if [[ "$_core" == "y" ]]; then
    echo "Installing mne-python with core dependencies..."
    pip install $_mne_core
else
    echo "Installing mne-python with all dependencies..."
    pip install $_mne_full
fi

# Get cupy preference
read -p "Do you want to install CUDA processing with cupy? (y/n): " _install_cupy
if [[ "$_install_cupy" == "y" ]]; then
    echo "Installing cupy..."
    pip install cupy-cuda12x
fi

echo "Installation completed successfully!"
echo
echo "Printing System-Info:"
python -c "import mne; mne.sys_info()"
