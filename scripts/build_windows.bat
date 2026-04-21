@echo off


::delete dist folder

echo "Windows: cleaning previous build..."
rmdir /s /q dist\windows
rmdir /s /q build\
call flutter clean

echo "Windows: 1/3: apply plugins..."
call flutter pub get
call dart run flutter_launcher_icons
call dart run change_app_package_name:main in.robbb.wad
 
echo "Windows: 2/3: building application..."
call flutter build windows --release

echo "Windows: 3/3: building installer..."
call scripts\build_windows_installer.bat