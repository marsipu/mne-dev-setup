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

:: Read paths from paths.ini
for /f "tokens=1,2 delims==" %%a in (./paths.ini) do (
    if %%a==mne_python_path set mne_python_path=%%b
    if %%a==mne_qt_browser_path set mne_qt_browser_path=%%b
    if %%a==mne_bids_path set mne_bids_path=%%b
    if %%a==mne_bids_pipeline_path set mne_bids_pipeline_path=%%b
    if %%a==mne_connectivity_path set mne_connectivity_path=%%b
    if %%a==mne_features_path set mne_features_path=%%b
    if %%a==mne_nodes_path set mne_nodes_path=%%b
)

echo Package paths loaded from paths.ini

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
pip install !qt_variant!!qt_version!

:: Install dev-version of mne-python
if defined mne_python_path (
    echo Installing development version of mne-python...
    cd /d "!mne_python_path!"
    if not exist "!mne_python_path!" (
        echo Error: mne-python directory not found at !mne_python_path!
        echo Please check your mne_python_path in paths.ini
        pause
        exit /b 1
    )
    pip install -e .[full-no-qt,test,doc]
    :: Initialize pre-commit
    pip install pre-commit
    pre-commit install
) else (
    echo Warning: mne_python_path not specified in paths.ini
    echo Skipping mne-python development installation...
)

:: Install dev-version of mne-qt-browser
if defined mne_qt_browser_path (
    echo Installing development version of mne-qt-browser...
    cd /d "!mne_qt_browser_path!"
    if not exist "!mne_qt_browser_path!" (
        echo Warning: mne-qt-browser directory not found at !mne_qt_browser_path!
        echo Skipping mne-qt-browser installation...
    ) else (
        pip uninstall -y mne_qt_browser
        pip install -e .[opengl,tests]
    )
) else (
    echo Warning: mne_qt_browser_path not specified in paths.ini
    echo Skipping mne-qt-browser installation...
)

:: Install dev-version of mne-bids
if defined mne_bids_path (
    echo Installing development version of mne-bids...
    cd /d "!mne_bids_path!"
    if not exist "!mne_bids_path!" (
        echo Warning: mne-bids directory not found at !mne_bids_path!
        echo Skipping mne-bids installation...
    ) else (
        pip install -e .[full,test,doc]
    )
) else (
    echo Warning: mne_bids_path not specified in paths.ini
    echo Skipping mne-bids installation...
)

:: Install dev-version of mne-bids-pipeline
if defined mne_bids_pipeline_path (
    echo Installing development version of mne-bids-pipeline...
    cd /d "!mne_bids_pipeline_path!"
    if not exist "!mne_bids_pipeline_path!" (
        echo Warning: mne-bids-pipeline directory not found at !mne_bids_pipeline_path!
        echo Skipping mne-bids-pipeline installation...
    ) else (
        pip install -e .[full,test,doc]
    )
) else (
    echo Warning: mne_bids_pipeline_path not specified in paths.ini
    echo Skipping mne-bids-pipeline installation...
)

:: Install dev-version of mne-connectivity
if defined mne_connectivity_path (
    echo Installing development version of mne-connectivity...
    cd /d "!mne_connectivity_path!"
    if not exist "!mne_connectivity_path!" (
        echo Warning: mne-connectivity directory not found at !mne_connectivity_path!
        echo Skipping mne-connectivity installation...
    ) else (
        pip install -e .[test,doc]
    )
) else (
    echo Warning: mne_connectivity_path not specified in paths.ini
    echo Skipping mne-connectivity installation...
)

:: Install dev-version of mne-features
if defined mne_features_path (
    echo Installing development version of mne-features...
    cd /d "!mne_features_path!"
    if not exist "!mne_features_path!" (
        echo Warning: mne-features directory not found at !mne_features_path!
        echo Skipping mne-features installation...
    ) else (
        pip install -e .[test,doc]
    )
) else (
    echo Warning: mne_features_path not specified in paths.ini
    echo Skipping mne-features installation...
)

:: Install dev-version of mne-nodes
if defined mne_nodes_path (
    echo Installing development version of mne-nodes...
    cd /d "!mne_nodes_path!"
    if not exist "!mne_nodes_path!" (
        echo Warning: mne-nodes directory not found at !mne_nodes_path!
        echo Skipping mne-nodes installation...
    ) else (
        pip install -e .[test,docs]
        pre-commit install
    )
) else (
    echo Warning: mne_nodes_path not specified in paths.ini
    echo Skipping mne-nodes installation...
)

echo Development installation completed successfully!
echo.
echo Printing System-Info:
python -c "import mne; mne.sys_info()"

pause
