:: Updates all development repositories configured in paths.ini:
::   1. Fetches the newest version from the remotes
::   2. Merges the default branch of "upstream" (or "origin" if no upstream exists)
::      into the currently checked out branch
::   3. Renews the editable installation (pip install -e) in the activated environment
@echo off
setlocal enabledelayedexpansion

set "script_dir=%~dp0"

:: Read paths from paths.ini
if not exist "%script_dir%paths.ini" (
    echo ERROR: paths.ini not found beside this script.
    pause
    exit /b 1
)
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

:: Reuse an active development environment, or activate a requested one.
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
echo Updating development MNE repositories...
echo Current environment: %CONDA_DEFAULT_ENV%
echo Environment path: %CONDA_PREFIX%

where git >nul 2>&1
if errorlevel 1 (
    echo ERROR: git was not found on PATH.
    pause
    exit /b 1
)

set "failed="

call :update_repo "mne-python" "!mne_python_path!" "full-no-qt,test,doc"
call :update_repo "mne-qt-browser" "!mne_qt_browser_path!" "opengl,tests"
call :update_repo "mne-bids" "!mne_bids_path!" "full,test,doc"
call :update_repo "mne-bids-pipeline" "!mne_bids_pipeline_path!" "full,test,doc"
call :update_repo "mne-connectivity" "!mne_connectivity_path!" "test,doc"
call :update_repo "mne-features" "!mne_features_path!" "test,doc"
call :update_repo "mne-nodes" "!mne_nodes_path!" "test,docs,plugins"

echo.
if not defined failed (
    echo All repositories updated successfully!
) else (
    echo Update finished with problems in:
    for %%f in (!failed!) do echo   - %%~f
)
echo.
echo Printing System-Info:
"%env_python%" -c "import mne; mne.sys_info()"

pause
exit /b 0

:invalid_environment
echo ERROR: A non-base conda environment with Python must be activated before updating.
pause
exit /b 1


:: Usage: call :update_repo <name> <path> <extras>
:update_repo
set "repo_name=%~1"
set "repo_path=%~2"
set "repo_extras=%~3"

echo.
echo ==================================================
echo Updating %repo_name%
echo ==================================================

if "%repo_path%"=="" (
    echo Path for %repo_name% not specified in paths.ini, skipping...
    exit /b 0
)
if not exist "%repo_path%" (
    echo Warning: %repo_name% directory not found at %repo_path%, skipping...
    exit /b 0
)

cd /d "%repo_path%"
if errorlevel 1 (
    set failed=!failed! "%repo_name% (cd)"
    exit /b 0
)

git rev-parse --is-inside-work-tree >nul 2>&1
if errorlevel 1 (
    echo Warning: %repo_path% is not a git repository, skipping git update...
    goto :install
)

set "remote="
for /f "delims=" %%r in ('git remote') do (
    if "%%r"=="origin" if not defined remote set "remote=origin"
    if "%%r"=="upstream" set "remote=upstream"
)
if not defined remote (
    echo Warning: Neither 'upstream' nor 'origin' remote found, skipping git update...
    goto :install
)

echo Fetching all remotes...
git fetch --all --prune
if errorlevel 1 (
    echo Warning: Fetching failed for %repo_name%
    set failed=!failed! "%repo_name% (fetch)"
)

:: Determine default branch of the chosen remote
set "ref="
for /f "delims=" %%b in ('git symbolic-ref --quiet --short refs/remotes/%remote%/HEAD 2^>nul') do set "ref=%%b"
if not defined ref (
    git remote set-head %remote% --auto >nul 2>&1
    for /f "delims=" %%b in ('git symbolic-ref --quiet --short refs/remotes/%remote%/HEAD 2^>nul') do set "ref=%%b"
)
if not defined ref (
    git show-ref --verify --quiet refs/remotes/%remote%/main
    if not errorlevel 1 set "ref=%remote%/main"
)
if not defined ref (
    git show-ref --verify --quiet refs/remotes/%remote%/master
    if not errorlevel 1 set "ref=%remote%/master"
)
if not defined ref (
    echo Warning: Could not determine default branch of '%remote%', skipping merge...
    set failed=!failed! "%repo_name% (default branch)"
    goto :install
)

set "current="
for /f "delims=" %%c in ('git branch --show-current') do set "current=%%c"
if not defined current (
    echo Warning: Repository is in detached HEAD state, skipping merge...
    set failed=!failed! "%repo_name% (detached HEAD)"
    goto :install
)

echo Merging %ref% into %current%...
git merge --no-edit --autostash %ref%
if errorlevel 1 (
    echo Warning: Merge of %ref% into %current% failed, aborting merge...
    git merge --abort >nul 2>&1
    set failed=!failed! "%repo_name% (merge)"
)

:install
echo Renewing editable installation of %repo_name%...
"%env_python%" -m pip install -e ".[%repo_extras%]"
if errorlevel 1 (
    echo Warning: Editable installation of %repo_name% failed
    set failed=!failed! "%repo_name% (pip install)"
)
exit /b 0
