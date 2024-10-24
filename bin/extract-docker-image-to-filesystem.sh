#!/bin/bash

# Check if an image name is provided as an argument
if [ -z "$1" ]; then
  echo "Usage: $0 <image-name>"
  exit 1
fi

IMAGE_NAME="$1"
OUTPUT_DIR="/tmp/$IMAGE_NAME"

# Create the container from the image
CONTAINER_ID=$(docker create "$IMAGE_NAME")

# Export the filesystem of the container to the specified directory
mkdir -p "$OUTPUT_DIR"
docker export "$CONTAINER_ID" | tar -C "$OUTPUT_DIR" -xf -

# Remove the container after export
docker rm "$CONTAINER_ID"

echo "The content of the image '$IMAGE_NAME' has been exported to $OUTPUT_DIR"

