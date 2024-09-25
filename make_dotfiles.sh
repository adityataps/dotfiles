# omitted shebang

base64 -d <<<"CiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgCiAgICAgICAsLCAgICAgICAgICAgICAgICAgICAgLC4uLiwsICAgICwsICAgICAgICAgICAgICAgICAgCiAgICAgYDdNTSAgICAgICAgICAgbW0gICAgIC5kJyAiImRiICBgN01NICAgICAgICAgICAgICAgICAgCiAgICAgICBNTSAgICAgICAgICAgTU0gICAgIGRNYCAgICAgICAgIE1NICAgICAgICAgICAgICAgICAgCiAgLE0iImJNTSAgLHBXIldxLm1tTU1tbSAgbU1NbW1gN01NICAgIE1NICAuZ1AiWWEgICxwUCJZYmQgCixBUCAgICBNTSA2VycgICBgV2IgTU0gICAgIE1NICAgIE1NICAgIE1NICxNJyAgIFliIDhJICAgYCIgCjhNSSAgICBNTSA4TSAgICAgTTggTU0gICAgIE1NICAgIE1NICAgIE1NIDhNIiIiIiIiIGBZTU1NYS4gCmBNYiAgICBNTSBZQS4gICAsQTkgTU0gICAgIE1NICAgIE1NICAgIE1NIFlNLiAgICAsIEwuICAgSTggCiBgV2JtZCJNTUwuYFlibWQ5JyAgYE1ibW8uSk1NTC4uSk1NTC4uSk1NTC5gTWJtbWQnIE05bW1tUCcgCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgCg=="

# Display usage information
usage() {
    echo "Usage: $0 <path>"
    echo "       $0         # Run against all dotfiles in the dotfiles/ directory"
    echo "Options:"
    echo "  -h                      Display this help message."
    exit 1
}

# Enable dotglob to include hidden files
shopt -s dotglob

# Initialize variables
source_file=""
dotfile=""
path_provided=0
process_all=0

# To prevent backups from taking too much space, we can retain a specified number of backups
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
    local dotfile_name=$(basename "$source_file")
    local target_file="$HOME/$dotfile_name"

    echo "---"

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
                shift 1
            else
                # TODO: Support multiple dotfiles
                echo "Error: Multiple dotfile names provided. Use the ./make_dotfiles.sh command with no arguments" 
                usage
            fi
            ;;
    esac
done

# Process all dotfiles
if [[ $process_all -eq 1 ]]; then
    echo "Processing all dotfiles in the current directory..."

    # Iterate over all files in the dotfiles directory
    for file in ./dotfiles/*; do
        if [[ -f "$file" ]]; then
            source_file="$file"
            make_dotfile "$source_file"
        fi
    done
fi

# Restart the current shell to use the updated configs
exec $SHELL
