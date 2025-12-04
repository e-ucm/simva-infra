#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

export DEBUG=true;

echo "🔍 Detecting root LV..."
ROOT_LV=$(findmnt -n -o SOURCE /)
echo "📦 Root LV: $ROOT_LV"

# Detect VG and PV
echo "🔍 Detecting VG and PV..."
VG_NAME=$(lvs --noheadings -o vg_name "$ROOT_LV" | xargs)
PV_PATH=$(pvs --noheadings -o pv_name --select vgname="$VG_NAME" | xargs)
DISK=$(lsblk -no PKNAME "$PV_PATH" | head -n1)
DISK="/dev/$DISK"
PART_NUM=$(echo "$PV_PATH" | grep -o '[0-9]*$')

# ensure tools
if ! command -v growpart >/dev/null 2>&1; then
  echo "⚠️ growpart not found, installing cloud-guest-utils..."
  apt-get update -y
  apt-get install -y cloud-guest-utils
fi
if ! command -v sgdisk >/dev/null 2>&1; then
  echo "⚠️ sgdisk (gdisk) not found, installing gdisk..."
  apt-get update -y
  apt-get install -y gdisk
fi

# Detect partition number by parsing partition name
echo "📦 Physical volume: $PV_PATH"
echo "📦 Disk: $DISK"
echo "📦 Partition number: $PART_NUM"

# Check if partition already uses all disk space
DISK_SIZE=$(blockdev --getsize64 $DISK)
PART_END=$(parted -m $DISK unit B print | grep "^$PART_NUM:" | cut -d: -f3 | tr -d 'B')

# helper: attempt partition grow and return success/failure
attempt_grow() {
  echo "▶ Attempting growpart $DISK $PART_NUM"
  set +e
  if growpart "$DISK" "$PART_NUM"; then
    set -e
    echo "✅ growpart succeeded"
    return 0
  else
    set -e
    echo "❌ growpart failed"
    return 1
  fi
}

if (( PART_END >= DISK_SIZE )); then
  echo "✅ Partition already extended to disk end (or no extra space)."
else
  echo "ℹ️ Partition does not reach disk end; try to grow."

  # First attempt growpart
  if attempt_grow; then
    echo "Partition grown by growpart."
  else
    echo "⚠️ growpart/parted failed. Attempting to fix GPT backup header with sgdisk -e and retry."
    echo "   (This fixes the backup GPT header location so the partition can be resized.)"
    # sgdisk -e moves backup GPT header to the end of disk
    if sgdisk -e "$DISK"; then
      echo "✅ sgdisk -e succeeded (backup GPT moved). Retrying growpart..."
      if attempt_grow; then
        echo "✅ growpart succeeded after sgdisk -e"
      else
        echo "❌ growpart still failed after sgdisk -e. Aborting."
        exit 0
      fi
    else
      echo "❌ sgdisk -e failed. Aborting."
      exit 0
    fi
  fi
fi

# Now resize PV, LV and filesystem
echo "📦 Resizing physical volume $PV_PATH ..."
if pvresize "$PV_PATH"; then
  echo "✅ pvresize OK"
else
  echo "⚠️ pvresize reported failure (but continuing)."
fi

echo "📦 Checking for VG free space..."
VG_FREE_BYTES=$(vgdisplay "$VG_NAME" --units b --noheadings 2>/dev/null | awk '/Free  PE/ {print $3}' || true)
# alternative check: use vgs -o vg_free --noheadings --units b
VG_FREE=$(vgs --noheadings -o vg_free --units b --nosuffix "$VG_NAME" 2>/dev/null | tr -d ' ' || echo "0")
VG_FREE=${VG_FREE:-0}
echo "🔢 VG free: $VG_FREE bytes (approx)"

if [[ "$VG_FREE" == "0" || "$VG_FREE" == "" ]]; then
  echo "ℹ️ No free space in VG to extend. Still attempt lvextend in case of unit mismatch..."
fi

echo "📦 Extending logical volume $ROOT_LV to use all free space..."
# run lvextend but ignore non-zero exit if no change
if lvextend -l +100%FREE "$ROOT_LV"; then
  echo "✅ lvextend OK (or no-op)"
else
  echo "⚠️ lvextend returned non-zero. It may be a no-op if already full."
fi

MOUNT_POINT=$(findmnt -n -o TARGET /)
FS_TYPE=$(df -T / | tail -n1 | awk '{print $2}')
echo "📂 Mount point: $MOUNT_POINT"
echo "📄 Filesystem type: $FS_TYPE"

if [[ -z "$MOUNT_POINT" ]]; then
  echo "⚠️ Root is not mounted; cannot resize filesystem automatically."
  exit 0
fi

case "$FS_TYPE" in
  xfs)
    echo "🔧 Running xfs_growfs on $MOUNT_POINT"
    if xfs_growfs "$MOUNT_POINT"; then
      echo "✅ xfs_growfs OK"
    else
      echo "❌ xfs_growfs failed"
      exit 0
    fi
    ;;
  ext4|ext3)
    echo "🔧 Running resize2fs on $ROOT_LV"
    if resize2fs "$ROOT_LV"; then
      echo "✅ resize2fs OK"
    else
      echo "❌ resize2fs failed"
      exit 0
    fi
    ;;
  *)
    echo "⚠️ Unsupported FS type: $FS_TYPE. Please resize manually."
    ;;
esac

echo "🎉 Resize finished. New root size:"
df -h /