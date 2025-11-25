#!/bin/bash

EXE_PATH="$1"

if [ -z "$EXE_PATH" ]; then
    kdialog --error "No executable file specified"
    exit 1
fi

# Enable MangoHud
export MANGOHUD=1
export MANGOHUD_CONFIGFILE="$HOME/.config/MangoHud/MangoHud.conf"

# Find Proton installations
PROTON_PATHS=()
PROTON_NAMES=()

# Steam's default Proton locations
STEAM_ROOT="$HOME/.steam/steam"
STEAM_COMPAT="$STEAM_ROOT/steamapps/common"

# Check Steam's common folder for Proton versions
if [ -d "$STEAM_COMPAT" ]; then
    while IFS= read -r -d '' proton_dir; do
        proton_name=$(basename "$proton_dir")
        if [ -f "$proton_dir/proton" ]; then
            PROTON_PATHS+=("$proton_dir")
            PROTON_NAMES+=("$proton_name")
        fi
    done < <(find "$STEAM_COMPAT" -maxdepth 1 -type d -name "Proton*" -print0 2>/dev/null)
fi

# ProtonPlus / custom compatibility tools
COMPAT_TOOLS="$STEAM_ROOT/compatibilitytools.d"
if [ -d "$COMPAT_TOOLS" ]; then
    while IFS= read -r -d '' proton_dir; do
        proton_name=$(basename "$proton_dir")
        if [ -f "$proton_dir/proton" ]; then
            PROTON_PATHS+=("$proton_dir")
            PROTON_NAMES+=("$proton_name (Custom)")
        fi
    done < <(find "$COMPAT_TOOLS" -maxdepth 1 -type d -print0 2>/dev/null | grep -zv "^$COMPAT_TOOLS$")
fi

# Check if we found any Proton versions
if [ ${#PROTON_PATHS[@]} -eq 0 ]; then
    kdialog --error "No Proton installations found.\n\nChecked:\n- $STEAM_COMPAT\n- $COMPAT_TOOLS"
    exit 1
fi

# Build menu string for kdialog
MENU_STRING=""
for i in "${!PROTON_NAMES[@]}"; do
    MENU_STRING+="$i ${PROTON_NAMES[$i]} "
done

# Show selection dialog
SELECTION=$(kdialog --menu "Select Proton version to run $(basename "$EXE_PATH"):" $MENU_STRING)

if [ $? -ne 0 ]; then
    exit 0  # User cancelled
fi

# Get selected Proton path
SELECTED_PROTON="${PROTON_PATHS[$SELECTION]}"

# Set up Steam runtime environment
export STEAM_COMPAT_CLIENT_INSTALL_PATH="$STEAM_ROOT"
export STEAM_COMPAT_DATA_PATH="${XDG_DATA_HOME:-$HOME/.local/share}/proton-runner"

# Create prefix directory if it doesn't exist
mkdir -p "$STEAM_COMPAT_DATA_PATH"

# Create a temporary script to run in konsole
TEMP_SCRIPT=$(mktemp)
cat > "$TEMP_SCRIPT" << 'SCRIPT_END'
#!/bin/bash
EXE_PATH="$1"
SELECTED_PROTON="$2"
PROTON_NAME="$3"

export STEAM_COMPAT_CLIENT_INSTALL_PATH="$4"
export STEAM_COMPAT_DATA_PATH="$5"

cd "$(dirname "$EXE_PATH")"

echo "=========================================="
echo "Running: $(basename "$EXE_PATH")"
echo "Proton: $PROTON_NAME"
echo "=========================================="
echo ""

# Run the executable and capture exit code
"$SELECTED_PROTON/proton" run "$EXE_PATH"
EXIT_CODE=$?

echo ""
echo "=========================================="
if [ $EXIT_CODE -eq 0 ]; then
    echo "Program exited successfully (code: $EXIT_CODE)"
else
    echo "Program crashed or exited with error (code: $EXIT_CODE)"
fi
echo "=========================================="
echo ""
echo "Press Enter to close this window..."
read
SCRIPT_END

chmod +x "$TEMP_SCRIPT"

# Run in Konsole with the temporary script
konsole --hold -e "$TEMP_SCRIPT" "$EXE_PATH" "$SELECTED_PROTON" "${PROTON_NAMES[$SELECTION]}" "$STEAM_COMPAT_CLIENT_INSTALL_PATH" "$STEAM_COMPAT_DATA_PATH" &

# Clean up temp script after a delay (konsole will have copied it to memory)
(sleep 2 && rm -f "$TEMP_SCRIPT") &
