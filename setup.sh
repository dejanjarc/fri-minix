#!/bin/bash
# Script to create a disk image for Minix and boot it using QEMU
# Usage: first time setup of Minix. After that, run minix/run.sh to boot Minix from the disk image

show_help() {
  echo "Usage: $0 [-s SIZE] [-n NAME] [-i ISO]"
  echo ""
  echo "Create a Minix disk image and boot it via QEMU for installation."
  echo ""
  echo "Options:"
  echo "  -h, --help   Show this help message and exit."
  echo "  -s, --size   Size of the Minix disk image. Value must be between 1 and 10. Default: 2."
  echo "  -n, --name   Name or path of the disk image file (default: minix.img)"
  echo "  -i, --iso    Specify the Minix ISO file (without .iso extension). Default: auto-detects a .iso file in the current directory."
  echo ""
  echo "Example:"
  echo "  $0 -s 4                            Create a 4GB disk image for Minix"
  echo "  $0 -s 3 -i minixISO -n myMinix     Create a 3GB disk image from './minixISO.iso' named './myMinix.img'"
  echo "  $0 -n images/myMinix.img           Create a disk image named './images/myMinix.img'"
  echo ""
}

# --- Default values ---
IMG_SIZE=2
IMG_NAME="minix.img"
ISO_NAME=""

# --- Argument parsing ---
while [[ $# -gt 0 ]]; do
  case "$1" in
    -s|--size)
      shift
      IMG_SIZE="$1"
      ;;
    -n|--name)
      shift
      # Handle the case where the user provides a path or name
      if [[ "$1" == *.img ]]; then
        IMG_NAME="$1"
        WORK_DIR="$(dirname "$IMG_NAME")"
        IMG_NAME="$(basename "$IMG_NAME")"
      else
        IMG_NAME="$1.img"
      fi
      ;;
    -h|--help)
      show_help
      exit 0
      ;;
    -i|--iso)
      shift
      ISO_NAME="$1"
      ;;
    *)
      echo "Unknown argument: $1"
      echo ""
      echo -e "Run $0 --help or -h to view options.\n"
      exit 1
      ;;
  esac
  shift
done

# Allow sizes between 1 and 10
if [[ $IMG_SIZE -lt 1 || $IMG_SIZE -gt 10 ]]; then
  echo "  Invalid size: '$IMG_SIZE'"
  echo "  Only image sizes between 1GB and 10GB are allowed."
  exit 1
fi

# --- ISO detection or validation ---
if [[ -n "$ISO_NAME" ]]; then
  ISO_FILE="${ISO_NAME}.iso"
  if [[ ! -f "$ISO_FILE" ]]; then
    echo "Error: Specified ISO file '$ISO_FILE' does not exist."
    exit 1
  fi
else
  ISO_MATCHES=(*.iso)
  if [[ ${#ISO_MATCHES[@]} -eq 0 ]]; then
    echo "Error: No .iso file found in the current directory."
    exit 1
  elif [[ ${#ISO_MATCHES[@]} -gt 1 ]]; then
    echo "Error: Multiple .iso files found. Please specify one with -i or --iso."
    ls *.iso
    exit 1
  else
    ISO_FILE="${ISO_MATCHES[0]}"
  fi
fi

# Check if disk image already exists
if [ -f "$IMG_NAME" ]; then
  echo "Image $IMG_NAME detected. It may contain an already active installation of Minix."
  read -p "Would you like to remove '$IMG_NAME' and create a fresh image? [y/N] " answer
  case "$answer" in
    [yY])
      echo "Removing existing image..."
      rm "$IMG_NAME"
      ;;
    *)
      echo "Aborting. $IMG_NAME was not removed."
      echo ""
      exit 1
      ;;
  esac
fi

sleep 2

echo "Creating ${IMG_SIZE}G $IMG_NAME..."
if qemu-img create "$IMG_NAME" "${IMG_SIZE}G"; then
  echo "Image $IMG_NAME created."
else 
  echo "Error: Failed to create image $IMG_NAME."
  exit 1
fi

sleep 2
echo "Booting Minix from $ISO_FILE and setting the drive to $IMG_NAME..."

sleep 2

qemu-system-x86_64 \
  -rtc base=localtime \
  -net user \
  -net nic \
  -m 256 \
  -cdrom "$ISO_FILE" \
  -drive file="$IMG_NAME",format=raw \
  -boot d \
  -display curses
