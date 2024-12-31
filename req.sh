#!/bin/bash

# Detect OS
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    if ! command -v brew &> /dev/null; then
        echo "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi

    # Install required tools
    for tool in cppcheck clang-format clang-tidy; do
        if ! command -v $tool &> /dev/null; then
            echo "Installing $tool..."
            brew install $tool
        else
            echo "$tool is already installed"
        fi
    done
elif [[ "$OSTYPE" == "linux"* ]]; then
    # Linux - assuming Debian/Ubuntu
    if ! command -v apt &> /dev/null; then
        echo "Error: This script requires apt package manager"
        exit 1
    fi

    # Install required tools
    for tool in cppcheck clang-format clang-tidy; do
        if ! command -v $tool &> /dev/null; then
            echo "Installing $tool..."
            sudo apt update && sudo apt install -y $tool
        else
            echo "$tool is already installed"
        fi
    done
else
    echo "Unsupported operating system"
    exit 1
fi