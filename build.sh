# config:
label="Wallpaper a Day"
package="in.robbb.wad"

# script:
set -e # exit on error
clear

# build for the current platform
platform=$(uname -s)
if [ "$platform" = "Darwin" ]; then platform="macos"
elif [[ "$platform" == MINGW* || "$platform" == MSYS* || "$platform" == CYGWIN* ]]; then platform="windows"
else
  echo "Unknown platform: $platform"
  exit 1
fi

echo "Running Plugins"
flutter pub get
dart run flutter_launcher_icons
dart run change_app_package_name:main $package

echo "cleaning output..."
rm -rf ./dist
mkdir ./dist
echo "building app for the platforms"

# build for the current platform
./scripts/build_${platform}.sh "$label"

echo "Done! opening dist directory"
# open the dist directory
if [ "$platform" = "macos" ]; then open ./dist
elif [ "$platform" = "windows" ]; then start .\\dist
fi