:: This batch file creates a mne-environment
@echo off
echo "Creating MNE-Dev-Environment"
:: Activate Anaconda
set root=C:/Users/martin/anaconda3
call %root%/Scripts/activate.bat %root%

:: Use mamba or conda?
set /P _solver="Do you want to use mamba? (y/n): "
if %_solver%==y (
    set solver=mamba
) else (
    set solver=conda
)

:: Install mamba
if %solver%==mamba (
    echo "Installing mamba"
    conda install --yes --channel=conda-forge --name=base mamba
)

:: Remove existing environment
echo "Removing existing environment"
call conda env remove --name mnedev_minimal
rmdir /s /q "C:/Users/martin/anaconda3/envs/mnedev_minimal"

echo "Creating environment"
call conda create --yes --name mnedev_minimal python
call conda activate mnedev_minimal

echo "Installing mne"
call pip install mne
call mne sys_info
echo "Installing Qt"
call pip install PyQt5
echo "Installing mne dependencies"
:: Activate mne-python development-version
cd /d "C:/Users/martin/PycharmProjects/mne-python"
call python -m pip uninstall -y mne
call pip install -e .
call pip install -r requirements_testing.txt
cd /d "C:/Users/martin/PycharmProjects/mne-qt-browser"
call python -m pip uninstall -y mne_qt_browser
call pip install -e .
call pip install -r requirements_testing.txt
cd /d "C:/Users/martin/PycharmProjects/mne-pipeline-hd"
call pip install -e .
call pip install -r requirements_dev.txt

Pause
exit
