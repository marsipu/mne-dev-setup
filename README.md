# MNE Development Setup

## Overview

These scripts provide a flexible way to set up MNE-Python development environments. The installation process is split into two phases:

1. **Environment Creation**: Creates conda environments with basic packages
2. **Package Installation**: Installs MNE and related packages in the activated environment

## Configuration

### paths.ini
Edit the `paths.ini` file to configure your installation:

```ini
# Required path
conda_root=C:/Users/user/miniconda3

# Development package paths (optional - only for development installations)
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
> **Note:** On a first time conda-installation, you need to create any environment with `conda create -n <env-name> once to accept terms and services.

### Windows

1. **Create environment**: Run `create_mne_env.bat`
2. **Install development packages**: Run or double-click `install_mne_dev.bat`. If no non-base environment is active, it prompts for an existing environment name or full path (default: `mnedev`) and activates it. Alternatively, run `install_mne_dev.bat <environment-name>`.

The creation script initializes conda using `conda_root` in `paths.ini` and prompts for the environment to create. No environment needs to be activated beforehand. For a normal installation, choose the normal-installation option in the creation script.

### Linux/macOS

These scripts initialize conda from `conda_root` in `paths.ini`; `bash -i` and a previously activated environment are not required:

1. **Create environment**: Run `bash create_mne_env.sh` and enter the environment to create.
2. **Install development packages**: Run `bash install_mne_dev.sh`. It reuses an active non-base environment or prompts for an existing environment name or full path (default: `mnedev`). Alternatively, run `bash install_mne_dev.sh <environment-name>`.

The installation scripts use the selected environment's Python for pip and pre-commit. Activation failures stop installation before any packages are changed. Both platforms read configuration beside the scripts, independent of the launch directory.

**Warning:** The creation scripts remove an existing environment with the chosen name before recreating it. To install or update packages in an existing environment, use the installation or update scripts instead.

### Updating development repositories

To update all repositories from `paths.ini` and renew their editable installations:
- Windows: Run `update_mne_dev.bat`. It reuses an active non-base conda environment; otherwise it prompts for an environment name or full path (default: `mnedev`) and activates it using `conda_root` from `paths.ini`. You can also select an environment explicitly with `update_mne_dev.bat my-environment`. Activation failures stop the update before any repositories are changed. Editable installations use that environment's Python.
- Linux/macOS: Run `bash update_mne_dev.sh`. Like the Windows updater, it reuses an active non-base environment or prompts for an environment name or full path (default: `mnedev`). It initializes conda from `conda_root/etc/profile.d/conda.sh`, so `bash -i` is not required for this script. You can also pass an environment explicitly: `bash update_mne_dev.sh my-environment`. Activation failures stop the update before any repositories are changed, and editable installations use the selected environment's Python.

**Launching by double-click:**
- Windows: Double-click `update_mne_dev.bat`. The console prompts for the environment when needed and stays open at the end.
- Linux: Mark `update_mne_dev.sh` as executable (`chmod +x update_mne_dev.sh`) and select **Run in Terminal** if your file manager supports it. Opening it in an editor will not run it.
- macOS: `.sh` files do not reliably launch in Terminal on double-click. Run `bash update_mne_dev.sh` from Terminal instead.

The same launch behavior applies to the creation and installation scripts: Windows batch files open a console and pause at the end; Linux shell scripts need **Run in Terminal**, and macOS shell scripts should be run from Terminal.

Shell scripts need terminal input for interactive prompts; they do not create a terminal window themselves. For the installation and update scripts, passing an environment as the first argument skips the environment-selection prompt (the installer still prompts for Qt preferences). Shell configuration values containing spaces must be quoted, for example `conda_root="/home/user/My Conda"`.

For each repository the script:
1. Fetches all remotes (`git fetch --all --prune`)
2. Merges the default branch of the `upstream` remote (or `origin` if there is no `upstream`) into the currently checked-out branch. Uncommitted changes are stashed and restored automatically (`--autostash`). If a merge conflict occurs, the merge is aborted and reported.
3. Reinstalls the package in editable mode (`pip install -e .[extras]`) with the same extras as the development installation

At the end, the script lists any repositories that had problems.

## Development Package Details

### Supported Packages
- **mne-python**: Core MNE library with `[full-no-qt,test,doc]` extras
- **mne-qt-browser**: GUI browser with `[opengl,tests]` extras
- **mne-connectivity**: Connectivity analysis with `[test,docs]` extras
- **mne-features**: Feature extraction with `[test,docs]` extras
- **mne-nodes**: Node-based processing with `[test,docs]` extras

### Pre-commit Hooks
For packages that support it, pre-commit hooks are automatically installed to ensure code quality.

## Acknowledgement
This script was created and modified with help from GitHub Copilot in Agent Mode.
