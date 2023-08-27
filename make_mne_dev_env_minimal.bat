:: This batch file creates a mne-environment
@echo off
echo "Creating MNE-Dev-Environment"
:: Activate Anaconda
set root=C:/Users/martin
set conda_root=%root%/anaconda3
set script_root=%root%/PycharmProjects
call %conda_root%/Scripts/activate.bat %conda_root%

:: Remove existing environment
echo "Removing existing environment"
call conda env remove --name mnedev_minimal
rmdir /s /q %conda_root%/envs/mnedev_minimal

echo "Creating environment"
call conda create --yes --name mnedev_minimal python
call conda activate mnedev_minimal

echo "Installing IPython"
call conda install ipython

echo "Installing mne"
call pip install mne
call mne sys_info

echo "Installing Qt"
call pip install PyQt5

echo "Installing mne dependencies"
:: Install dev-version of mne-python
cd /d %script_root%/mne-python
call python -m pip uninstall -y mne
call pip install -e . --config-settings editable_mode=strict
call pip install -r requirements_testing.txt
call pre-commit install

:: Install dev-version of mne-qt-browser
cd /d %script_root%/mne-qt-browser
call python -m pip uninstall -y mne_qt_browser
call pip install -e .[opengl,tests] --config-settings editable_mode=strict

:: Install dev-version of mne-pipeline-hd
cd /d %script_root%/mne-pipeline-hd
call pip install -e .[tests] --config-settings editable_mode=strict

Pause
exit
