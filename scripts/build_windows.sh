# ==== CONFIG ====

app=$1;
output="null"; # set to 'stdout' (default 'null') for verbose output

# ==== SCRIPT ====

set -e # exit on error
fOUT="/dev/$output"

echo "Windows: 1/2: Flutter build..."
flutter build windows > $fOUT 2>&1

echo "Windows: 2/2: packaging Inno..."
iscc ./scripts/windows_installer.iss > $fOUT 2>&1