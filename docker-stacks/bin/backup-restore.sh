#!/bin/bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

backup_data() {
    # Input path
    target="$1"
    local output_folder=$2
    local last_backup_timestamp=$3  # date
    local compress="${4:-false}"  # optional: true|false, default false
    local first_depth="${5:-false}"  # optional: true|false, default false

    # Check if the user provided an argument
    if [[ -z "$target" || -z $output_folder ]]; then
        echo "Usage: $0 <file-or-folder> <output-folder> [timestamp] [compress] [first_depth]"
        exit 1
    fi

    # Check if the folder exists
    if [[ ! -e "$target" ]]; then
        echo "Error: '$target' does not exist!"
        exit 1
    fi

    # Ensure output folder exists
    mkdir -p "$output_folder" || { echo "❌ Failed to create output directory '$output_folder'"; return 1; }
    # Get the absolute name and parent directory
    BASENAME=$(basename "$target")
    local backup_already_present=false;
    local output_file="${BASENAME}";
    if [[ $compress == "true" ]]; then
        output_path="$output_folder/$output_file.tar.gz"
    else
        output_path="$output_folder/$output_file"
    fi
    echo "$output_path";
    if [[ -e "$output_path" ]]; then
        echo "📦 Previous backup detected at $output_path"

        # Create timestamped subfolder    
        if [[ -z $last_backup_timestamp ]]; then
            last_backup_timestamp="$(date +"%Y-%m-%d_%H-%M-%S")"
        fi
        OLD_DIR="$output_folder/old_${last_backup_timestamp}"
        mkdir -p "$OLD_DIR"

        # Move old backup
        mv "$output_path" "$OLD_DIR/"
        echo "🕐 Moved old backup to $OLD_DIR/"
    fi

    if [[ $compress == "true"  ]]; then
        # Compressed backup
        if [[ $first_depth == "true" ]]; then
            # Only files in top folder (no recursive)
            tar -czvf "$output_path" -C "$target" $(find "$target" -maxdepth 1 -type f -printf "%f\n")
        else
            # Full folder compress
            tar -czvf "$output_path" "$target"
        fi
    else
        # Non-compressed backup
        if [[ $first_depth == "true" ]]; then
            # Copy only files in top folder (no recursive)
            find "$target" -maxdepth 1 -type f -exec cp {} "$output_path" \;
        else 
            # Copy full folder
            cp -r "$target" "$output_path"
        fi
    fi
    
    echo "Backup created: $output_file"
}

restore_data() {
    # Input path
    local input="$1"
    target="$2"
    local extract="${3:-false}"  # optional: true|false, default false

    # Check if the user provided an argument
    if [[ -z "$target" || -z "$input" ]]; then
        echo "Usage: $0 <input> <target> [extract]"
        exit 1
    fi

    # Check if the file/folder exists
    if [[ ! -e "$input" ]]; then
        echo "Error: '$input' does not exist!"
        exit 1
    fi

    # Ensure output folder exists
    mkdir -p "$target" || { echo "❌ Failed to create restoration directory '$target'"; return 1; }

    # Get the absolute name and parent directory
    BASENAME=$(basename "$target")
    local input_file="${BASENAME}";
    if [[ $extract == "true" ]]; then
        DEPTH=$(echo "$target" | awk -F/ '{print NF-1}')
        echo "DEPTH : $DEPTH";
        STRIP_COUNT=$((DEPTH))
        # Restore the backup
        tar --strip-components=$STRIP_COUNT -xzvf "$input/$input_file.tar.gz" -C "$target"
    else 
        cp "$input/$input_file" "$target"
    fi
    
    echo "Backup restored: $input_file"
}
