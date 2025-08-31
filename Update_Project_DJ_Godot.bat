@echo off
setlocal EnableExtensions

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

REM ===== 3) fix git PATH issue =====
set "GIT_EXE=git"
where git >nul 2>&1 || (
  if exist "%ProgramFiles%\Git\bin\git.exe" set "GIT_EXE=%ProgramFiles%\Git\bin\git.exe"
  if exist "%ProgramFiles%\Git\cmd\git.exe" set "GIT_EXE=%ProgramFiles%\Git\cmd\git.exe"
)
"%GIT_EXE%" --version >nul 2>&1 || (
  echo Git is installed but not available in this session. Please open a new terminal and run again.
  exit /b 1
)

REM ===== 4) Git LFS init =====
"%GIT_EXE%" lfs install

REM ===== 5) repo clone & LFS Pull =====
"%GIT_EXE%" clone --depth=1 https://github.com/Rliop913/Project_DJ_Godot.git
if errorlevel 1 (
  echo git clone failed.
  exit /b 1
)

pushd Project_DJ_Godot
"%GIT_EXE%" lfs pull

REM ===== 6) Prebuilts copy  =====
if not exist "..\addons\Prebuilts" mkdir "..\addons\Prebuilts"
robocopy "addons\Prebuilts" "..\addons\Prebuilts" /E >nul

REM ===== 7) version files copy =====
if exist PDJE_VERSION copy /Y "PDJE_VERSION" "..\"
if exist PDJE_WRAPPER_VERSION copy /Y "PDJE_WRAPPER_VERSION" "..\"

popd
echo installed! cleaning cloned repo now.
rmdir /S /Q Project_DJ_Godot

REM ===== 8) echo versions =====
set "PDJE_VERSION="
if exist "PDJE_VERSION" set /p PDJE_VERSION=<PDJE_VERSION

set "PDJE_WRAPPER_VERSION="
if exist "PDJE_WRAPPER_VERSION" set /p PDJE_WRAPPER_VERSION=<PDJE_WRAPPER_VERSION

echo PDJE Update Complete. PDJE_VERSION:%PDJE_VERSION%, PDJE_WRAPPER_VERSION:%PDJE_WRAPPER_VERSION%
endlocal
