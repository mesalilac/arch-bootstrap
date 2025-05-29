#!/usr/bin/env bash

# Read include/packages and check if the packages doesn't exists

. "include/packages.bash"

echo "Checking pacman packages"

for pkg in "${PACMAN_PACKAGES[@]}";
do
    if ! pacman -Ss "^${pkg}$" > /dev/null ; then
        echo "ERROR: Pacman package '${pkg}' not found!"
    fi
done
