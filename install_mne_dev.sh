#!/bin/bash
# This script runs inside an activated conda environment for development MNE installation

echo "Running development MNE installation inside activated environment..."
echo "Current environment: $CONDA_DEFAULT_ENV"
echo "Environment path: $CONDA_PREFIX"

# Check if we're in the base environment
if [[ "$CONDA_DEFAULT_ENV" == "base" ]]; then
    echo
    echo "ERROR: You are currently in the base environment!"
    echo "This script should be run in the MNE development environment you created."
    echo
    echo "Please activate your MNE development environment first:"
    echo "  conda activate <your-environment-name>"
    echo
    echo "Then run this script again."
    exit 1
fi

# Check if CONDA_DEFAULT_ENV is empty (not in any conda environment)
if [[ -z "$CONDA_DEFAULT_ENV" ]]; then
    echo
    echo "ERROR: No conda environment is currently activated!"
    echo "This script should be run in the MNE development environment you created."
    echo
    echo "Please activate your MNE development environment first:"
    echo "  conda activate <your-environment-name>"
    echo
    echo "Then run this script again."
    exit 1
fi

echo "Environment check passed. Proceeding with installation..."

# Read script root from paths.ini
source ./paths.ini
echo "Script-Root: $script_root"

# Get Qt variant preference
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

# Get Qt version preference
read -p "Do you want to install a specific version of Qt? (<version-number>/n): " _qt_version
qt_version=""
if [[ -z "$_qt_version" || "$_qt_version" == "n" ]]; then
    echo "No Qt version entered, proceeding with latest version..."
else
    qt_version==$_qt_version
fi

# Installing Qt
echo "Installing Qt variant ${qt_variant}${qt_version}..."
pip install ${qt_variant}${qt_version}

# Install dev-version of mne-python
echo "Installing development version of mne-python..."
if [[ ! -d "$script_root/mne-python" ]]; then
    echo "Error: mne-python directory not found at $script_root/mne-python"
    echo "Please check your script_root path in paths.ini"
    exit 1
fi
cd "$script_root/mne-python" || exit
pip install -e .[full-no-qt,test,doc]

# Initialize pre-commit
pip install pre-commit
pre-commit install

# Install dev-version of mne-qt-browser
echo "Installing development version of mne-qt-browser"
if [[ ! -d "$script_root/mne-qt-browser" ]]; then
    echo "Warning: mne-qt-browser directory not found at $script_root/mne-qt-browser"
    echo "Skipping mne-qt-browser installation..."
else
    cd "$script_root/mne-qt-browser" || exit
    pip uninstall -y mne_qt_browser
    pip install -e .[opengl,tests]
fi

# Install dev-version of mne-nodes
echo "Installing development version of mne-nodes"
if [[ ! -d "$script_root/mne-nodes" ]]; then
    echo "Warning: mne-nodes directory not found at $script_root/mne-nodes"
    echo "Skipping mne-nodes installation..."
else
    cd "$script_root/mne-nodes" || exit
    pip install -e .[test,docs]
    pre-commit install
fi

# Get cupy preference
read -p "Do you want to install CUDA processing with cupy? (y/n): " _install_cupy
if [[ "$_install_cupy" == "y" ]]; then
    echo "Installing cupy..."
    pip install cupy-cuda12x
fi

echo "Development installation completed successfully!"
echo
echo "Printing System-Info:"
python -c "import mne; mne.sys_info()"
