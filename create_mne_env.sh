#!/bin/bash
# This batch file creates a mne-environment
# It has to be run with 'bash -i install_mne.sh' to source .bashrc

# You need to specify the path to your conda-root and the path to the script-root, where you store the folders 
# of your development version of mne-python, mne-qt-browser, mne-pipeline-hd etc. in a paths.ini file, like this:
# conda_root=C:\Users\user\Anaconda3
# script_root=C:\Users\user\Documents\GitHub\mne-python

# Read version
source ./version.txt
echo Running mne-python installation script $version for MacOs/Linux...

# Read paths from paths.ini
source ./paths.ini
echo Conda-Root: $conda_root
echo Script-Root: $script_root

# Check if all paths exist
paths=($conda_root $script_root)
for path in ${paths[@]};
do
    if [ ! -d $path ]
    then
        echo "Path $path does not exist"
        exit 1
    fi
done

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

    # Remove existing environment if it exists
    echo "Removing existing environment $_env_name if necessary..."
    $solver env remove -n $_env_name -y

    # Create new environment with basic packages
    echo "Creating environment \"$_env_name\" with Python and basic packages..."
    $solver create --yes --strict-channel-priority --channel=conda-forge --name=$_env_name python pip

    echo
    echo "Environment \"$_env_name\" has been created successfully!"
    echo
    echo "To complete the installation, please activate the environment and run the installation script:"
    echo
    echo "  conda activate $_env_name"
    echo "  ./install_mne_normal_unix.sh"
    echo

else
    # Get Python version
    read -p "Do you want to install a specific version of Python? (<version>/n): " _python_version
    python_version=""
    if [[ -z "$_python_version" || "$_python_version" == "n" ]]; then
        echo "No Python version entered, proceeding with latest version..."
    else
        python_version="==$_python_version"
    fi
    
    # Qt variant selection
    read -p "Which Qt variant do you want to use? (1: PySide6 / 2: PyQt6 / 3: PySide2 / 4: PyQt5): " _qt_type
    qt_variant=pyside6
    if [[ -z "$_qt_type" ]]; then
        echo "No Qt variant entered, proceeding with default PySide6..."
    elif [[ "$_qt_type" == "1" ]]; then
        qt_variant=pyside6
    elif [[ "$_qt_type" == "2" ]]; then
        qt_variant=pyqt6
    elif [[ "$_qt_type" == "3" ]]; then
        qt_variant=pyside2
    elif [[ "$_qt_type" == "4" ]]; then
        qt_variant=pyqt5
    else
        echo "Invalid Qt variant entered, proceeding with default PySide6..."
    fi

    # Specify Qt version
    read -p "Do you want to install a specific version of Qt? (<version-number>/n): " _qt_version
    qt_version=""
    if [[ -z "$_qt_version" || "$_qt_version" == "n" ]]; then
        echo "No Qt version entered, proceeding with latest version..."
    else
        qt_version==$_qt_version
    fi

    env_name=mnedev_${qt_variant}${qt_version}
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
    echo "  ./install_mne_dev_unix.sh"
    echo
fi
