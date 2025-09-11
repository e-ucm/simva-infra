#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

usage() {
  echo "Usage:"
  echo "  $0 create <volume>"
  echo "  $0 backup <volume> [output.tar.gz]"
  echo "  $0 restore <backup.tar.gz> <volume>"
  echo "  $0 migrate <local_dir> <volume>"
  echo "  $0 copy <volume> <new_volume>"
  echo "  $0 exec <volume> <volume_local_path> <command to execute>"
  echo "  $0 delete <volume>"
  exit 1
}

# --- Backup volume into tar.gz ---
backup_volume() {
  local volume=$1
  local output_file=${2:-"${volume}_backup_$(date +%Y%m%d_%H%M%S).tar.gz"}

  if ! docker volume inspect "$volume" >/dev/null 2>&1; then
    echo "❌ Volume '$volume' does not exist."
    exit 0
  fi

  mkdir -p "$(dirname "$output_file")"

  echo "📦 Backing up volume '$volume' to '$output_file'..."
  docker run --rm \
    -v "$volume":/src \
    -v "$(dirname "$(realpath "$output_file")")":/backup \
    alpine sh -c "cd /src && tar -czf /backup/$(basename "$output_file") ."

  echo "✅ Backup complete: $output_file"
}

# --- Restore tar.gz into volume ---
restore_volume() {
  local backup_file=$1
  local volume=$2

  if [ ! -f "$backup_file" ]; then
    echo "❌ Backup file '$backup_file' does not exist."
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
    -v "$(realpath "$backup_file")":/backup/backup.tar.gz \
    alpine sh -c "rm -rf /dest/* && tar -xzf /backup/backup.tar.gz -C /dest"

  echo "✅ Restore complete."
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
  copy)  [ $# -lt 2 ] && usage; copy_volume "$@" ;;
  exec)  [ $# -lt 3 ] && usage; exec_command_volume "$@" ;;
  *) usage ;;
esac