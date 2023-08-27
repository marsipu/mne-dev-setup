:: This batch file creates a mne-environment
@echo off
echo "Creating MNE-Dev-Environment"
:: Activate Anaconda
set root=C:/Users/martin
set conda_root=%root%/anaconda3
set script_root=%root%/PycharmProjects
call %conda_root%/Scripts/activate.bat %root%

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
    call conda install --yes --channel=conda-forge --name=base mamba
)

:: Remove existing environment
echo "Removing existing environment"
call conda env remove -n mnedev
rmdir /s /q %conda_root%/envs/mnedev

echo "Installing mne"
call curl --remote-name --ssl-no-revoke https://raw.githubusercontent.com/mne-tools/mne-python/main/environment.yml
call %solver% env create -n mnedev -f environment.yml
call conda activate mnedev
call mne sys_info

call del "environment.yml"

echo "Installing mne dependencies"
:: Install dev-version of mne-python
cd /d %script_root%/mne-python
call python -m pip uninstall -y mne
call pip install -e . --config-settings editable_mode=strict
call pip install -r requirements_doc.txt
call pip install -r requirements_testing.txt
call pip install -r requirements_testing_extra.txt
call %solver% install -y graphviz
call %solver% install -c conda-forge -y sphinx-autobuild doc8
call pre-commit install
:: Install dev-version of mne-qt-browser
cd /d %script_root%/mne-qt-browser
call python -m pip uninstall -y mne_qt_browser
call pip install -e . --config-settings editable_mode=strict
call pip install -r requirements_testing.txt
:: Install dev-version of mne-pipeline-hd
cd /d %script_root%/mne-pipeline-hdeuro
call pip install -e . --config-settings editable_mode=strict
call pip install -r requirements_dev.txt

Pause
exit
