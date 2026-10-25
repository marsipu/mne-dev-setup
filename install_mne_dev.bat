:: Installs development packages in an existing conda environment.
@echo off
setlocal enabledelayedexpansion

set "script_dir=%~dp0"
if not exist "%script_dir%paths.ini" (
    echo ERROR: paths.ini not found beside this script.
    pause
    exit /b 1
)

:: Read paths from paths.ini
set "conda_root="
for /f "usebackq eol=# tokens=1,* delims==" %%a in ("%script_dir%paths.ini") do (
    if "%%a"=="conda_root" set "conda_root=%%b"
    if "%%a"=="mne_python_path" set "mne_python_path=%%b"
    if "%%a"=="mne_qt_browser_path" set "mne_qt_browser_path=%%b"
    if "%%a"=="mne_bids_path" set "mne_bids_path=%%b"
    if "%%a"=="mne_bids_pipeline_path" set "mne_bids_pipeline_path=%%b"
    if "%%a"=="mne_connectivity_path" set "mne_connectivity_path=%%b"
    if "%%a"=="mne_features_path" set "mne_features_path=%%b"
    if "%%a"=="mne_nodes_path" set "mne_nodes_path=%%b"
)

echo Package paths loaded from paths.ini

set "target_env=%~1"
if defined target_env goto :activate_environment
if not defined CONDA_DEFAULT_ENV goto :choose_environment
if /i "%CONDA_DEFAULT_ENV%"=="base" goto :choose_environment
if not defined CONDA_PREFIX goto :choose_environment
goto :environment_ready

:choose_environment
set /p "target_env=Development environment name or full path [mnedev]: "
if not defined target_env set "target_env=mnedev"

:activate_environment
if not defined conda_root (
    echo ERROR: Set conda_root in paths.ini to activate a conda environment.
    pause
    exit /b 1
)
if not exist "%conda_root%\Scripts\activate.bat" (
    echo ERROR: Conda activation script not found at "%conda_root%\Scripts\activate.bat".
    pause
    exit /b 1
)
call "%conda_root%\Scripts\activate.bat" "%target_env%"
if errorlevel 1 (
    echo ERROR: Could not activate conda environment "%target_env%".
    pause
    exit /b 1
)

:environment_ready
if not defined CONDA_DEFAULT_ENV goto :invalid_environment
if /i "%CONDA_DEFAULT_ENV%"=="base" goto :invalid_environment
if not defined CONDA_PREFIX goto :invalid_environment
if not exist "%CONDA_PREFIX%\python.exe" goto :invalid_environment
set "env_python=%CONDA_PREFIX%\python.exe"
echo Running development MNE installation...
echo Current environment: %CONDA_DEFAULT_ENV%
echo Environment path: %CONDA_PREFIX%

:: Get Qt variant preference
set /P _qt_type="Which Qt variant do you want to use? (1: PySide6 / 2: PyQt6 / 3: PySide2 / 4: PyQt5): "
set qt_variant=PySide6
if "!_qt_type!"=="" (
    echo No Qt variant entered, proceeding with default PySide6...
) else if !_qt_type!==1 (
    set qt_variant=PySide6
) else if !_qt_type!==2 (
    set qt_variant=PyQt6
) else if !_qt_type!==3 (
    set qt_variant=PySide2
) else if !_qt_type!==4 (
    set qt_variant=PyQt5
) else (
    echo Invalid Qt variant entered, proceeding with default PySide6...
)
echo Selected Qt variant: !qt_variant!

:: Get Qt version preference
set /P _qt_version="Do you want to install a specific version of Qt? (<version-number>/n): "
set qt_version=
if "!_qt_version!"=="" (
    echo No Qt version entered, proceeding with latest version...
) else if "!_qt_version!"=="n" (
    echo No Qt version entered, proceeding with latest version...
) else (
    set qt_version===!_qt_version!
    echo Selected Qt version: !qt_version!
)

:: Installing Qt
echo Installing Qt variant !qt_variant!!qt_version!...
"%env_python%" -m pip install !qt_variant!!qt_version!

:: Install dev-version of mne-python
if not defined mne_python_path (
    echo Warning: mne_python_path not specified in paths.ini
    echo Skipping mne-python development installation...
) else if not exist "!mne_python_path!" (
    echo Warning: mne-python directory not found at !mne_python_path!
    echo Skipping mne-python development installation...
) else (
    echo Installing development version of mne-python...
    cd /d "!mne_python_path!"
    "%env_python%" -m pip install -e .[full-no-qt,test,doc]
    :: Initialize pre-commit
    "%env_python%" -m pip install pre-commit
    "%env_python%" -m pre_commit install
)

:: Install dev-version of mne-qt-browser
if not defined mne_qt_browser_path (
    echo Warning: mne_qt_browser_path not specified in paths.ini
    echo Skipping mne-qt-browser installation...
) else if not exist "!mne_qt_browser_path!" (
    echo Warning: mne-qt-browser directory not found at !mne_qt_browser_path!
    echo Skipping mne-qt-browser installation...
) else (
    echo Installing development version of mne-qt-browser...
    cd /d "!mne_qt_browser_path!"
    "%env_python%" -m pip uninstall -y mne_qt_browser
    "%env_python%" -m pip install -e .[opengl,tests]
)

:: Install dev-version of mne-bids
if not defined mne_bids_path (
    echo Warning: mne_bids_path not specified in paths.ini
    echo Skipping mne-bids installation...
) else if not exist "!mne_bids_path!" (
    echo Warning: mne-bids directory not found at !mne_bids_path!
    echo Skipping mne-bids installation...
) else (
    echo Installing development version of mne-bids...
    cd /d "!mne_bids_path!"
    "%env_python%" -m pip install -e .[full,test,doc]
)

:: Install dev-version of mne-bids-pipeline
if not defined mne_bids_pipeline_path (
    echo Warning: mne_bids_pipeline_path not specified in paths.ini
    echo Skipping mne-bids-pipeline installation...
) else if not exist "!mne_bids_pipeline_path!" (
    echo Warning: mne-bids-pipeline directory not found at !mne_bids_pipeline_path!
    echo Skipping mne-bids-pipeline installation...
) else (
    echo Installing development version of mne-bids-pipeline...
    cd /d "!mne_bids_pipeline_path!"
    "%env_python%" -m pip install -e .[full,test,doc]
)

:: Install dev-version of mne-connectivity
if not defined mne_connectivity_path (
    echo Warning: mne_connectivity_path not specified in paths.ini
    echo Skipping mne-connectivity installation...
) else if not exist "!mne_connectivity_path!" (
    echo Warning: mne-connectivity directory not found at !mne_connectivity_path!
    echo Skipping mne-connectivity installation...
) else (
    echo Installing development version of mne-connectivity...
    cd /d "!mne_connectivity_path!"
    "%env_python%" -m pip install -e .[test,doc]
)

:: Install dev-version of mne-features
if not defined mne_features_path (
    echo Warning: mne_features_path not specified in paths.ini
    echo Skipping mne-features installation...
) else if not exist "!mne_features_path!" (
    echo Warning: mne-features directory not found at !mne_features_path!
    echo Skipping mne-features installation...
) else (
    echo Installing development version of mne-features...
    cd /d "!mne_features_path!"
    "%env_python%" -m pip install -e .[test,doc]
)

:: Install dev-version of mne-nodes
if not defined mne_nodes_path (
    echo Warning: mne_nodes_path not specified in paths.ini
    echo Skipping mne-nodes installation...
) else if not exist "!mne_nodes_path!" (
    echo Warning: mne-nodes directory not found at !mne_nodes_path!
    echo Skipping mne-nodes installation...
) else (
    echo Installing development version of mne-nodes...
    cd /d "!mne_nodes_path!"
    "%env_python%" -m pip install -e .[test,docs,plugins]
    "%env_python%" -m pre_commit install
)

:: Install IPython
echo Installing IPython for enhanced interactive experience...
"%env_python%" -m pip install ipython

echo Development installation completed successfully!
echo.
echo Printing System-Info:
"%env_python%" -c "import mne; mne.sys_info()"

pause
exit /b 0

:invalid_environment
echo ERROR: A non-base conda environment with Python must be activated before installing.
pause
exit /b 1
