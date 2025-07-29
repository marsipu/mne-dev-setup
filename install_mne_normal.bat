:: This script runs inside an activated conda environment for normal MNE installation
@echo off
setlocal enabledelayedexpansion

echo Running normal MNE installation inside activated environment...
echo Current environment: %CONDA_DEFAULT_ENV%
echo Environment path: %CONDA_PREFIX%

:: Check if we're in the base environment
if "%CONDA_DEFAULT_ENV%"=="base" (
    echo.
    echo ERROR: You are currently in the base environment!
    echo This script should be run in the MNE environment you created.
    echo.
    echo Please activate your MNE environment first:
    echo   conda activate ^<your-environment-name^>
    echo.
    echo Then run this script again.
    pause
    exit /b 1
)

:: Check if CONDA_DEFAULT_ENV is empty (not in any conda environment)
if "%CONDA_DEFAULT_ENV%"=="" (
    echo.
    echo ERROR: No conda environment is currently activated!
    echo This script should be run in the MNE environment you created.
    echo.
    echo Please activate your MNE environment first:
    echo   conda activate ^<your-environment-name^>
    echo.
    echo Then run this script again.
    pause
    exit /b 1
)

echo Environment check passed. Proceeding with installation...

:: Get version preference
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

if "!_core!"=="y" (
    echo Installing mne-python with core dependencies...
    pip install !_mne_core!
) else (
    echo Installing mne-python with all dependencies...
    pip install !_mne_full!
)

:: Get cupy preference
set /P _install_cupy="Do you want to install CUDA processing with cupy? (y/n): "
if "!_install_cupy!"=="y" (
    echo Installing cupy...
    pip install cupy-cuda12x
)

echo Installation completed successfully!
echo.
echo Printing System-Info:
python -c "import mne; mne.sys_info()"

pause
