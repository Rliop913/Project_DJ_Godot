@echo off
setlocal EnableExtensions EnableDelayedExpansion

REM ===== 1) Git install check =====
where git >nul 2>&1
if errorlevel 1 (
  echo Git is not installed. installing git...
  where winget >nul 2>&1 && (winget install -e --id Git.Git --source winget) ^
  || ( where choco >nul 2>&1 && (choco install git -y) ) ^
  || ( where scoop >nul 2>&1 && (scoop install git) ) ^
  || ( echo No supported package manager found. Please install Git for Windows manually. & goto :error_exit )
)

REM ===== 2) Git LFS install check =====
where git-lfs >nul 2>&1
if errorlevel 1 (
  echo Git LFS is not installed. installing git-lfs...
  where winget >nul 2>&1 && (winget install -e --id GitHub.GitLFS --source winget) ^
  || ( where choco >nul 2>&1 && (choco install git-lfs -y) ) ^
  || ( where scoop >nul 2>&1 && (scoop install git-lfs) ) ^
  || ( echo No supported package manager found. Please install Git LFS manually. & goto :error_exit )
)

REM ===== 3) 7zip install check =====
set "SEVENZIP="
call :find_7zip

REM install
if not defined SEVENZIP (
  echo 7-Zip not found. installing 7-Zip...
  call :install_7zip
  if errorlevel 1 (
    echo 7-Zip install failed. Please install 7-Zip manually.
    goto :error_exit
  )
  call :find_7zip
)

if not defined SEVENZIP (
  echo 7-Zip still not found. Aborting.
  goto :error_exit
)

REM ===== 4) fix git PATH issue =====
set "GIT_EXE=git"
where git >nul 2>&1 || (
  if exist "%ProgramFiles%\Git\bin\git.exe" set "GIT_EXE=%ProgramFiles%\Git\bin\git.exe"
  if exist "%ProgramFiles%\Git\cmd\git.exe" set "GIT_EXE=%ProgramFiles%\Git\cmd\git.exe"
)
"%GIT_EXE%" --version >nul 2>&1 || (
  echo Git is installed but not available in this session. Please open a new terminal and run again.
  goto :error_exit
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
@REM   goto :error_exit
@REM )

REM ===== 6) Git LFS init =====
"%GIT_EXE%" lfs install

REM ===== 7) repo clone & LFS Pull =====
"%GIT_EXE%" clone --depth=1 https://github.com/Rliop913/Project_DJ_Godot.git
if errorlevel 1 (
  echo git clone failed.
  goto :error_exit
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

REM ===== 10-1) agent docs copy =====
if exist "ProjectDJGodot_Agent_Docs\" (
  if not exist "..\ProjectDJGodot_Agent_Docs" mkdir "..\ProjectDJGodot_Agent_Docs"
  robocopy "ProjectDJGodot_Agent_Docs" "..\ProjectDJGodot_Agent_Docs" /MIR >nul
  if errorlevel 8 (
    echo ProjectDJGodot_Agent_Docs copy failed.
    goto :error_exit
  )
) else (
  echo ProjectDJGodot_Agent_Docs directory not found. skipping docs copy.
)



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

if exist Update_Project_DJ_Godot.bat copy /Y "Update_Project_DJ_Godot.bat" "..\"
if exist Update_Project_DJ_Godot.sh copy /Y "Update_Project_DJ_Godot.sh" "..\"

call :wait_before_exit
exit /b 0

:find_7zip
set "SEVENZIP="
where 7z >nul 2>&1 && set "SEVENZIP=7z"
if not defined SEVENZIP for %%P in (
  "%ProgramFiles%\7-Zip\7z.exe"
  "%ProgramFiles(x86)%\7-Zip\7z.exe"
  "%LOCALAPPDATA%\Programs\7-Zip\7z.exe"
) do if exist "%%~fP" set "SEVENZIP=%%~fP"
exit /b 0

:install_7zip
where winget >nul 2>&1
if not errorlevel 1 (
  winget install -e --id 7zip.7zip --accept-package-agreements --accept-source-agreements
  if not errorlevel 1 exit /b 0
)

where choco >nul 2>&1
if not errorlevel 1 (
  choco install 7zip -y
  if not errorlevel 1 exit /b 0
)

where scoop >nul 2>&1
if not errorlevel 1 (
  scoop install 7zip
  if not errorlevel 1 exit /b 0
)

exit /b 1

:error_exit
call :wait_before_exit
endlocal
exit /b 1

:wait_before_exit
echo.
pause
exit /b 0
