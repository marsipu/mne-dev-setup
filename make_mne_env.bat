:: This batch file creates a mne-environment
@echo off
echo "Creating MNE-Environment"
:: Activate Anaconda
set root=C:/Users/marti/anaconda3
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
    call conda install --yes --channel=conda-forge --name=base mamba
)

:: Get environment name
set /P _env_name= Please enter environment-name:

echo "Installing MNE"
call %solver% create --yes --override-channels --channel=conda-forge --name=%_env_name% mne
call conda activate mne
call mne sys_info

Pause
exit
