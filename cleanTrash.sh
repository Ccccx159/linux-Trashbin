#!/bin/bash

if [[ -e /home/$USER/.trashBin ]]; then
    rm -rf /home/$USER/.trashBin/*
fi