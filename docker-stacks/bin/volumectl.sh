#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

usage() {
  echo "Usage:"
  echo "  $0 create <volume>"
  echo "  $0 backup <volume> [output.tar.gz]"
  echo "  $0 restore <backup.tar.gz> <volume>"
  echo "  $0 migrate <local_dir> <volume>"
  echo "  $0 copyvl <volume> <local_dir> <volume_file> <local_file> [compress]"
  echo "  $0 copylv <local_dir> <volume> <local_file> <volume_file> <volume_dest> [extract]"
  echo "  $0 copyvv <volume> <new_volume>"
  echo "  $0 exec <volume> <volume_local_path> <command to execute>"
  echo "  $0 delete <volume>"
  exit 1
}

# --- Backup volume into tar.gz ---
backup_volume() {
  local volume=$1
  local output_folder=$2
  local last_backup_timestamp="${3:-}"  # date
  local output_file="${4:-"${volume}.tar.gz"}"
  
  if [[ $last_backup_timestamp == "" ]]; then
    last_backup_timestamp="$(date +"%Y-%m-%d_%H-%M-%S.%3N_%Z")"
  fi

  if ! docker volume inspect "$volume" >/dev/null 2>&1; then
    echo "❌ Volume '$volume' does not exist."
    exit 0
  fi
  
  output_path="$output_folder/$output_file"
  if [[ -f "$output_path" ]]; then
      echo "📦 Previous backup detected at $output_path"

      # Create timestamped subfolder
      OLD_DIR="$output_folder/../old/${last_backup_timestamp}/$(basename "$output_folder")"
      if [[ ! -e "$OLD_DIR" ]]; then
        mkdir -p "$OLD_DIR"
      fi

      # Move old backup
      mv "$output_path" "$OLD_DIR/"
      echo "🕐 Moved old backup to $OLD_DIR/"
  fi

  echo "📦 Backing up volume '$volume' to '$output_path'..."
  docker run --rm \
    -v "$volume":/src \
    -v "$output_folder":/backup \
    alpine sh -c "cd /src && tar -czf /backup/$output_file ."

  echo "✅ Backup complete: $output_file"
}

# --- Restore tar.gz into volume ---
restore_volume() {
  local volume=$1
  local backup_folder=$2
  local backup_file=${3:-"${volume}.tar.gz"}

  backup_path="$backup_folder/$backup_file"
  if [ ! -f "$backup_path" ]; then
    echo "❌ Backup file '$backup_path' does not exist."
    exit 1
  fi

  if ! docker volume inspect "$volume" >/dev/null 2>&1; then
    echo "📦 Creating volume '$volume'..."
    docker volume create "$volume" >/dev/null
  else
    echo "⚠️  Volume '$volume' already exists. Restoring will overwrite its contents."
  fi

  echo "📂 Restoring '$backup_file' into volume '$volume'..."
  docker run --rm \
    -v "$volume":/dest \
    -v "$backup_path":/backup/backup.tar.gz \
    alpine sh -c "rm -rf /dest/* && tar -xzf /backup/backup.tar.gz -C /dest"

  echo "✅ Restore complete."
}

copy_data_from_local_to_volume() {
    local local_dir="$1"
    local volume="$2"
    local local_file="$3"
    local container_dest="$4"
    local extract="${5:-false}"  # optional: true|false (default false)

    # Validate inputs
    if [[ -z "$local_dir" || -z "$volume" || -z "$local_file" || -z "$container_dest" ]]; then
        echo "❌ Usage: copy_data_from_local_to_volume <local_dir> <volume> <local_file> <container_dest> [extract]"
        return 1
    fi

    local src_path
    src_path="$(realpath "$local_dir/$local_file")"

    if [[ ! -e "$src_path" ]]; then
        echo "❌ Local file not found: $src_path"
        return 1
    fi

    echo "📂 Copying '$src_path' into volume '$volume' at '$container_dest'..."

    if [[ "$extract" == "true" ]]; then
        if [[ "$src_path" == *.tar.gz || "$src_path" == *.tgz ]]; then
            echo "📦 Extracting archive into volume..."

            if docker run --rm \
                -v "$volume":/dest \
                -v "$src_path":/tmp/archive.tar.gz:ro \
                alpine sh -c "mkdir -p /dest/$container_dest && tar xzf /tmp/archive.tar.gz -C /dest/$container_dest"; then
                echo "✅ Archive extracted successfully to '/dest/$container_dest'"
                return 0
            else
                echo "❌ Failed to extract archive"
                return 1
            fi
        else
            echo "⚠️  Extract option specified but file is not a .tar.gz — copying instead"
        fi
    fi

    # Regular copy
    if docker run --rm \
        -v "$volume":/dest \
        -v "$(dirname "$src_path")":/src:ro \
        alpine sh -c "mkdir -p /dest/$(dirname "$container_dest") && cp -a /src/$(basename "$src_path") /dest/$container_dest"; then
        echo "✅ Data copied successfully."
    else
        echo "❌ Failed to copy data."
        return 1
    fi
}

# --- Copy Data from volume to local ---
copy_data_from_volume_to_local() {
    local volume="$1"
    local local_dir="$2"
    local container_path="$3"
    local local_name="$4"
    local compress="${5:-false}"  # optional: true|false, default false

    # Validate inputs
    if [[ -z "$volume" || -z "$local_dir" || -z "$container_path" || -z "$local_name" ]]; then
        echo "❌ Usage: copy_data_from_volume_to_local <volume> <local_dir> <container_path> <local_name> [compress]"
        return 1
    fi

    # Ensure local directory exists
    mkdir -p "$local_dir" || { echo "❌ Failed to create local directory '$local_dir'"; return 1; }

    # Check if the file/directory exists inside the volume
    if ! docker run --rm -v "$volume":/src:ro alpine sh -c "[ -e /src/$container_path ]"; then
        echo "❌ '$container_path' does not exist in volume '$volume'"
        return 1
    fi

    local dest_path="$local_dir/$local_name"

    echo "📂 Copying '$container_path' from volume '$volume' to '$dest_path'..."

    if [[ "$compress" == "true" ]]; then
        # Copy and compress
        if docker run --rm -v "$volume":/src:ro -v "$(realpath "$local_dir")":/dest alpine sh -c "tar czf /dest/$local_name.tar.gz -C /src $(basename "$container_path")"; then
            echo "✅ Data copied and compressed to '$dest_path.tar.gz'"
        else
            echo "❌ Failed to copy and compress data"
            return 1
        fi
    else
        # Regular copy
        if docker run --rm -v "$volume":/src:ro -v "$(realpath "$local_dir")":/dest alpine sh -c "cp -a /src/$container_path /dest/$local_name"; then
            echo "✅ Data copied successfully to '$dest_path'"
        else
            echo "❌ Failed to copy data"
            return 1
        fi
    fi
}


# --- Migrate local dir into new volume ---
migrate_to_volume() {
  local local_dir=$1
  local volume=$2
  local migrate=false
  local create=false
  
  if docker volume inspect "$volume" >/dev/null 2>&1; then
    echo "⚠️  Volume '$volume' already exists. Skipping migration."
    exit 0
  else 
    migrate=true
  fi

  if [ ! -d "$local_dir" ] || [ -z "$(ls -A "$local_dir")" ]; then
    echo "❌ Local directory '$local_dir' does not exist or is empty. Creating empty volume '$volume'..."
    create=true
    migrate=false
  fi
  
  if $create; then 
    create_volume "$volume"
  fi

  if $migrate; then
    echo "📂 Copying data from '$local_dir' into volume '$volume'..."
    docker run --rm \
      -v "$volume":/dest \
      -v "$(realpath "$local_dir")":/src \
      alpine sh -c "cp -a /src/. /dest/"

    echo "✅ Migration complete."
  fi
}

# --- Copy volume into a new volume ---
copy_volume() {
  local volume=$1
  local new_volume = $2

  if ! docker volume inspect "$volume" >/dev/null 2>&1; then
    echo "❌  Volume '$volume' to copy not exist. Skipping copy."
    exit 0
  fi

  if docker volume inspect "$new_volume" >/dev/null 2>&1; then
    echo "⚠️  Volume '$new_volume' already exists. Skipping copy."
    exit 0
  fi

  create_volume "$new_volume"

  echo "📂 Copying data from '$volume' into volume '$new_volume'..."
  docker run --rm \
    -v "$volume":/src \
    -v "$new_volume":/dest \
    alpine sh -c "cp -a /src/. /dest/"

  echo "✅ Data copy complete."
}

# --- Execute a command in a volume and return its value ---
exec_command_volume() {
  local volume=$1
  local volume_local_path=$2
  shift 2
  local command="$@"

  if ! docker volume inspect "$volume" >/dev/null 2>&1; then
    echo "❌  Volume '$volume' not exist. Skipping." >&2
    exit 0
  fi

  echo "📂 Executing command '$command' from '$volume'" >&2
  local result=$(docker run --rm \
    -v "$volume":$volume_local_path \
    alpine sh -c "$command" 2>&1)
  local exit_code=$?

  if [ $exit_code -eq 0 ]; then
    echo "✅ Executing command complete." >&2
  else
    echo "❌ Command failed with exit code $exit_code" >&2
  fi

  # Print only the result to stdout
  echo "$result"

  return $exit_code
}

# --- create new volume ---
create_volume() {
  local volume=$1
  echo "📦 Creating volume '$volume'..."
  docker volume create "$volume" >/dev/null
  echo "✅ Creation complete."
}

# --- delete existing volume ---
delete_volume() {
  local volume=$1

  if docker volume inspect "$volume" >/dev/null 2>&1; then
    echo "📦 Deleting volume '$volume'..."
    docker volume rm "$volume" >/dev/null
    echo "✅ Deletion complete."
  else 
    echo "⚠️  Volume '$volume' don't exist. Skipping deletion."
    exit 0
  fi
}

# --- Main dispatcher ---
cmd=${1:-""}
shift || true

case "$cmd" in
  backup)   [ $# -lt 1 ] && usage; backup_volume "$@" ;;
  restore)  [ $# -lt 2 ] && usage; restore_volume "$@" ;;
  migrate)  [ $# -lt 2 ] && usage; migrate_to_volume "$@" ;;
  create)  [ $# -lt 1 ] && usage; create_volume "$@" ;;
  delete)  [ $# -lt 1 ] && usage; delete_volume "$@" ;;
  copyvv)  [ $# -lt 2 ] && usage; copy_volume "$@" ;;
  copyvl)  [ $# -lt 4 ] && usage; copy_data_from_volume_to_local "$@" ;;
  copylv)  [ $# -lt 4 ] && usage; copy_data_from_local_to_volume "$@" ;;
  exec)  [ $# -lt 3 ] && usage; exec_command_volume "$@" ;;
  *) usage ;;
esac