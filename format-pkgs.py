#!/usr/bin/env python

"""
Format packages.bash and add package info
"""

from dataclasses import dataclass, field
from enum import Enum
from typing import List, Optional


@dataclass
class Package:
    name: Optional[str] = None
    description: Optional[str] = None


class CurrentArray(Enum):
    PACMAN = "PACMAN_PACKAGES"
    AUR = "AUR_PACKAGES"
    NONE = "none"


@dataclass
class State:
    current_array: CurrentArray = field(default=CurrentArray.NONE)


@dataclass
class Packages:
    pacman: List[Package] = field(default_factory=list)
    aur: List[Package] = field(default_factory=list)


def get_pacman_pkg_info(package: Package):
    ...


def get_aur_pkg_info(package: Package):
    ...


def parse_line(line: str) -> Package:
    reading_pkg_name: bool = False
    reading_comment: bool = False

    package = Package()

    temp_string = []
    temp_comment = []

    for char in line:
        if char == '"' and reading_comment == False:
            reading_pkg_name = not reading_pkg_name
            continue

        if char == "#" and reading_pkg_name == False:
            reading_comment = True
            continue

        if reading_comment == True:
            temp_comment.append(char)

        if reading_pkg_name == True:
            temp_string.append(char)

    if len(temp_string) != 0:
        package.name = "".join(temp_string)

    if len(temp_comment) != 0:
        if temp_comment[0] == " " and len(temp_comment) == 1:  # Comment is empty
            package.description = None
        else:
            package.description = "".join(temp_comment)

    return package


def parse_file() -> Packages:
    packages = Packages()

    with open("./include/packages.bash", "r") as f:
        state: State = State()

        for line in f:
            line = line.strip()

            if line == "export PACMAN_PACKAGES=(":
                state.current_array = CurrentArray.PACMAN
                continue
            elif line == "export AUR_PACKAGES=(":
                state.current_array = CurrentArray.AUR
                continue
            if line == ")":
                state.current_array = CurrentArray.NONE
                continue

            if (
                state.current_array != CurrentArray.NONE
                and line.startswith("#") == False
                and line != ""
            ):
                package = parse_line(line)
                if state.current_array == CurrentArray.PACMAN:
                    packages.pacman.append(package)
                elif state.current_array == CurrentArray.AUR:
                    packages.aur.append(package)

    return packages


def main():
    packages = parse_file()

    print("pacman_packages:", packages.pacman)
    print("len pacman_packages:", len(packages.pacman))

    print("aur:", packages.aur)
    print("len aur_packages:", len(packages.aur))


if __name__ == "__main__":
    main()
