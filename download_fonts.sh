#!/bin/bash

# Create fonts directory if it doesn't exist
mkdir -p assets/fonts

# Download Oswald fonts
curl -L "https://fonts.google.com/download?family=Oswald" -o oswald.zip
unzip -j oswald.zip "static/Oswald-Regular.ttf" "static/Oswald-Bold.ttf" -d assets/fonts/
rm oswald.zip

# Download Roboto fonts
curl -L "https://fonts.google.com/download?family=Roboto" -o roboto.zip
unzip -j roboto.zip "Roboto-Regular.ttf" "Roboto-Medium.ttf" "Roboto-Bold.ttf" -d assets/fonts/
rm roboto.zip 