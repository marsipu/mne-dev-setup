#!/bin/bash
# This script creates a mne-environment
# It has to be run with 'bash -i create_mne_env.sh' to source .bashrc

# You need to specify the path to your conda-root in a paths.ini file, like this:
# conda_root=C:\Users\user\Anaconda3
# 
# For development installations, also specify paths to the packages you want to develop:
# mne_python_path=C:\Users\user\Code\mne-python
# mne_qt_browser_path=C:\Users\user\Code\mne-qt-browser

# Read version
source ./version.txt
echo Running mne-python installation script $version for MacOs/Linux...

# Read paths from paths.ini
source ./paths.ini
echo Conda-Root: $conda_root

# Check if conda path exists
if [ ! -d "$conda_root" ]
then
    echo "Path $conda_root does not exist, exiting..."
    exit 1
fi

# Configure package solver
if command -v mamba &> /dev/null
then
    read -p "Do you want to use mamba? [y/n]: " use_mamba
else
    echo "Mamba is not installed. Using conda."
    use_mamba=n
fi

if [ "$use_mamba" == "y" ]; then
    solver=mamba
    echo "Using mamba as solver..."
else
    solver=conda
    echo "Using conda as solver..."
fi


# Improved logic for environment type selection (mirroring .bat logic)
read -p "Do you want to install a development environment? (y/n): " _inst_type
installation_type=dev
if [[ -z "$_inst_type" ]]; then
    echo "No installation type entered, proceeding with development environment..."
elif [[ "$_inst_type" == "y" ]]; then
    installation_type=dev
elif [[ "$_inst_type" == "n" ]]; then
    installation_type=normal
else
    echo "Invalid installation type entered, proceeding with development environment..."
fi

if [[ "$installation_type" == "normal" ]]; then
    # Get environment name
    read -p "Please enter environment-name: " _env_name
    if [[ -z "$_env_name" ]]; then
        echo "No environment name entered, proceeding with default name mne..."
        _env_name=mne
    fi

    # Get MNE version preference
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

    # Get cupy preference
    read -p "Do you want to install CUDA processing with cupy? (y/n): " _install_cupy

    # Remove existing environment if it exists
    echo "Removing existing environment $_env_name if necessary..."
    $solver env remove -n $_env_name -y

    # Create new environment with MNE
    echo "Creating environment \"$_env_name\" with Python and MNE..."
    if [[ "$_core" == "y" ]]; then
        echo "Installing mne-python with core dependencies..."
        if [[ "$_install_cupy" == "y" ]]; then
            $solver create --yes --strict-channel-priority --channel=conda-forge --name=$_env_name python pip $_mne_core cupy
        else
            $solver create --yes --strict-channel-priority --channel=conda-forge --name=$_env_name python pip $_mne_core
        fi
    else
        echo "Installing mne-python with all dependencies..."
        if [[ "$_install_cupy" == "y" ]]; then
            $solver create --yes --strict-channel-priority --channel=conda-forge --name=$_env_name python pip $_mne_full cupy
        else
            $solver create --yes --strict-channel-priority --channel=conda-forge --name=$_env_name python pip $_mne_full
        fi
    fi

    echo
    echo "Environment \"$_env_name\" with MNE has been created successfully!"
    echo
    echo "To verify the installation, activate the environment and check system info:"
    echo
    echo "  conda activate $_env_name"
    echo "  python -c \"import mne; mne.sys_info()\""
    echo

else
    # Get environment name
    read -p "Please enter development environment name: " _env_name
    if [[ -z "$_env_name" ]]; then
        echo "No environment name entered, proceeding with default name mnedev..."
        _env_name=mnedev
    fi

    # Get Python version
    read -p "Do you want to install a specific version of Python? (<version>/n): " _python_version
    python_version=""
    if [[ -z "$_python_version" || "$_python_version" == "n" ]]; then
        echo "No Python version entered, proceeding with latest version..."
    else
        python_version="==$_python_version"
    fi
    
    env_name=$_env_name
    echo "Removing existing environment $env_name if necessary..."
    $solver env remove -n $env_name -y
    echo "Creating development environment $env_name..."
    $solver create -n $env_name -y python$python_version pip

    echo
    echo "Development environment \"$env_name\" has been created successfully!"
    echo
    echo "To complete the installation, please activate the environment and run the installation script:"
    echo
    echo "  conda activate $env_name"
    echo "  ./install_mne_dev.sh"
    echo
fi
