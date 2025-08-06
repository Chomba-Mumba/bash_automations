#!/bin/bash

#create main directory
echo "creating directory..."
NEW_DIR="src"

mkdir $NEW_DIR

#create sub directories
echo "creating sub-directories..."

cd $NEW_DIR

subDirectories=(src docs tests bin var)

for sd in ${subDirectories[@]}; do
    mkdir $sd
    echo "created sub directory {$sd}"
done

#create log file
sudo touch /var/output.log

ts=$(date +"%Y-%m-%d %H:%M:%S")

sudo echo "${ts} learning to write bash" >> ./var/output.log