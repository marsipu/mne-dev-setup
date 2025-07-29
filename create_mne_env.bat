:: This batch file creates a mne-environment
:: You need to specify the path to your conda-root and the path to the script-root, where you store the folders 
:: of your development version of mne-python, mne-qt-browser, mne-pipeline-hd etc. in a paths.ini file, like this:
:: conda_root=C:\Users\user\Anaconda3
:: script_root=C:\Users\user\Documents\GitHub\mne-python

:: This disables printing every command from the script
@echo off
:: This is necessary to allow setting variables inside if-blocks
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
for %%a in (%conda_root% %script_root%) do (
    if not exist %%a (
        echo Path %%a does not exist, exiting...
        Pause
        exit 1
    )
)

:: Activate Anaconda
call %conda_root%/Scripts/activate.bat %conda_root%

:: Configure package solver
where mamba >nul 2>nul
if %errorlevel%==0 (
    set mamba_installed=true
) else (
    set mamba_installed=false
)

if %mamba_installed%==true (
    set /P use_mamba="Do you want to use mamba? (y/n): "
) else (
    set use_mamba=n
)

if %use_mamba%==y (
    set solver=mamba
    echo Using mamba as solver...
) else (
    set solver=conda
    echo Using conda as solver...
)

set /P _inst_type="Do you want to install a development environment? (y/n): "
set installation_type=dev
if "!_inst_type!"=="" (
    echo No installation type entered, proceeding with development environment...
) else if "!_inst_type!"=="y" (
    set installation_type=dev
) else if "!_inst_type!"=="n" (
    set installation_type=normal
) else (
    echo Invalid installation type entered, proceeding with development environment...
)

if %installation_type%==normal (
    :: Get environment name
    set /P _env_name="Please enter environment-name: "
    if "!_env_name!"=="" (
        echo No environment name entered, proceeding with default name mne...
        set _env_name=mne
    )

    :: Remove existing environment if it exists
    echo Removing existing environment !_env_name! if necessary...
    call !solver! env remove -n !_env_name! -y

    :: Create new environment with mne
    echo Creating environment "!_env_name!" with Python and basic packages...
    call !solver! create --yes --strict-channel-priority --channel=conda-forge --name=!_env_name! python pip

    echo.
    echo Environment "!_env_name!" has been created successfully!
    echo.
    echo To complete the installation, please activate the environment and run the installation script:
    echo.
    echo   conda activate !_env_name!
    echo   install_mne_normal_win.bat
    echo.

) else (
    :: Get python version
    set python_version=
    set /P _python_version="Do you want to install a specific version of Python? (<version>/n): "
    if !_python_version!==n (
        echo No Python version entered, proceeding with latest version...
    ) else if "!_python_version!"=="" (
        echo No Python version entered, proceeding with latest version...
    ) else (
        set python_version===!_python_version!
        echo Python version set to !python_version!.
    )

    :: Get Qt variant for environment name
    set /P _qt_type="Which Qt variant do you want to use? (1: PySide6 / 2: PyQt6 / 3: PySide2 / 4: PyQt5): "
    set qt_variant=pyside6
    if "!_qt_type!"=="" (
        echo No Qt variant entered, proceeding with default PySide6...
    ) else if !_qt_type!==1 (
        set qt_variant=pyside6
    ) else if !_qt_type!==2 (
        set qt_variant=pyqt6
    ) else if !_qt_type!==3 (
        set qt_variant=pyside2
    ) else if !_qt_type!==4 (
        set qt_variant=pyqt5
    ) else (
        echo Invalid Qt variant entered, proceeding with default PySide6...
    )

    :: Get Qt version for environment name
    set /P _qt_version="Do you want to install a specific version of Qt? (<version-number>/n): "
    set qt_version=
    if "!_qt_version!"=="" (
        echo No Qt version entered, proceeding with latest version...
    ) else if "!_qt_version!"=="n" (
        echo No Qt version entered, proceeding with latest version...
    ) else (
        set qt_version===!_qt_version!
    )

    :: Remove environment if possible
    set env_name=mnedev_!qt_variant!!qt_version!
    echo Removing existing environment !env_name! if necessary...
    call !solver! env remove -n !env_name! -y

    :: Create new environment
    echo Creating development environment !env_name!...
    call !solver! create -n !env_name! -y python!python_version! pip

    echo.
    echo Development environment "!env_name!" has been created successfully!
    echo.
    echo To complete the installation, please activate the environment and run the installation script:
    echo.
    echo   conda activate !env_name!
    echo   install_mne_dev_win.bat
    echo.
)

Pause