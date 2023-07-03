#!/bin/bash

# This script is used to restore files from the trash bin.
# 截取文件名
filename=$(basename $1)
src=$(grep ${filename} ~/.trashBin/.log | awk '{print $3}')
dst=$(grep ${filename} ~/.trashBin/.log | awk '{print $4}')

mv $src $dst