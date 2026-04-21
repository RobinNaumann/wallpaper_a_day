@echo off
setlocal

set "BUILD_OUTPUT=build\windows\x64\runner\Release"
set "DIST_DIR=dist\windows"
set "WIX_BUILD_DIR=build\wix"

if not exist "%BUILD_OUTPUT%\WallpaperADay.exe" (
  echo "Windows: WiX: expected build output not found: %BUILD_OUTPUT%\WallpaperADay.exe"
  exit /b 1
)

where heat.exe >nul 2>nul
if errorlevel 1 (
  echo "Windows: WiX: missing heat.exe in PATH. Install WiX Toolset v3 and add it to PATH."
  exit /b 1
)

where candle.exe >nul 2>nul
if errorlevel 1 (
  echo "Windows: WiX: missing candle.exe in PATH. Install WiX Toolset v3 and add it to PATH."
  exit /b 1
)

where light.exe >nul 2>nul
if errorlevel 1 (
  echo "Windows: WiX: missing light.exe in PATH. Install WiX Toolset v3 and add it to PATH."
  exit /b 1
)

if exist "%WIX_BUILD_DIR%" rmdir /s /q "%WIX_BUILD_DIR%"
mkdir "%WIX_BUILD_DIR%"
if not exist "%DIST_DIR%" mkdir "%DIST_DIR%"

echo "Windows: WiX: harvesting build output..."
heat dir "%BUILD_OUTPUT%" ^
  -cg AppFiles ^
  -dr INSTALLFOLDER ^
  -srd ^
  -sreg ^
  -sfrag ^
  -gg ^
  -var var.BuildOutputDir ^
  -out "%WIX_BUILD_DIR%\app_files.wxs"
if errorlevel 1 exit /b 1

echo "Windows: WiX: compiling installer sources..."
candle -nologo ^
  -dBuildOutputDir="%CD%\%BUILD_OUTPUT%" ^
  -out "%WIX_BUILD_DIR%\\" ^
  scripts\windows_installer.wxs ^
  "%WIX_BUILD_DIR%\app_files.wxs"
if errorlevel 1 exit /b 1

echo "Windows: WiX: linking MSI..."
light -nologo ^
  -out "%DIST_DIR%\WallpaperADay.msi" ^
  "%WIX_BUILD_DIR%\windows_installer.wixobj" ^
  "%WIX_BUILD_DIR%\app_files.wixobj"
if errorlevel 1 exit /b 1

echo "Windows: WiX: installer created at %DIST_DIR%\WallpaperADay.msi"
