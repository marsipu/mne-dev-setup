:: This batch file creates a mne-environment
@echo off
echo "Creating MNE-Dev-Environment"
:: Activate Anaconda
set root=C:/Users/marti/anaconda3
call %root%/Scripts/activate.bat %root%

:: Use mamba or conda?
set solver=mamba

:: Install mamba
if %solver%==mamba (
    echo "Installing mamba"
    conda install --yes --channel=conda-forge --name=base mamba
)

:: Remove existing environment
echo "Removing existing environment"
call conda env remove -n mnedev
rmdir /s /q "C:/Users/marti/anaconda3/envs/mnedev"

echo "Installing mne"
call curl --remote-name https://raw.githubusercontent.com/mne-tools/mne-python/master/environment.yml
call %solver% env create -n mnedev -f environment.yml
call conda activate mnedev
call mne sys_info

call del "environment.yml"

echo "Installing mne dependencies"
:: Activate mne-python development-version
cd /d "C:/Users/marti/PycharmProjects/mne-python"
call python -m pip uninstall -y mne
call pip install -e .
call pip install -r requirements_doc.txt
call pip install -r requirements_testing.txt
call pip install -r requirements_testing_extra.txt
call %solver% install -y graphviz
call %solver% install -c conda-forge -y sphinx-autobuild doc8
cd /d "C:/Users/marti/PycharmProjects/mne-qt-browser"
call python -m pip uninstall -y mne_qt_browser
call pip install -e .
call pip install -r requirements_testing.txt
cd /d "C:/Users/marti/PycharmProjects/mne-pipeline-hd"
call pip install -e .
call pip install -r requirements_dev.txt

Pause
exit
