:: This batch file creates a mne-environment

: This disables printing every command from the script
@echo off
:: This is necessary to allow setting variables inside if-blocks
:: https://superuser.com/questions/78496/variables-in-batch-file-not-being-set-when-inside-if
setlocal enabledelayedexpansion

:: Read version
for /f "tokens=1,2 delims==" %%a in (./version.txt) do (
    if %%a==version set version=%%b
)
echo Running mne-python installation script %version% for Windows...

:: Read paths from paths.inis
for /f "tokens=1,2 delims==" %%a in (./paths.ini) do (
    if %%a==conda_root set conda_root=%%b
    if %%a==script_root set script_root=%%b
)
echo Conda-Root: %conda_root%
echo Script-Root: %script_root%

:: Check if all paths exist
for %%a in (%conda_root%, %script_root%) do (
    if not exist %%a (
        echo Path %%a does not exist, exiting...
        Pause
        exit 1
    )
)

:: Activate Anaconda
call %conda_root%/Scripts/activate.bat %conda_root%

:: Use mamba or conda?
set /P _solver="Do you want to use mamba? (y/n): "
if %_solver%==y (
    set solver=mamba
) else (
    set solver=conda
)

:: Install mamba
if %solver%==mamba (
    echo Installing mamba...
    call conda install --yes --channel=conda-forge --name=base mamba
)

set /P _inst_type="Do you want to install a development environment? (y/n): "

if %_inst_type%==n (
    :: Get environment name
    set /P _env_name="Please enter environment-name: "

    :: Install simple mne-environment
    set /P _core="Do you want to install only core dependencies? (y/n): "

    if !_core!==y (
        echo Creating environment "!_env_name!" and installing mne-python with core dependencies...
        call %solver% create --yes --strict-channel-priority --channel=conda-forge --name=!_env_name! mne-base
    ) else (
        echo Creating environment "!_env_name!" and installing mne-python with all dependencies...
        call %solver% create --yes --override-channels --channel=conda-forge --name=!_env_name! mne
    )
    
    call conda activate !_env_name!

) else (
    :: Remove existing environment
    echo Creating development environment "mnedev"...
    echo Removing existing environment
    call conda env remove -n mnedev
    rmdir /s /q %conda_root%/envs/mnedev

    echo Installing development version of mne-python
    call curl --remote-name --ssl-no-revoke https://raw.githubusercontent.com/mne-tools/mne-python/main/environment.yml
    call %solver% env create -n mnedev -f environment.yml
    call conda activate mnedev

    :: Delete environment.yml
    call del "environment.yml"

    echo Installing mne-python development dependencies...
    :: Install dev-version of mne-python
    cd /d %script_root%/mne-python
    call python -m pip uninstall -y mne
    call pip install -e .
    call pip install -r requirements_doc.txt
    call pip install -r requirements_testing.txt
    call pip install -r requirements_testing_extra.txt
    call %solver% install -c conda-forge -y sphinx-autobuild doc8 graphviz
    call pre-commit install

    :: Install dev-version of mne-qt-browser
    echo Installing developement version of mne-qt-browser
    cd /d %script_root%/mne-qt-browser
    call python -m pip uninstall -y mne_qt_browser
    call pip install -e .[opengl,tests]

    :: Install dev-version of mne-pipeline-hd
    echo Installing
    cd /d %script_root%/mne-pipeline-hd
    call pip install -e .[tests]
)


:: Printing System-Info
call mne sys_info

Pause
exit 0