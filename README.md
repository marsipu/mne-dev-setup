# MNE Installation Scripts Configuration

## Overview
These scripts provide a flexible way to set up MNE-Python development environments. The installation process is split into two phases:

1. **Environment Creation**: Creates conda environments with basic packages
2. **Package Installation**: Installs MNE and related packages in the activated environment

## Configuration

### paths.ini
Edit the `paths.ini` file to configure your installation:

```ini
# Required paths
conda_root=C:/Users/user/miniconda3

# Development package paths (optional)
# Only define paths for packages you want to install in development mode
# These should point to the root directory of each package (containing setup.py or pyproject.toml)

mne_python_path=C:/Users/user/Code/mne-python
mne_qt_browser_path=C:/Users/user/Code/mne-qt-browser
mne_nodes_path=C:/Users/user/Code/mne-nodes
# mne_connectivity_path=C:/Users/user/Code/mne-connectivity
# mne_features_path=C:/Users/user/Code/mne-features
```

### Package Path Configuration
- **Leave undefined**: If you don't want to install a particular package in development mode, simply don't define its path variable or comment it out with `#`
- **Invalid paths**: If a path is defined but doesn't exist, the script will show a warning and skip that package
- **Valid paths**: Only packages with valid paths will be installed in development mode with `pip install -e`

## Usage

### Windows
1. **Create environment**: Run `install_mne.bat` or `create_mne_env.bat`
2. **Activate environment**: `conda activate <environment-name>`
3. **Install packages**: 
   - Normal installation: `install_mne_normal_win.bat`
   - Development installation: `install_mne_dev_win.bat`

### Linux/macOS
1. **Create environment**: Run `./install_mne.sh`
2. **Activate environment**: `conda activate <environment-name>`
3. **Install packages**:
   - Normal installation: `./install_mne_normal_unix.sh`
   - Development installation: `./install_mne_dev_unix.sh`

## Development Package Details

### Supported Packages
- **mne-python**: Core MNE library with `[full-no-qt,test,doc]` extras
- **mne-qt-browser**: GUI browser with `[opengl,tests]` extras
- **mne-nodes**: Node-based processing with `[test,docs]` extras
- **mne-connectivity**: Connectivity analysis with `[test,docs]` extras
- **mne-features**: Feature extraction with `[test,docs]` extras

### Pre-commit Hooks
For packages that support it, pre-commit hooks are automatically installed to ensure code quality.

## Flexibility for Contributors

This setup allows anyone to:
1. Install only the packages they're working on
2. Skip packages they don't need
3. Use custom directory structures
4. Easily add new MNE ecosystem packages

Simply clone the repositories you want to work on and update the paths in `paths.ini` accordingly.

## Acknowledgement
This script was created and modified with help from GitHub Copilot in Agent Mode.
