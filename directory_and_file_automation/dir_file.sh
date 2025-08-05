#!/bin/bash

#create main directory
echo "creating directory..."
NEW_DIR="src"

mkdir $NEW_DIR

#create sub directories
echo "creating sub-directories..."

cd $NEW_DIR

subDirectories=(src docs tests bin)

for sd in ${subDirectories[@]}; do
    mkdir $sd
    echo "created sub directory {$sd}"
done