:: This batch file creates a mne-environment
:: You need to specify the path to your conda-root in a paths.ini file, like this:
:: conda_root=C:\Users\user\Anaconda3
:: 
:: For development installations, also specify paths to the packages you want to develop:
:: mne_python_path=C:\Users\user\Code\mne-python
:: mne_qt_browser_path=C:\Users\user\Code\mne-qt-browser

:: This disables printing every command from the script
@echo off
:: This is necessary to allow setting variables inside if-blocks
setlocal enabledelayedexpansion

:: Read version
for /f "tokens=1,2 delims==" %%a in (./version.txt) do (
    if %%a==version set version=%%b
)
echo Running mne-python installation script %version% for Windows...

:: Read paths from paths.ini
if not exist paths.ini (
    echo paths.ini not found. Please create paths.ini with the required paths. You can copy template-paths.ini for reference.
    Pause
    exit 1
)
for /f "tokens=1,2 delims==" %%a in (./paths.ini) do (
    if %%a==conda_root set conda_root=%%b
)
echo Conda-Root: %conda_root%

:: Check if conda path exists
if not exist %conda_root% (
    echo Path %conda_root% does not exist, exiting...
    Pause
    exit 1
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

    :: Get MNE version preference
    set /P _mne_version="Do you want to install a specific version of mne-python? (<version>/n): "
    if "!_mne_version!"=="n" (
        set _mne_core=mne-base
        set _mne_full=mne
    ) else if "!_mne_version!"=="" (
        echo No version entered, proceeding with latest version...
        set _mne_core=mne-base
        set _mne_full=mne
    ) else (
        set _mne_core=mne-base==!_mne_version!
        set _mne_full=mne==!_mne_version!
    )

    :: Get core dependencies preference
    set /P _core="Do you want to install only core dependencies? (y/n): "

    :: Remove existing environment if it exists
    echo Removing existing environment !_env_name! if necessary...
    call !solver! env remove -n !_env_name! -y

    :: Create new environment with MNE
    echo Creating environment "!_env_name!" with Python and MNE...
    if "!_core!"=="y" (
        echo Installing mne-python with core dependencies...
        call !solver! create --yes --strict-channel-priority --channel=conda-forge --name=!_env_name! python pip !_mne_core!
    ) else (
        echo Installing mne-python with all dependencies...
        call !solver! create --yes --strict-channel-priority --channel=conda-forge --name=!_env_name! python pip !_mne_full!
    )

    echo.
    echo Environment "!_env_name!" with MNE has been created successfully!
    echo.
    echo To verify the installation, activate the environment and check system info:
    echo.
    echo   conda activate !_env_name!
    echo   python -c "import mne; mne.sys_info()"
    echo.

) else (
    :: Get environment name
    set /P _env_name="Please enter development environment name: "
    if "!_env_name!"=="" (
        echo No environment name entered, proceeding with default name mnedev...
        set _env_name=mnedev
    )

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

    :: Remove environment if possible
    set env_name=!_env_name!
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