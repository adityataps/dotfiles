# omitted shebang

# Display usage information
usage() {
    echo "Usage: $0 [-p <path>] <dotfile_name>"
    echo "       $0                                 # Run against all dotfiles in the dotfiles/ directory"
    echo "Options:"
    echo "  -p <path>     Specify the path to the source dotfile."
    echo "  -h            Display this help message."
    exit 1
}

# Enable dotglob to include hidden files
shopt -s dotglob

# Initialize variables
source_file=""
dotfile=""
path_provided=0
process_all=0

# Check if no arguments are provided
if [[ $# -eq 0 ]]; then
    process_all=1
fi

# Parse command-line arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        -p|--path)
            if [[ -n "$2" && ! "$2" =~ ^- ]]; then
                source_file="$2"
                path_provided=1
                shift 2
            else
                echo "Error: -p requires a non-empty option argument."
                usage
            fi
            ;;
        -h|--help)
            usage
            ;;
        -*)
            echo "Unknown option: $1"
            usage
            ;;
        *)
            if [[ -z "$dotfile" ]]; then
                dotfile="$1"
                shift
            else
                # TODO: Support multiple dotfiles
                echo "Error: Multiple dotfile names provided. Use the ./make_dotfiles.sh command with no arguments" 
                usage
            fi
            ;;
    esac
done

retain_n_backups() {
    local backup_dir=$1
    local backup_count=10   # Retain top n=10 backups

    # Find and remove the oldest backups, keeping only the most recent $backup_count
    backups=($(ls -t "$backup_dir"))  # List all backup files in dotenv backup dir sorted by time

    # If there are more than $backup_count backups, delete the oldest ones
    if (( ${#backups[@]} > $backup_count )); then
        NUM_TO_DELETE=$(( ${#backups[@]} - $backup_count ))
        for (( i=$backup_count; i<${#backups[@]}; i++ )); do
            rm "$backup_dir/${backups[$i]}"
            echo "Deleted old backup:\t$backup_dir${backups[$i]}"
        done
    fi
}

# Function to replace a single dotfile
make_dotfile() {
    local source_file="$1"
    local dotfile_name="$2"
    local target_file="$HOME/$dotfile_name"

    echo

    if [[ -f "$source_file" ]]; then
        # Backup the existing target file if it exists
        if [[ -f "$target_file" ]]; then
            local timestamp
            timestamp=$(date +%Y%m%d%H%M%S)
            backup_dir="$target_file"_backups/
            backup_file="$target_file"_backups/$timestamp
            mkdir -p $backup_dir
            cp "$target_file" "$backup_file"
            retain_n_backups $backup_dir
            echo "Backup created:\t\t$backup_file"
        fi
        # Replace the target file with the source file
        cp "$source_file" "$target_file"
        echo "Updated $target_file with '$source_file'."
    else
        echo "Error: Source file '$source_file' not found."
    fi
}

# Main logic

if [[ $process_all -eq 1 ]]; then
    echo "Processing all dotfiles in the current directory..."


    # Iterate over all files in the dotfiles directory
    for file in ./dotfiles/*; do
        if [[ -f "$file" ]]; then
            source_file="$file"
            dotfile_name=$(basename "$source_file")
            make_dotfile "$source_file" "$dotfile_name"
        fi
    done
else
    if [[ $path_provided -eq 1 ]]; then
        if [[ -z "$source_file" ]]; then
            echo "Error: Source file path not provided."
            usage
        fi
        # Extract the dotfile name from the provided path
        dotfile=$(basename "$source_file")
    else
        if [[ -z "$dotfile" ]]; then
            echo "Error: Dotfile name not provided."
            usage
        fi
        source_file="./$dotfi∏le"
    fi

    # Call the replace function for the specified dotfile
    make_dotfile "$source_file" "$dotfile"
fi

# Restart the current shell to use the updated commands
exec $SHELL
