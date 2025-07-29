:: This script runs inside an activated conda environment for development MNE installation
@echo off
setlocal enabledelayedexpansion

echo Running development MNE installation inside activated environment...
echo Current environment: %CONDA_DEFAULT_ENV%
echo Environment path: %CONDA_PREFIX%

:: Check if we're in the base environment
if "%CONDA_DEFAULT_ENV%"=="base" (
    echo.
    echo ERROR: You are currently in the base environment!
    echo This script should be run in the MNE development environment you created.
    echo.
    echo Please activate your MNE development environment first:
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
    echo This script should be run in the MNE development environment you created.
    echo.
    echo Please activate your MNE development environment first:
    echo   conda activate ^<your-environment-name^>
    echo.
    echo Then run this script again.
    pause
    exit /b 1
)

echo Environment check passed. Proceeding with installation...

:: Read script root from paths.ini
for /f "tokens=1,2 delims==" %%a in (./paths.ini) do (
    if %%a==script_root set script_root=%%b
)
echo Script-Root: %script_root%

:: Get Qt variant preference
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

:: Get Qt version preference
set /P _qt_version="Do you want to install a specific version of Qt? (<version-number>/n): "
set qt_version=
if "!_qt_version!"=="" (
    echo No Qt version entered, proceeding with latest version...
) else if "!_qt_version!"=="n" (
    echo No Qt version entered, proceeding with latest version...
) else (
    set qt_version===!_qt_version!
)

:: Installing Qt
echo Installing Qt variant !qt_variant!!qt_version!...
pip install !qt_variant!!qt_version!

:: Install dev-version of mne-python
echo Installing development version of mne-python...
cd /d "%script_root%/mne-python"
if not exist "%script_root%/mne-python" (
    echo Error: mne-python directory not found at %script_root%/mne-python
    echo Please check your script_root path in paths.ini
    pause
    exit /b 1
)
pip install -e .[full-no-qt,test,doc]

:: Initialize pre-commit
pip install pre-commit
pre-commit install

:: Install dev-version of mne-qt-browser
echo Installing development version of mne-qt-browser
cd /d "%script_root%/mne-qt-browser"
if not exist "%script_root%/mne-qt-browser" (
    echo Warning: mne-qt-browser directory not found at %script_root%/mne-qt-browser
    echo Skipping mne-qt-browser installation...
) else (
    pip uninstall -y mne_qt_browser
    pip install -e .[opengl,tests]
)

:: Install dev-version of mne-nodes
echo Installing development version of mne-nodes
cd /d "%script_root%/mne-nodes"
if not exist "%script_root%/mne-nodes" (
    echo Warning: mne-nodes directory not found at %script_root%/mne-nodes
    echo Skipping mne-nodes installation...
) else (
    pip install -e .[test,docs]
    pre-commit install
)

:: Get cupy preference
set /P _install_cupy="Do you want to install CUDA processing with cupy? (y/n): "
if "!_install_cupy!"=="y" (
    echo Installing cupy...
    pip install cupy-cuda12x
)

echo Development installation completed successfully!
echo.
echo Printing System-Info:
python -c "import mne; mne.sys_info()"

pause
