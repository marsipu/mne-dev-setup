#!/bin/bash
# Installs development packages in an existing conda environment.
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [[ ! -f "$script_dir/paths.ini" ]]; then
    echo "ERROR: paths.ini not found beside this script."
    exit 1
fi
if ! source "$script_dir/paths.ini"; then
    echo "ERROR: Could not load paths.ini."
    exit 1
fi
echo "Package paths loaded from paths.ini"

target_env="${1:-}"
if [[ -n "$target_env" || -z "$CONDA_DEFAULT_ENV" || "$CONDA_DEFAULT_ENV" == "base" || -z "$CONDA_PREFIX" ]]; then
    if [[ -z "$target_env" ]]; then
        if ! read -r -p "Development environment name or full path [mnedev]: " target_env; then
            echo "ERROR: Cannot read an environment name. Run in a terminal or pass it as the first argument."
            exit 1
        fi
        target_env="${target_env:-mnedev}"
    fi
    if [[ -z "$conda_root" || ! -f "$conda_root/etc/profile.d/conda.sh" ]]; then
        echo "ERROR: Set conda_root in paths.ini to a conda installation containing etc/profile.d/conda.sh."
        exit 1
    fi
    if ! source "$conda_root/etc/profile.d/conda.sh"; then
        echo "ERROR: Could not initialize conda."
        exit 1
    fi
    if ! conda activate "$target_env"; then
        echo "ERROR: Could not activate conda environment '$target_env'."
        exit 1
    fi
fi

if [[ -z "$CONDA_DEFAULT_ENV" || "$CONDA_DEFAULT_ENV" == "base" || -z "$CONDA_PREFIX" || ! -x "$CONDA_PREFIX/bin/python" ]]; then
    echo "ERROR: A non-base conda environment with Python must be activated before installing."
    exit 1
fi
env_python="$CONDA_PREFIX/bin/python"
echo "Running development MNE installation..."
echo "Current environment: $CONDA_DEFAULT_ENV"
echo "Environment path: $CONDA_PREFIX"

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
"$env_python" -m pip install "${qt_variant}${qt_version}"

# Install dev-version of mne-python
if [[ -z "$mne_python_path" ]]; then
    echo "Warning: mne_python_path not specified in paths.ini"
    echo "Skipping mne-python development installation..."
elif [[ ! -d "$mne_python_path" ]]; then
    echo "Warning: mne-python directory not found at $mne_python_path"
    echo "Skipping mne-python development installation..."
else
    echo "Installing development version of mne-python..."
    cd "$mne_python_path" || exit
    "$env_python" -m pip install -e ".[full-no-qt,test,doc]"
    # Initialize pre-commit
    "$env_python" -m pip install pre-commit
    "$env_python" -m pre_commit install
fi

# Install dev-version of mne-qt-browser
if [[ -z "$mne_qt_browser_path" ]]; then
    echo "Warning: mne_qt_browser_path not specified in paths.ini"
    echo "Skipping mne-qt-browser installation..."
elif [[ ! -d "$mne_qt_browser_path" ]]; then
    echo "Warning: mne-qt-browser directory not found at $mne_qt_browser_path"
    echo "Skipping mne-qt-browser installation..."
else
    echo "Installing development version of mne-qt-browser..."
    cd "$mne_qt_browser_path" || exit
    "$env_python" -m pip uninstall -y mne_qt_browser
    "$env_python" -m pip install -e ".[opengl,tests]"
fi

# Install dev-version of mne-bids
if [[ -z "$mne_bids_path" ]]; then
    echo "Warning: mne_bids_path not specified in paths.ini"
    echo "Skipping mne-bids installation..."
elif [[ ! -d "$mne_bids_path" ]]; then
    echo "Warning: mne-bids directory not found at $mne_bids_path"
    echo "Skipping mne-bids installation..."
else
    echo "Installing development version of mne-bids..."
    cd "$mne_bids_path" || exit
    "$env_python" -m pip install -e ".[full,test,doc]"
fi

# Install dev-version of mne-bids-pipeline
if [[ -z "$mne_bids_pipeline_path" ]]; then
    echo "Warning: mne_bids_pipeline_path not specified in paths.ini"
    echo "Skipping mne-bids-pipeline installation..."
elif [[ ! -d "$mne_bids_pipeline_path" ]]; then
    echo "Warning: mne-bids-pipeline directory not found at $mne_bids_pipeline_path"
    echo "Skipping mne-bids-pipeline installation..."
else
    echo "Installing development version of mne-bids-pipeline..."
    cd "$mne_bids_pipeline_path" || exit
    "$env_python" -m pip install -e ".[full,test,doc]"
fi

# Install dev-version of mne-connectivity
if [[ -z "$mne_connectivity_path" ]]; then
    echo "Warning: mne_connectivity_path not specified in paths.ini"
    echo "Skipping mne-connectivity installation..."
elif [[ ! -d "$mne_connectivity_path" ]]; then
    echo "Warning: mne-connectivity directory not found at $mne_connectivity_path"
    echo "Skipping mne-connectivity installation..."
else
    echo "Installing development version of mne-connectivity..."
    cd "$mne_connectivity_path" || exit
    "$env_python" -m pip install -e ".[test,doc]"
fi

# Install dev-version of mne-features
if [[ -z "$mne_features_path" ]]; then
    echo "Warning: mne_features_path not specified in paths.ini"
    echo "Skipping mne-features installation..."
elif [[ ! -d "$mne_features_path" ]]; then
    echo "Warning: mne-features directory not found at $mne_features_path"
    echo "Skipping mne-features installation..."
else
    echo "Installing development version of mne-features..."
    cd "$mne_features_path" || exit
    "$env_python" -m pip install -e ".[test,doc]"
fi

# Install dev-version of mne-nodes
if [[ -z "$mne_nodes_path" ]]; then
    echo "Warning: mne_nodes_path not specified in paths.ini"
    echo "Skipping mne-nodes installation..."
elif [[ ! -d "$mne_nodes_path" ]]; then
    echo "Warning: mne-nodes directory not found at $mne_nodes_path"
    echo "Skipping mne-nodes installation..."
else
    echo "Installing development version of mne-nodes..."
    cd "$mne_nodes_path" || exit
    "$env_python" -m pip install -e ".[test,docs]"
    "$env_python" -m pre_commit install
fi

# Install IPython
echo "Installing IPython for enhanced interactive experience..."
"$env_python" -m pip install ipython

echo "Development installation completed successfully!"
echo
echo "Printing System-Info:"
"$env_python" -c "import mne; mne.sys_info()"
