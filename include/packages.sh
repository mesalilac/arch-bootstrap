#!/usr/bin/env bash

export PACMAN_PACKAGES=(
    "sccache"                     # Shared compilation cache
    "chafa"                       # Image-to-text converter supporting a wide range of symbols and palettes, transparency, animations, etc.
    "resources"                   # Monitor for system resources and processes
    "colordiff"                   # A Perl script wrapper for 'diff' that produces the same output but with pretty 'syntax' highlighting
    "stylelint"                   # Mighty, modern CSS linter
    "luacheck"                    # A tool for linting and static analysis of Lua code
    "ghostty"                     # Fast, native, feature-rich terminal emulator pushing modern features
    "baobab"                      # GNOME Disk Usage Analyzer
    "hyprpicker"                  # A wlroots-compatible Wayland color picker that does not suck
    "hypridle"                    # hyprland’s idle daemon
    "hyprlock"                    # hyprland’s GPU-accelerated screen locking utility
    "spotify-launcher"            # Client for spotify's apt repository in Rust for Arch Linux
    "power-profiles-daemon"       # Makes power profiles handling available over D-Bus
    "eslint_d"                    # Makes eslint the fastest linter on the planet.
    "typescript-language-server"  # Language Server Protocol (LSP) implementation for TypeScript using tsserver
    "flatpak"                     # Linux application sandboxing and distribution framework (formerly xdg-app)
    "lua-language-server"         # Lua Language Server coded by Lua
    "wl-clipboard"                # Command-line copy/paste utilities for Wayland
    "xdg-desktop-portal-gtk"      # A backend implementation for xdg-desktop-portal using GTK
    "xdg-desktop-portal-hyprland" # xdg-desktop-portal backend for hyprland
    "hyprpolkitagent"             # Simple polkit authentication agent for Hyprland, written in QT/QML
    "hyprland"                    # a highly customizable dynamic tiling Wayland compositor
    "lib32-nvidia-utils"          # NVIDIA drivers utilities (32-bit)
    "nvidia-utils"                # NVIDIA drivers utilities
    "nvidia-dkms"                 # NVIDIA kernel modules - module sources
    "linux-headers"               # Headers and scripts for building modules for the Linux kernel
    "hyprpaper"                   # a blazing fast wayland wallpaper utility with IPC controls
    "waybar"                      # Highly customizable Wayland bar for Sway and Wlroots based compositors
    "wofi"                        # launcher for wlroots-based wayland compositors
    "psensor"                     # Graphical hardware temperature monitoring application
    "wmenu"                       # Efficient dynamic menu for Wayland and wlroots based Wayland compositors
    "mesa"                        # Open-source OpenGL drivers
    "lib32-mesa"                  # Open-source OpenGL drivers - 32-bit
    "acpid"                       # A daemon for delivering ACPI power management events with netlink support
    "clang"                       # C language family frontend for LLVM
    "obsidian"                    # A powerful knowledge base that works on top of a local folder of plain text Markdown files
    "uthash"                      # C preprocessor implementations of a hash table and a linked list
    "zoxide"                      # A smarter cd command for your terminal
    "go"                          # Core compiler tools for the Go programming language
    "go-tools"                    # Developer tools for the Go programming language
    "python-pipx"                 # Install and Run Python Applications in Isolated Environments
    "python-black"                # Uncompromising Python code formatter
    "smartmontools"               # Control and monitor S.M.A.R.T. enabled ATA and SCSI Hard Drives
    "shellcheck"                  # Shell script analysis tool
    "gnome-text-editor"           # A simple text editor for the GNOME desktop
    "seahorse"                    # GNOME application for managing PGP keys.
    "gpick"                       # Advanced color picker written in C++ using GTK+ toolkit
    "playerctl"                   # mpris media player controller and lib for spotify, vlc, audacious, bmp, xmms2, and others.
    "cmake"                       # A cross-platform open-source make system
    "cloc"                        # Count lines of code
    "fontforge"                   # Outline and bitmap font editor
    "font-manager"                # A simple font management application for GTK+ Desktop Environments
    "udiskie"                     # Removable disk automounter using udisks
    # Fix: Steam no text
    "lib32-fontconfig"            # Library for configuring and customizing font access
    #
    # edit meta data
    #
    "easytag"                     # Simple application for viewing and editing tags in audio files
    #
    # calculators
    #
    "gnome-calculator"            # GNOME Scientific calculator
    #
    # audio
    #
    "alsa-tools"                  # Advanced tools for certain sound cards
    "alsa-utils"                  # Advanced Linux Sound Architecture - Utilities
    "pipewire"                    # Low-latency audio/video router and processor
    "wireplumber"                 # Session / policy manager implementation for PipeWire
    "qpwgraph"                    # PipeWire Graph Qt GUI Interface
    "pipewire-alsa"               # Low-latency audio/video router and processor - ALSA configuration
    "pipewire-pulse"              # Low-latency audio/video router and processor - PulseAudio replacement
    "pipewire-jack"               # Low-latency audio/video router and processor - JACK replacement
    #
    # manage audio
    #
    "pavucontrol"                 # PulseAudio Volume Control
    "pamixer"                     # Pulseaudio command-line mixer like amixer
    #
    # terminal
    #
    "alacritty"                   # A cross-platform, GPU-accelerated terminal emulator
    "kitty"                       # A modern, hackable, featureful, OpenGL-based terminal emulator
    #
    # text editors
    #
    "code"                        # The Open Source build of Visual Studio Code (vscode) editor
    #
    # music player
    #
    "cmus"                        # Feature-rich ncurses-based music player
    #
    # system monitor
    #
    "htop"                        # Interactive process viewer
    #
    # image editing
    #
    "gimp"                        # GNU Image Manipulation Program
    #
    # screenshot tools
    #
    "flameshot"                   # Powerful yet simple to use screenshot software
    #
    # imagemagick
    #
    "imagemagick"                 # An image viewing/manipulation program
    #
    # ffmpeg
    #
    "ffmpeg"                      # Complete solution to record, convert and stream audio and video
    "ffmpegthumbnailer"           # Lightweight video thumbnailer that can be used by file managers
    "ffmpegthumbs"                # FFmpeg-based thumbnail creator for video files
    #
    # shell
    #
    "zsh"                         # A very advanced and programmable command interpreter (shell) for UNIX
    "dash"                        # POSIX compliant shell that aims to be as small as possible
    #
    # zsh stuff
    #
    "zsh-completions"             # Additional completion definitions for Zsh
    #
    # file manager
    #
    "nemo"                        # Cinnamon file manager (Nautilus fork)
    "nemo-audio-tab"              # View audio tag information in Nemo properties tab
    "nemo-fileroller"             # File archiver extension for Nemo
    "nemo-image-converter"        # Nemo extension to rotate/resize image files
    #
    # libs
    #
    "libqalculate"                # Multi-purpose desktop calculator
    "lib32-libpulse"              # A featureful, general-purpose sound server (32-bit client libraries)
    "libguestfs"                  # Access and modify virtual machine disk images
    "libpng12"                    # A collection of routines used to create PNG format graphics files
    "libwacom"                    # Library to identify Wacom tablets and their features
    "gtk4"                        # GObject-based multi-platform GUI toolkit
    "sdl2"                        # An SDL2 compatibility layer that uses SDL3 behind the scenes
    "sdl2_image"                  # A simple library to load images of various formats as SDL surfaces (Version 2)
    "sdl2_ttf"                    # A library that allows you to use TrueType fonts in your SDL applications (Version 2)
    "raylib"                      # Simple and easy-to-use game programming library
    #
    # themes
    #
    "qt5ct"                       # Qt5 Configuration Utility
    "nwg-look"                    # lx lxappearance but for wayland
    # "lxappearance"
    # "lxappearance-obconf"
    "papirus-icon-theme"          # Papirus icon theme
    #
    "kdenlive"                    # A non-linear video editor for Linux using the MLT video framework
    "wget"                        # Network utility to retrieve files from the web
    # "discord" # use vesktop-bin
    "steam"                       # Valve's digital software delivery system
    "tree"                        # A directory listing program displaying a depth indented list of files
    "dust"                        # A more intuitive version of du in rust
    "tmux"                        # Terminal multiplexer
    "onboard"                     # On-screen keyboard useful on tablet PCs or for mobility impaired users
    "github-cli"                  # The GitHub CLI
    "gparted"                     # A Partition Magic clone, frontend to GNU Parted
    "zathura"                     # Minimalistic document viewer
    "zathura-pdf-mupdf"           # PDF support for Zathura (MuPDF backend) (Supports PDF, ePub, and OpenXPS)
    "python-setuptools"           # Easily download, build, install, upgrade, and uninstall Python packages
    "python-pywal"                # Generate and change colorschemes on the fly
    "yt-dlp"                      # A youtube-dl fork with additional features and fixes
    "ninja"                       # Small build system with a focus on speed
    "postgresql"                  # Sophisticated object-relational DBMS
    "postgresql-docs"             # HTML documentation for PostgreSQL
    "network-manager-applet"      # Applet for managing network connections
    "dhcpcd"                      # DHCP/ IPv4LL/ IPv6RA/ DHCPv6 client
    "redis"                       # An in-memory database that persists on disk
    "nodejs-lts-iron"             # Evented I/O for V8 javascript (LTS release
    "man-db"                      # A utility for reading man pages
    "docker"                      # Pack, ship and run any application as a lightweight container
    "dnsmasq"                     # Lightweight, easy to configure DNS forwarder and DHCP server
    "highlight"                   # Fast and flexible source code highlighter - CLI version
    "rsync"                       # A fast and versatile file copying tool for remote and local files
    "ntfs-3g"                     # NTFS filesystem driver and utilities
    "hwinfo"                      # Hardware detection tool from openSUSE
    "fzf"                         # Command-line fuzzy finder
    "bat"                         # Cat clone with syntax highlighting and git integration
    "bc"                          # An arbitrary precision calculator language
    "fd"                          # Simple, fast and user-friendly alternative to find
    "feh"                         # Fast and light imlib2-based image viewer
    "eog"                         # Eye of Gnome
    "zip"                         # Compressor/archiver for creating and modifying zipfiles
    "unzip"                       # For extracting and viewing files in .zip archives
    "unrar"                       # The RAR uncompression program
    "p7zip"                       # File archiver for extremely high compression
    "which"                       # A utility to show the full path of commands
    "jq"                          # Command-line JSON processor
    "yad"                         # A fork of zenity - display graphical dialogs from shell scripts or command line
    "npm"                         # JavaScript package manager
    "yarn"                        # Fast, reliable, and secure dependency management
    "firefox"                     # Fast, Private & Safe Web Browser
    "mpv"                         # a free, open source, and cross-platform media player
    "gnome-system-monitor"        # View current processes and monitor system state
    "transmission-gtk"            # Fast, easy, and free BitTorrent client (GTK+ GUI)
)

export AUR_PACKAGES=(
    "czkawka-gui-bin"
    "sqlitestudio-bin"
    "vesktop-bin"
    "opentabletdriver"
    "adw-gtk3-git"
    "tmuxinator"
    "exa"
    "diesel-cli"
    "cava"
    "pfetch"
    "code-marketplace"
    "spaceship-prompt-git"
    "gromit-mpx"
    "vtop"
    "selectdefaultapplication-git"
    "figma-linux"
    "fontpreview-ueberzug-git"
    "pnpm-bin"
    "icons-in-terminal"
    "inxi"
)
