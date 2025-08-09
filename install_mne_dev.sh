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

# Read paths from paths.ini
source ./paths.ini

echo "Package paths loaded from paths.ini"

# Get Qt variant preference
read -p "Which Qt variant do you want to use? (1: PySide6 / 2: PyQt6 / 3: PySide2 / 4: PyQt5): " _qt_type
qt_variant=PySide6  # Default to PySide6
if [[ -z "$_qt_type" ]]; then
    echo "No Qt variant entered, proceeding with default PySide6..."
elif [[ "$_qt_type" == "1" ]]; then
    qt_variant=PySide6
elif [[ "$_qt_type" == "2" ]]; then
    qt_variant=PyQt6
elif [[ "$_qt_type" == "3" ]]; then
    qt_variant=PySide2
elif [[ "$_qt_type" == "4" ]]; then
    qt_variant=PyQt5
else
    echo "Invalid Qt variant entered, proceeding with default PySide6..."
fi
echo "Selected Qt variant: $qt_variant"

# Get Qt version preference
read -p "Do you want to install a specific version of Qt? (<version-number>/n): " _qt_version
qt_version=""
if [[ -z "$_qt_version" || "$_qt_version" == "n" ]]; then
    echo "No Qt version entered, proceeding with latest version..."
else
    qt_version==$_qt_version
    echo "Selected Qt version: $qt_version"
fi

# Installing Qt
echo "Installing Qt variant ${qt_variant}${qt_version}..."
pip install ${qt_variant}${qt_version}

# Install dev-version of mne-python
if [[ -n "$mne_python_path" ]]; then
    echo "Installing development version of mne-python..."
    if [[ ! -d "$mne_python_path" ]]; then
        echo "Error: mne-python directory not found at $mne_python_path"
        echo "Please check your mne_python_path in paths.ini"
        exit 1
    fi
    cd "$mne_python_path" || exit
    pip install -e .[full-no-qt,test,doc]
    
    # Initialize pre-commit
    pip install pre-commit
    pre-commit install
else
    echo "Warning: mne_python_path not specified in paths.ini"
    echo "Skipping mne-python development installation..."
fi

# Install dev-version of mne-qt-browser
if [[ -n "$mne_qt_browser_path" ]]; then
    echo "Installing development version of mne-qt-browser..."
    if [[ ! -d "$mne_qt_browser_path" ]]; then
        echo "Warning: mne-qt-browser directory not found at $mne_qt_browser_path"
        echo "Skipping mne-qt-browser installation..."
    else
        cd "$mne_qt_browser_path" || exit
        pip uninstall -y mne_qt_browser
        pip install -e .[opengl,tests]
    fi
else
    echo "Warning: mne_qt_browser_path not specified in paths.ini"
    echo "Skipping mne-qt-browser installation..."
fi

# Install dev-version of mne-bids
if [[ -n "$mne_bids_path" ]]; then
    echo "Installing development version of mne-bids..."
    if [[ ! -d "$mne_bids_path" ]]; then
        echo "Warning: mne-bids directory not found at $mne_bids_path"
        echo "Skipping mne-bids installation..."
    else
        cd "$mne_bids_path" || exit
        pip install -e .[full,test,doc]
    fi
else
    echo "Warning: mne_bids_path not specified in paths.ini"
    echo "Skipping mne-bids installation..."
fi

# Install dev-version of mne-bids-pipeline
if [[ -n "$mne_bids_pipeline_path" ]]; then
    echo "Installing development version of mne-bids-pipeline..."
    if [[ ! -d "$mne_bids_pipeline_path" ]]; then
        echo "Warning: mne-bids-pipeline directory not found at $mne_bids_pipeline_path"
        echo "Skipping mne-bids-pipeline installation..."
    else
        cd "$mne_bids_pipeline_path" || exit
        pip install -e .[full,test,doc]
    fi
else
    echo "Warning: mne_bids_pipeline_path not specified in paths.ini"
    echo "Skipping mne-bids-pipeline installation..."
fi

# Install dev-version of mne-connectivity
if [[ -n "$mne_connectivity_path" ]]; then
    echo "Installing development version of mne-connectivity..."
    if [[ ! -d "$mne_connectivity_path" ]]; then
        echo "Warning: mne-connectivity directory not found at $mne_connectivity_path"
        echo "Skipping mne-connectivity installation..."
    else
        cd "$mne_connectivity_path" || exit
        pip install -e .[test,doc]
    fi
else
    echo "Warning: mne_connectivity_path not specified in paths.ini"
    echo "Skipping mne-connectivity installation..."
fi

# Install dev-version of mne-features
if [[ -n "$mne_features_path" ]]; then
    echo "Installing development version of mne-features..."
    if [[ ! -d "$mne_features_path" ]]; then
        echo "Warning: mne-features directory not found at $mne_features_path"
        echo "Skipping mne-features installation..."
    else
        cd "$mne_features_path" || exit
        pip install -e .[test,doc]
    fi
else
    echo "Warning: mne_features_path not specified in paths.ini"
    echo "Skipping mne-features installation..."
fi

# Install dev-version of mne-nodes
if [[ -n "$mne_nodes_path" ]]; then
    echo "Installing development version of mne-nodes..."
    if [[ ! -d "$mne_nodes_path" ]]; then
        echo "Warning: mne-nodes directory not found at $mne_nodes_path"
        echo "Skipping mne-nodes installation..."
    else
        cd "$mne_nodes_path" || exit
        pip install -e .[test,docs]
        pre-commit install
    fi
else
    echo "Warning: mne_nodes_path not specified in paths.ini"
    echo "Skipping mne-nodes installation..."
fi

echo "Development installation completed successfully!"
echo
echo "Printing System-Info:"
python -c "import mne; mne.sys_info()"
