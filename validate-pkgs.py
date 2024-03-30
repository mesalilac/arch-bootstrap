#!/usr/bin/env python

"""
Check if all packages are still availlable
"""

from include.parser import *


def main():
    packages = parse_file("./include/packages.bash")

    # TODO: loop all pacman and aur packages and check them


if __name__ == "__main__":
    main()
