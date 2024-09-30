#!/bin/bash

# Check if at least two arguments are provided (package name and glob pattern)
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <package_name> <glob_pattern>"
    exit 1
fi

PACKAGE_NAME=$1  # The name of the package (e.g., zsh, git)
GLOB_PATTERN=$2  # The glob pattern to match files (e.g., *.zshrc)

DOTFILES_DIR="$HOME/dotfiles"  # Updated location for dotfiles
PACKAGE_DIR="$DOTFILES_DIR/$PACKAGE_NAME"

# Create the package directory inside the dotfiles directory
mkdir -p "$PACKAGE_DIR"

# Function to desymlink files
copy_with_desymlink() {
    local SRC="$1"
    local DEST="$2"
    
    if [ -L "$SRC" ]; then
        # If it's a symlink, copy the real file it points to
        REAL_FILE=$(readlink -f "$SRC")
        cp -r "$REAL_FILE" "$DEST"
        echo "Desymlinked and copied $SRC (resolved to $REAL_FILE) to $DEST"
    elif [ -d "$SRC" ]; then
        # If it's a directory, create the destination directory and recurse into it
        mkdir -p "$DEST"
        for FILE in "$SRC"/*; do
            copy_with_desymlink "$FILE" "$DEST/$(basename "$FILE")"
        done
    elif [ -f "$SRC" ]; then
        # If it's a regular file, copy it
        cp -r "$SRC" "$DEST"
        echo "Copied $SRC to $DEST"
    fi
}

# Find and copy matched files to the package directory while preserving structure
echo "Copying files matching pattern '$GLOB_PATTERN' to $PACKAGE_DIR"
for FILE in $HOME/$GLOB_PATTERN; do
    if [ -e "$FILE" ]; then
        DEST_DIR=$(dirname "$FILE" | sed "s|$HOME|$PACKAGE_DIR|")
        mkdir -p "$DEST_DIR"
        copy_with_desymlink "$FILE" "$DEST_DIR/$(basename "$FILE")"
    else
        echo "No matching files found for $GLOB_PATTERN"
    fi
done
