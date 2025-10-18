#!/bin/bash
set -e

APP_NAME="JavaFX_Template"
DISPLAY_NAME="JavaFX_Template"  # The name shown in the menu.
MAIN_CLASS="org.proggersworld.javafx_template.App"
VENDOR="Proggersworld"
VERSION=$(mvn help:evaluate -Dexpression=project.version -q -DforceStdout)
DESCRIPTION="A JavaFX template."

OS="$(uname -s)"
case "$OS" in
    Linux*)  
        INSTALLER_TYPE="deb"  # Standard auf deb
        ICON="src/main/resources/icons/app.png"
        OS_NAME="linux"
        ;;
    Darwin*) 
        INSTALLER_TYPE="pkg"
        ICON="src/main/resources/icons/app.icns"
        OS_NAME="macos"
        ;;
    *) echo "Unsupported OS: $OS" ; exit 1 ;;
esac

# Optional build RPM (for Linux)
if [ "$1" = "rpm" ] && [ "$OS_NAME" = "linux" ]; then
    INSTALLER_TYPE="rpm"
fi

echo "Building installer for $OS_NAME ($INSTALLER_TYPE), version $VERSION..."

OUT_DIR="releases"
mkdir -p "$OUT_DIR"

# Start maven build.
mvn -q -DskipTests clean package

# Build the runtime only when not available.
if [ ! -d target/runtime ]; then
  echo "No cached runtime found → building new runtime..."
  jlink \
    --module-path "$JAVA_HOME/jmods" \
    --add-modules java.base,java.sql,javafx.controls \
    --strip-debug --no-header-files --no-man-pages \
    --output target/runtime
else
  echo "Reusing cached runtime from target/runtime"
fi

# Find the Shaded-JAR in lowercase (Importanat for Windows/Linux).
MAIN_JAR=$(ls target | grep -i "shaded.jar" | head -n 1)
if [ -z "$MAIN_JAR" ]; then
    echo "Error: Shaded JAR not found in target/"
    exit 1
fi
MAIN_JAR_LOWER=$(echo "$MAIN_JAR" | tr '[:upper:]' '[:lower:]')

# Build the JPackage optionens.
JPACKAGE_OPTS=(
  --name "$APP_NAME"
  --app-version "$VERSION"
  --input target
  --main-jar "$MAIN_JAR_LOWER"
  --main-class "$MAIN_CLASS"
  --type "$INSTALLER_TYPE"
  --runtime-image target/runtime
  --icon "$ICON"
  --dest "$OUT_DIR"
)

# Linux: Shortcut, Menugroup, Vendor, Description
if [ "$OS_NAME" = "linux" ]; then
  # Desktop Shortcut
  JPACKAGE_OPTS+=(--linux-shortcut)
  # Menugroup
  JPACKAGE_OPTS+=(--linux-menu-group "Utility")
  # Vendor
  JPACKAGE_OPTS+=(--vendor "$VENDOR")
  # Description
  JPACKAGE_OPTS+=(--description "$DESCRIPTION")
fi

# Build installer.
jpackage "${JPACKAGE_OPTS[@]}"

# Rename the installer file.
ORIG_FILE=$(ls "$OUT_DIR" | grep "$APP_NAME")
NEW_FILE="${APP_NAME}-${VERSION}-${OS_NAME}.${INSTALLER_TYPE}"
mv "$OUT_DIR/$ORIG_FILE" "$OUT_DIR/$NEW_FILE"

# Linux: Setup the .desktop file (name + icon).
if [ "$OS_NAME" = "linux" ]; then
    DESKTOP_FILE=$(find "$OUT_DIR" -name "*.desktop" | head -n 1)
    if [ -f "$DESKTOP_FILE" ]; then
        sed -i "s/^Name=.*/Name=$DISPLAY_NAME/" "$DESKTOP_FILE"
        sed -i "s|^Icon=.*|Icon=$(realpath "$ICON")|" "$DESKTOP_FILE"
        chmod +x "$DESKTOP_FILE"  # take care the .desktop file is executable.
        echo "Updated .desktop file with name and icon: $DESKTOP_FILE"
    fi
fi

# Copy LICENSE.txt in the installation directory.
INSTALL_DIR="$OUT_DIR/${APP_NAME}-${VERSION}-${OS_NAME}"
mkdir -p "$INSTALL_DIR"
cp LICENSE.txt "$INSTALL_DIR/"
echo "LICENSE.txt copied to $INSTALL_DIR"

echo "Installer created: $OUT_DIR/$NEW_FILE"
