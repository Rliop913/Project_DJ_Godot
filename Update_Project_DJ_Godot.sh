#!/bin/bash

if ! command -v git &> /dev/null; then
    echo "Git is not installed. installing git."
    
    if command -v apt-get &> /dev/null; then
        sudo apt-get update
        sudo apt-get install -y git

    elif command -v pacman &> /dev/null; then
        sudo pacman -S git
    elif command -v dnf &> /dev/null; then
        sudo dnf install -y git
    elif command -v yum &> /dev/null; then
        sudo yum install -y git
    elif command -v brew &> /dev/null; then
        brew install git
    else
        echo "No known package manager found. Please install Git manually."
        exit 1
    fi
fi

if ! command -v git-lfs &> /dev/null; then
    echo "Git-lfs is not installed. installing git-lfs."
    
    if command -v apt-get &> /dev/null; then
        sudo apt-get update
        sudo apt-get install -y git-lfs

    elif command -v pacman &> /dev/null; then
        sudo pacman -S git-lfs
    elif command -v dnf &> /dev/null; then
        sudo dnf install -y git-lfs
    elif command -v yum &> /dev/null; then
        sudo yum install -y git-lfs
    elif command -v brew &> /dev/null; then
        brew install git-lfs
    else
        echo "No known package manager found. Please install Git-lfs manually."
        exit 1
    fi
fi


git lfs install

git clone --depth=1 https://github.com/Rliop913/Project_DJ_Godot.git

cd Project_DJ_Godot
git lfs pull

mkdir -p ../addons/Project_DJ_Godot
cp -r addons/Project_DJ_Godot/. ../addons/Project_DJ_Godot

[ -f PDJE_VERSION ] && cp PDJE_VERSION ../
[ -f PDJE_WRAPPER_VERSION ] && cp PDJE_WRAPPER_VERSION ../
[ -f Message_From_Project_DJ_Godot_Dev.md ] && cp Message_From_Project_DJ_Godot_Dev.md ../

cd ..
echo "installed! cleaning cloned repo now."
sudo rm -r Project_DJ_Godot

PDJE_VERSION=$(cat ./PDJE_VERSION)

PDJE_WRAPPER_VERSION=$(cat ./PDJE_WRAPPER_VERSION)

echo "PDJE Update Complete. PDJE_VERSION:${PDJE_VERSION}, PDJE_WRAPPER_VERSION:${PDJE_WRAPPER_VERSION}"
