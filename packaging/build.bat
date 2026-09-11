@echo off
setlocal

set "STAGING_DIR=..\build\msix_stage"
set "PACKAGING_DIR=."
set "OUTPUT=..\build\ProofReader.msix"

echo Starting MSIX Build Process...
echo.

echo 1. Cleaning and preparing staging directory...
if exist "%STAGING_DIR%" rmdir /S /Q "%STAGING_DIR%"
mkdir "%STAGING_DIR%"

echo 2. Copying executable to staging directory...
copy /Y "..\build\ProofReader.exe" "%STAGING_DIR%\" >nul

echo 3. Copying manifest and assets to staging directory...
copy /Y "%PACKAGING_DIR%\AppxManifest.xml" "%STAGING_DIR%\" >nul
xcopy /E /I /Y "%PACKAGING_DIR%\assets" "%STAGING_DIR%\assets" >nul

echo 4. Generating PRI config file...
makepri createconfig /cf "%STAGING_DIR%\priconfig.xml" /dq en-US /o

echo 5. Compiling resources.pri...
makepri new /pr "%STAGING_DIR%" /cf "%STAGING_DIR%\priconfig.xml" /of "%STAGING_DIR%\resources.pri" /o
del "%STAGING_DIR%\priconfig.xml" 2>nul

echo 6. Packing MSIX...
makeappx pack /d "%STAGING_DIR%" /p "%OUTPUT%" /o

echo.
echo MSIX built successfully at %OUTPUT%
endlocal
