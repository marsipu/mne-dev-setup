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

read -p "Do you want to install CUDA processing with cupy? (y/n): " _install_cupy
install_cupy=n
if [[ -z "$_install_cupy" || "$_install_cupy" == "n" ]]; then
    echo "Cupy will not be installed."
else
    echo "Cupy will be installed."
    install_cupy=y
fi

if [[ "$installation_type" == "normal" ]]; then
    # Get version
    read -p "Do you want to install a specific version of mne-python? (<version>/n): " _mne_version

    if [[ -z "$_mne_version" || "$_mne_version" == "n" ]]; then
        _mne_core=mne-base
        _mne_full=mne
    else
        _mne_core=mne-base\=\=$_mne_version
        _mne_full=mne\=\=$_mne_version
    fi

    # Get environment name
    read -p "Please enter environment-name: " _env_name
    if [[ -z "$_env_name" ]]; then
        echo "No environment name entered, proceeding with default name mne..."
        _env_name=mne
    fi

    # Install simple mne-environment
    read -p "Do you want to install only core dependencies? (y/n): " _core

    if [[ "$_core" == "y" ]]; then
        echo Creating environment "$_env_name" and installing mne-python with core dependencies...
        $solver create --yes --strict-channel-priority --channel=conda-forge --name=$_env_name $_mne_core
    else
        echo Creating environment "$_env_name" and installing mne-python with all dependencies...
        $solver create --yes --override-channels --channel=conda-forge --name=$_env_name $_mne_full
    fi

    source activate $_env_name

else
    # Get Python version
    read -p "Do you want to install a specific version of Python? (<version>/n): " _python_version
    python_version=""
    if [[ -z "$_python_version" || "$_python_version" == "n" ]]; then
        echo "No Python version entered, proceeding with latest version..."
    else
        python_version="==$_python_version"
    fi
    # Qt variant selection (mirroring .bat logic)
    read -p "Which Qt variant do you want to use? (1: PySide6 / 2: PyQt6): " _qt_type
    qt_variant=pyside6
    if [[ -z "$_qt_type" ]]; then
        echo "No Qt variant entered, proceeding with default PySide6..."
    elif [[ "$_qt_type" == "1" ]]; then
        qt_variant=pyside6
    elif [[ "$_qt_type" == "2" ]]; then
        qt_variant=pyqt6
    else
        echo "Invalid Qt variant entered, proceeding with default PySide6..."
    fi

    # Specify Qt version
    read -p "Do you want to install a specific version of Qt? (<version-number>/n): " _qt_version
    qt_version=""
    if [[ -z "$_qt_version" || "$_qt_version" == "n" ]]; then
        echo "No Qt version entered, proceeding with latest version..."
    else
        qt_version===$_qt_version
    fi

    env_name=mnedev_${qt_variant}${qt_version}
    echo Removing existing environment $env_name if necessary...
    $solver env remove -n $env_name -y
    echo Creating development environment $env_name...
    $solver create -n $env_name -y python$python_version
    source activate $env_name
    echo Installing Qt variant ${qt_variant}${qt_version}...
    pip install ${qt_variant}${qt_version}

    echo Installing development version of mne-python...
    cd "$script_root/mne-python" || exit
    pip install -e .[full-no-qt,test,doc]

    # Initialize pre-commit
    pip install pre-commit
    pre-commit install

    echo Installing development version of mne-qt-browser
    cd "$script_root/mne-qt-browser" || exit
    pip uninstall -y mne_qt_browser
    pip install -e .[opengl,tests]

    echo Installing development version of mne-nodes
    cd "$script_root/mne-nodes" || exit
    pip install -e .[test,docs]
    pre-commit install
fi

# Install cupy if requested
if [[ "$install_cupy" == "y" ]]; then
    echo Installing cupy...
    pip install cupy-cuda12x
fi

# Printing System-Info
mne sys_info
