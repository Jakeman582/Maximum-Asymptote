@echo off
setlocal EnableExtensions

set "SCRIPT_DIR=%~dp0"
set "PROJECT_DIR=%SCRIPT_DIR%"
set "INSTALL_DIR=%USERPROFILE%\.asy\MaximumMathematics"
set "CONFIG_DIR=%USERPROFILE%\.asy"
set "CONFIG_FILE=%CONFIG_DIR%\config.asy"

where asy >nul 2>nul
if errorlevel 1 (
    echo Error: Asymptote (asy) was not found on your PATH.
    echo Please install Asymptote and try again.
    exit /b 1
)

echo Installing Maximum Mathematics library to %INSTALL_DIR%...

if not exist "%INSTALL_DIR%\Utilities" mkdir "%INSTALL_DIR%\Utilities"
if not exist "%INSTALL_DIR%\Visualizations" mkdir "%INSTALL_DIR%\Visualizations"

copy /Y "%PROJECT_DIR%MaximumMathematics.asy" "%INSTALL_DIR%\" >nul
xcopy /E /I /Y "%PROJECT_DIR%Utilities\*" "%INSTALL_DIR%\Utilities\" >nul
xcopy /E /I /Y "%PROJECT_DIR%Visualizations\*" "%INSTALL_DIR%\Visualizations\" >nul

if not exist "%CONFIG_DIR%" mkdir "%CONFIG_DIR%"
findstr /C:"MaximumMathematics" "%CONFIG_FILE%" >nul 2>nul
if errorlevel 1 (
    echo.>> "%CONFIG_FILE%"
    echo // Add MaximumMathematics directory to Asymptote search path>> "%CONFIG_FILE%"
    echo dir += ":%INSTALL_DIR%";>> "%CONFIG_FILE%"
)

echo ✓ Library installed successfully to %INSTALL_DIR%
echo ✓ Search path added to %CONFIG_FILE%
echo ✓ No wrapper file needed - using config.asy search path
echo.
echo You can now use 'import MaximumMathematics;' from any Asymptote file.
echo.
echo To update after making changes, run this script again:
echo   install_library_windows.bat
