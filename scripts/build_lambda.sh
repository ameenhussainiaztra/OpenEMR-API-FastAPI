#!/bin/bash
# Build Lambda deployment package for OpenEMR API
# Run this from the project root directory

set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
BUILD_DIR="$PROJECT_ROOT/build"
PACKAGE_DIR="$BUILD_DIR/package"

echo "Building Lambda deployment package..."
echo "Project root: $PROJECT_ROOT"

# Clean and create build directory
rm -rf "$BUILD_DIR"
mkdir -p "$PACKAGE_DIR"

# Install dependencies
echo ""
echo "Installing Python dependencies..."
pip install -r "$PROJECT_ROOT/requirements.txt" -t "$PACKAGE_DIR" --upgrade

# Copy application code
echo "Copying application files..."
cp "$PROJECT_ROOT/main.py" "$PACKAGE_DIR/"
cp "$PROJECT_ROOT/lambda_handler.py" "$PACKAGE_DIR/"

# Create zip
ZIP_PATH="$PROJECT_ROOT/terraform/lambda.zip"
mkdir -p "$(dirname "$ZIP_PATH")"
rm -f "$ZIP_PATH"

echo "Creating deployment package..."
cd "$PACKAGE_DIR"
zip -r "$ZIP_PATH" .
cd "$PROJECT_ROOT"

# Cleanup
rm -rf "$BUILD_DIR"

SIZE_MB=$(du -m "$ZIP_PATH" | cut -f1)
echo ""
echo "Done! Package created: $ZIP_PATH"
echo "Size: ${SIZE_MB} MB"
echo ""
echo "Next step: cd terraform && terraform init && terraform apply"
