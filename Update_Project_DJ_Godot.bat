@echo off
setlocal EnableExtensions EnableDelayedExpansion

REM ===== 1) Git install check =====
where git >nul 2>&1
if errorlevel 1 (
  echo Git is not installed. installing git...
  where winget >nul 2>&1 && (winget install -e --id Git.Git --source winget) ^
  || ( where choco >nul 2>&1 && (choco install git -y) ) ^
  || ( where scoop >nul 2>&1 && (scoop install git) ) ^
  || ( echo No supported package manager found. Please install Git for Windows manually. & exit /b 1 )
)

REM ===== 2) Git LFS install check =====
where git-lfs >nul 2>&1
if errorlevel 1 (
  echo Git LFS is not installed. installing git-lfs...
  where winget >nul 2>&1 && (winget install -e --id GitHub.GitLFS --source winget) ^
  || ( where choco >nul 2>&1 && (choco install git-lfs -y) ) ^
  || ( where scoop >nul 2>&1 && (scoop install git-lfs) ) ^
  || ( echo No supported package manager found. Please install Git LFS manually. & exit /b 1 )
)

REM ===== 3) 7zip install check =====
set "SEVENZIP="

REM find path
where 7z >nul 2>&1 && set "SEVENZIP=7z"


if not defined SEVENZIP for %%P in (
  "%ProgramFiles%\7-Zip\7z.exe"
  "%ProgramFiles(x86)%\7-Zip\7z.exe"
  "%LOCALAPPDATA%\Programs\7-Zip\7z.exe"
) do if exist "%%~fP" set "SEVENZIP=%%~fP"

REM install
if not defined SEVENZIP (
  echo 7-Zip not found. installing 7-Zip...
  set "PM="
  where winget >nul 2>&1 && set "PM=winget"
  if not defined PM where choco >nul 2>&1 && set "PM=choco"
  if not defined PM where scoop >nul 2>&1 && set "PM=scoop"
  if not defined PM (
    echo No supported package manager found. Please install 7-Zip manually.
    exit /b 1
  )

  if "%PM%"=="winget" winget install -e --id 7zip.7zip --accept-package-agreements --accept-source-agreements
  if "%PM%"=="choco"  choco install 7zip -y
  if "%PM%"=="scoop"  scoop install 7zip

  REM research
  where 7z >nul 2>&1 && set "SEVENZIP=7z"
  if not defined SEVENZIP for %%P in (
    "%ProgramFiles%\7-Zip\7z.exe"
    "%ProgramFiles(x86)%\7-Zip\7z.exe"
    "%LOCALAPPDATA%\Programs\7-Zip\7z.exe"
  ) do if exist "%%~fP" set "SEVENZIP=%%~fP"
)

if not defined SEVENZIP (
  echo 7-Zip still not found. Aborting.
  exit /b 1
)

REM ===== 4) fix git PATH issue =====
set "GIT_EXE=git"
where git >nul 2>&1 || (
  if exist "%ProgramFiles%\Git\bin\git.exe" set "GIT_EXE=%ProgramFiles%\Git\bin\git.exe"
  if exist "%ProgramFiles%\Git\cmd\git.exe" set "GIT_EXE=%ProgramFiles%\Git\cmd\git.exe"
)
"%GIT_EXE%" --version >nul 2>&1 || (
  echo Git is installed but not available in this session. Please open a new terminal and run again.
  exit /b 1
)

@REM REM ===== 5) 7z PATH fix =====
@REM set "SEVENZIP=7z"
@REM where %SEVENZIP% >nul 2>&1 || (
@REM   if exist "%ProgramFiles%\7-Zip\7z.exe" set "SEVENZIP=%ProgramFiles%\7-Zip\7z.exe"
@REM   if exist "%ProgramFiles(x86)%\7-Zip\7z.exe" set "SEVENZIP=%ProgramFiles(x86)%\7-Zip\7z.exe"
@REM   if exist "%LOCALAPPDATA%\Programs\7-Zip\7z.exe" set "SEVENZIP=%LOCALAPPDATA%\Programs\7-Zip\7z.exe"
@REM )
@REM "%SEVENZIP%" >nul 2>&1 || (
@REM   echo 7-Zip is installed but not available in this session. Please open a new terminal and run again.
@REM   exit /b 1
@REM )

REM ===== 6) Git LFS init =====
"%GIT_EXE%" lfs install

REM ===== 7) repo clone & LFS Pull =====
"%GIT_EXE%" clone --depth=1 https://github.com/Rliop913/Project_DJ_Godot.git
if errorlevel 1 (
  echo git clone failed.
  exit /b 1
)


pushd Project_DJ_Godot
"%GIT_EXE%" lfs pull

REM ===== 8) unzip LFS files =====
pushd addons
for /r %%F in (*.7z.001) do (
  echo Found: %%F

  REM move to directory
  pushd "%%~dpF"

  echo Extracting: %%~nF
  "%SEVENZIP%" e "%%~nxF" -aoa -o"." >nul

  if errorlevel 1 (
    echo Failed to extract: %%~nxF
  ) else (
    echo Extracted: %%~nxF
    REM remove .7z files:
    del /f /q "%%~nF.*"
    del /f /q "%%~nF.???"
  )

  popd
)
popd

REM ===== 9) Project_DJ_Godot copy  =====
if not exist "..\addons\Project_DJ_Godot" mkdir "..\addons\Project_DJ_Godot"
robocopy "addons\Project_DJ_Godot" "..\addons\Project_DJ_Godot" /MIR >nul

REM ===== 10) version files copy =====
if exist PDJE_VERSION copy /Y "PDJE_VERSION" "..\"
if exist PDJE_WRAPPER_VERSION copy /Y "PDJE_WRAPPER_VERSION" "..\"
if exist Message_From_Project_DJ_Godot_Dev.md copy /Y "Message_From_Project_DJ_Godot_Dev.md" "..\"
if exist Update_Project_DJ_Godot.bat copy /Y "Update_Project_DJ_Godot.bat" "..\"
if exist Update_Project_DJ_Godot.sh copy /Y "Update_Project_DJ_Godot.sh" "..\"



popd
echo installed! cleaning cloned repo now.
rmdir /S /Q Project_DJ_Godot

REM ===== 11) echo versions =====
set "PDJE_VERSION="
if exist "PDJE_VERSION" set /p PDJE_VERSION=<PDJE_VERSION

set "PDJE_WRAPPER_VERSION="
if exist "PDJE_WRAPPER_VERSION" set /p PDJE_WRAPPER_VERSION=<PDJE_WRAPPER_VERSION



echo PDJE Update Complete. PDJE_VERSION:%PDJE_VERSION%, PDJE_WRAPPER_VERSION:%PDJE_WRAPPER_VERSION%
endlocal
