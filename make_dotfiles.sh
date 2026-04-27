#!/bin/bash

# ASCII art
base64 -d <<<"CiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg\
ICAgCiAgICAgICAsLCAgICAgICAgICAgICAgICAgICAgLC4uLiwsICAgICwsICAgICAgICAgICAgICAgICAgCiAgIC\
AgYDdNTSAgICAgICAgICAgbW0gICAgIC5kJyAiImRiICBgN01NICAgICAgICAgICAgICAgICAgCiAgICAgICBNTSAg\
ICAgICAgICAgTU0gICAgIGRNYCAgICAgICAgIE1NICAgICAgICAgICAgICAgICAgCiAgLE0iImJNTSAgLHBXIldxLm\
1tTU1tbSAgbU1NbW1gN01NICAgIE1NICAuZ1AiWWEgICxwUCJZYmQgCixBUCAgICBNTSA2VycgICBgV2IgTU0gICAg\
IE1NICAgIE1NICAgIE1NICxNJyAgIFliIDhJICAgYCIgCjhNSSAgICBNTSA4TSAgICAgTTggTU0gICAgIE1NICAgIE\
1NICAgIE1NIDhNIiIiIiIiIGBZTU1NYS4gCmBNYiAgICBNTSBZQS4gICAsQTkgTU0gICAgIE1NICAgIE1NICAgIE1N\
IFlNLiAgICAsIEwuICAgSTggCiBgV2JtZCJNTUwuYFlibWQ5JyAgYE1ibW8uSk1NTC4uSk1NTC4uSk1NTC5gTWJtbW\
QnIE05bW1tUCcgCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg\
ICAgCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgCg=="

# Enable dotglob to include hidden files
shopt -s dotglob

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Capture git identity before symlinking .gitconfig
source "$SCRIPT_DIR/vars.sh"

# Initialize variables
source_file=""
path_provided=0
process_all=0
install_packages=0

# Display usage information
usage() {
    echo "Usage: $0 <path>"
    echo "       $0         # Run against all dotfiles in the dotfiles/ directory"
    echo "Options:"
    echo "  -h                      Display this help message."
    echo "  -i, --install-packages  Install packages before processing dotfiles."
    exit 1
}

# Function to symlink a single dotfile
make_dotfile() {
    local source_file="$1"
    local dotfile_name=$(basename "$source_file")
    local target_file="$HOME/$dotfile_name"
    # Symlinks require an absolute path as the source
    local abs_source
    abs_source="$(cd "$(dirname "$source_file")" && pwd)/$(basename "$source_file")"

    echo "---"

    if [[ -f "$source_file" ]]; then
        # Warn if replacing a real file (not already a symlink) — user may want to review it first
        if [[ -f "$target_file" && ! -L "$target_file" ]]; then
            echo -e "Warning: replacing real file $target_file — original is gone after this."
        fi
        # Create symlink (-f replaces any existing file or symlink)
        ln -sf "$abs_source" "$target_file"
        echo -e "Symlinked:\t\t$target_file -> $abs_source"
    else
        echo "Error: Source file '$source_file' not found."
    fi
}

# Check if no arguments are provided
if [[ $# -eq 0 ]]; then
    process_all=1
fi

# Parse command-line arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        -h|--help)
            usage
            ;;
        -i|--install-packages)
            install_packages=1
            shift
            ;;
        -*)
            echo "Unknown option: $1"
            usage
            ;;
        *)
            echo $1
            if [[ -n "$1" && ! "$1" =~ ^- ]]; then
                source_file="$1"
                path_provided=1
                make_dotfile $source_file
                shift
            fi
            ;;
    esac
done

# Process all dotfiles
if [[ $path_provided -eq 0 ]]; then
    if [[ $install_packages -eq 1 ]]; then
        echo "Installing packages..."
        "$SCRIPT_DIR/install_packages.sh"
    fi

    echo "Processing all dotfiles in the current directory..."

    # Iterate over all files in the dotfiles directory
    for file in "$SCRIPT_DIR/dotfiles/"*; do
        if [[ -f "$file" ]]; then
            source_file="$file"
            make_dotfile "$source_file"
        fi
    done
fi

# Run postmake.sh
"$SCRIPT_DIR/postmake.sh"
