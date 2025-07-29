set conda_root=C:/Users/marti/miniconda3
call %conda_root%/Scripts/activate.bat %conda_root%

call conda env remove -n test --yes
echo %CONDA_PREFIX%

call conda create -n test -y python

:: Refresh conda to recognize the new environment
call conda info --envs

call conda activate test

echo %CONDA_PREFIX%

set expected_env=%conda_root:\=/%/envs/test
set actual_env=%CONDA_PREFIX:\=/%

echo expected_env: %expected_env%
echo actual_env: %actual_env%

if /I "%actual_env%"=="%expected_env%" (
    echo Environment successfully activated.
) else (
    echo Failed to activate environment.
)

Pause
exit /b