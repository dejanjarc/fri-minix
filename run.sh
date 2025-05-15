#!/bin/bash

# Script to boot Minix using QEMU
# Usage: booting Minix from the existing disk image. If the disk image does not exist, it will prompt to run minix/setup.sh first.

show_help() {
  echo "Usage: $0 [-n NAME_OR_PATH]"
  echo ""
  echo "Boot Minix from a previously created disk image using QEMU."
  echo ""
  echo "Options:"
  echo "  -h, --help    Show this help message and exit"
  echo "  -n, --name    Name or path of the disk image file (default: minix.img)"
  echo ""
  echo "Examples:"
  echo "  $0                        Boot using './minix.img'"
  echo "  $0 -n myMinix             Boot using './myMinix.img'"
  echo "  $0 -n images/minix.img    Boot using './images/minix.img'"
  echo ""
}

# --- Default values ---
IMG_NAME="minix.img"
WORK_DIR="$(pwd)"

# --- Argument parsing ---
while [[ $# -gt 0 ]]; do
  case "$1" in
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
    *)
      echo "Unknown argument: $1"
      echo ""
      echo -e "Run $0 --help or -h to view options.\n"
      exit 1
      ;;
  esac
  shift
done

FULL_PATH="$WORK_DIR/$IMG_NAME"

# --- Check if disk image exists ---
if [ ! -f "$FULL_PATH" ]; then
  echo "Disk image '$FULL_PATH' not found."
  echo "This may be due to a typo in the image name or because it hasn't been created yet."
  echo ""

  echo "If the image doesn't exist, you need to create it first."
  echo "After that you need to proceed with the setup within Minix and install it onto the image."
  read -p "Would you like to run setup.sh to create '$IMG_NAME'? [y/N] " answer
  case "$answer" in
    [yY])
      echo "Running setup.sh with image name '${IMG_NAME%.img}'..."
      sleep 2
      ./setup.sh -n "${IMG_NAME%.img}"
      exit $?
      ;;
    *)
      echo "Aborting. You can manually create the image with:"
      echo "  ./setup.sh -n ${IMG_NAME%.img}"
      echo ""
      exit 1
      ;;
  esac
fi

# Run Minix from the existing disk image
echo "Booting Minix from '$FULL_PATH'..."

sleep 2

qemu-system-x86_64 \
  -rtc base=localtime \
  -net user \
  -net nic \
  -m 256 \
  -drive file="$FULL_PATH",format=raw \
  -boot d \
  -display curses
