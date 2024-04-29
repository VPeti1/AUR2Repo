#!/bin/bash
set -e 
set -o pipefail

# Prompt user for package names, repository name, and architecture
read -p "Enter a name of the packages: " package_name
read -p "Enter a name of the repo: " repo_name
read -p "Enter the architecture of the repo (Like: x86_64): " arch

# Check if /usr/bin/yay exists
if [ -e "/usr/bin/yay" ]; then
    echo "Found Yay"
else
    echo "Yay is needed to run this script!"
    exit 1
fi

# Run yay command for each package separately
for pkg in $package_name; do
    yay --builddir "$(pwd)" -S "$pkg"
done

# Delete files with "debug" in the name
find . -type f -name "*debug*" -delete

# Create repository directory
mkdir -p "$repo_name"
mkdir -p "$repo_name"/"$arch"

# Copy packages to repository directory
find . -type f -name "*.zst" -exec cp {} "$repo_name"/"$arch" \;

cd "$repo_name"

# Create architecture directory

cd "$arch"

# Create repository database
repo-add "$repo_name".db.tar.gz *.pkg.tar.zst

# Update repository database and file list
unlink "$repo_name".db
unlink "$repo_name".files
mv "$repo_name".db.tar.gz "$repo_name".db
mv "$repo_name".files.tar.gz "$repo_name".files

echo "Repo created"
