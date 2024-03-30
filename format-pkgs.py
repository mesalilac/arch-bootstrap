#!/usr/bin/env python

"""
Format packages.bash and add package info
"""

from include.parser import *


def get_pacman_pkg_info(package: Package):
    ...


def get_aur_pkg_info(package: Package):
    ...


def main():
    packages = parse_file("./include/packages.bash")

    print(to_string(packages))


if __name__ == "__main__":
    main()
