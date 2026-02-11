# Build Lambda deployment package for OpenEMR API
# Run this from the project root directory

$ErrorActionPreference = "Stop"
# Script is in scripts/build_lambda.ps1, project root is parent of scripts
$ProjectRoot = (Get-Item $PSScriptRoot).Parent.FullName
# Use temp dir to avoid conflicts with locked files from previous builds
$BuildDir = Join-Path $env:TEMP "openemr-lambda-build-$(Get-Date -Format 'yyyyMMddHHmmss')"
$PackageDir = Join-Path $BuildDir "package"

Write-Host "Building Lambda deployment package..." -ForegroundColor Cyan
Write-Host "Project root: $ProjectRoot"
New-Item -ItemType Directory -Path $PackageDir -Force | Out-Null

# Install dependencies to package directory
Write-Host "`nInstalling Python dependencies..." -ForegroundColor Yellow
$RequirementsFile = Join-Path $ProjectRoot "requirements.txt"
pip install -r $RequirementsFile -t $PackageDir --upgrade

# Copy application code (exclude test files and unnecessary files)
$SourceFiles = @("main.py", "lambda_handler.py")
foreach ($file in $SourceFiles) {
    $src = Join-Path $ProjectRoot $file
    if (Test-Path $src) {
        Copy-Item $src -Destination $PackageDir -Force
        Write-Host "  Copied $file"
    } else {
        Write-Error "Required file not found: $file"
    }
}

# Create zip (Lambda expects flat structure - all files in root of zip)
$ZipDir = Join-Path $ProjectRoot "terraform"
$ZipPath = Join-Path $ZipDir "lambda.zip"
if (-not (Test-Path $ZipDir)) { New-Item -ItemType Directory -Path $ZipDir -Force | Out-Null }

# Write to temp file first to avoid overwriting locked files
$TempZipPath = Join-Path $env:TEMP "openemr-lambda-$(Get-Date -Format 'yyyyMMddHHmmss').zip"

Write-Host "`nCreating deployment package..." -ForegroundColor Yellow
Set-Location $PackageDir
Compress-Archive -Path * -DestinationPath $TempZipPath -Force
Set-Location $ProjectRoot

# Move to final location (copy then delete to handle locked files)
Copy-Item $TempZipPath -Destination $ZipPath -Force
Remove-Item $TempZipPath -Force -ErrorAction SilentlyContinue

# Cleanup build directory
Remove-Item -Recurse -Force $BuildDir -ErrorAction SilentlyContinue

$ZipSize = (Get-Item $ZipPath).Length / 1MB
Write-Host "`nDone! Package created: $ZipPath" -ForegroundColor Green
Write-Host "Size: $([math]::Round($ZipSize, 2)) MB"
Write-Host "`nNext step: cd terraform && terraform init && terraform apply"
