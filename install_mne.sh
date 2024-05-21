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

# :: Check if all paths exist
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
read -p "Do you want to use mamba? [y/n]: " _solver
if [ $_solver = y ]
then
    solver=mamba
else
    solver=conda
fi

read -p "Do you want to install a development environment? (y/n): " _inst_type

if [ $_inst_type == n ]; then
  # Get version
  read -p "Do you want to install a specific version of mne-python? (<version>/n): " _mne_version

  if [ $_mne_version == n ]; then
      _mne_core=mne-base
      _mne_full=mne
  else
      _mne_core=mne-base\=\=$_mne_version
      _mne_full=mne\=\=$_mne_version
  fi

  echo $_mne_core
  echo $_mne_full

  # Get environment name
  read -p "Please enter environment-name: " _env_name

  # Install simple mne-environment
  read -p "Do you want to install only core dependencies? (y/n): " _core

  if [[ $_core == y ]]; then
    echo Creating environment "$_env_name" and installing mne-python with core dependencies...
    $solver create --yes --strict-channel-priority --channel=conda-forge --name=$_env_name $_mne_core
  else
    echo Creating environment "$_env_name" and installing mne-python with all dependencies...
    $solver create --yes --override-channels --channel=conda-forge --name=$_env_name $_mne_full
  fi

  $solver activate $_env_name

else
  echo Creating development environment "mnedev"...
  # Remove existing environment
  echo Removing existing environment
  $solver env remove -n mnedev
  rm -rf "$conda_root/envs/mnedev"

  echo Installing development version of mne-python
  curl --remote-name --ssl-no-revoke https://raw.githubusercontent.com/mne-tools/mne-python/main/environment.yml
  $solver env create -n mnedev -f environment.yml
  $solver activate mnedev

  # Delete environment.yml
  rm "environment.yml"

  echo Installing mne-python development dependencies...
  # Install dev-version of mne-python
  cd "$script_root/mne-python" || exit
  python -m pip uninstall -y mne
  pip install -e .[test,test_extra,doc]
  $solver install -c conda-forge -y sphinx-autobuild doc8 graphviz
  pre-commit install

  # Install dev-version of mne-qt-browser
  echo Installing developement version of mne-qt-browser
  cd "$script_root/mne-qt-browser" || exit
  python -m pip uninstall -y mne_qt_browser
  pip install -e .[opengl,tests]

  # Install dev-version of mne-pipeline-hd
  echo Installing development version of mne-pipeline-hd
  cd "$script_root/mne-pipeline-hd" || exit
  pip install -e .[tests,docs]
fi

# Printing System-Info
mne sys_info

exit 0
