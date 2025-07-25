#!/usr/bin/env bash

LOG_FILE="${HOME}/arch-bootstrap.log"

exec > >(tee -a "${LOG_FILE}") 2>&1

set -euo pipefail
set -x

USER_ID="$(id -u)"
if [[ "${USER_ID}" -eq 0 ]]; then
    echo "Don't run this script as root..."
    exit 1
fi

. "include/colors.sh"
. "include/packages.sh"

DOTFILES_REPO_URL="https://github.com/mesalilac/dotfiles"
DOTFILES_DIR="${HOME}/.dotfiles"

PATH="${HOME}/.cargo/bin:${PATH}"

function fn_log_info() {
    echo -e "[$(date +'%Y-%m-%d %H:%M:%S') ${On_Green}${BBlack} INFO ${NO_COLOR} ] $1"
}

function fn_log_error() {
    echo -e "[$(date +'%Y-%m-%d %H:%M:%S') ${On_Red}${BBlack} ERROR ${NO_COLOR} ] $1"
}

function fn_check_cmd {
    if ! command -v "$1" > /dev/null 2>&1; then
        fn_log_error "Dependency not found: $1"
        exit 1
    fi
}

function fn_print_banner {
    echo -e "${IGreen}"
    cat << "EOF"
        __                __       __
       / /_  ____  ____  / /______/ /__________ _____
      / __ \/ __ \/ __ \/ __/ ___/ __/ ___/ __ `/ __ \
     / /_/ / /_/ / /_/ / /_(__  ) /_/ /  / /_/ / /_/ /
    /_.___/\____/\____/\__/____/\__/_/   \__,_/ .___/
                                             /_/
EOF
    echo -e "${NO_COLOR}"

    echo -e "arch bootstrap script"
    echo -e "repo: https://github.com/mesalilac/arch-bootstrap"

    if [[ "${USER}" != "testuser" ]]; then
        local PROMPT_MESSAGE="Press any key to continue... "

        # stop executing the script and wait for any key press
        read -rsn1 -p "${PROMPT_MESSAGE}" ; echo
    fi
}

function fn_setup {
    fn_log_info "Creating Directories"
    mkdir -pv ~/Downloads
    mkdir -pv ~/sources
    mkdir -pv ~/.local/
    mkdir -pv ~/.local/bin/
    mkdir -pv ~/.local/bin/app-images

    if [[ ! -f "/etc/pacman.conf.bak" ]]; then
        fn_log_info "Backing up /etc/pacman.conf"
        sudo cp /etc/pacman.conf /etc/pacman.conf.bak
    fi

    fn_log_info "Enabling multilib"
    # sudo sed -i "/\[multilib\]/,/Include/"'s/^#//' /etc/pacman.conf
    sudo echo -e "\n[multilib]\nInclude = /etc/pacman.d/mirrorlist\n" | sudo tee -a /etc/pacman.conf

    fn_log_info "Enabling parallel downloads"
    sudo sed -i "s/^#ParallelDownloads = 5/ParallelDownloads = 15/" /etc/pacman.conf
}

function fn_install_pacman_packages {
    sudo pacman -Syyu --noconfirm

    if [[ -z "${PACMAN_PACKAGES[*]}" ]]; then
        fn_log_error "Pacman packages list is empty"
        exit 1
    fi

    fn_log_info "Downloading pacman packages"
    sudo pacman -Syu --noconfirm --needed "${PACMAN_PACKAGES[@]}"

    fn_log_info "Changing default shell to zsh!"
    ZSH_PATH="$(command -v zsh)"
    echo "${ZSH_PATH}" | sudo tee -a /etc/shells
    chsh -s "${ZSH_PATH}"
}

function fn_install_aur_packages {
    # TODO: use paru
    fn_log_info "Installing yay (aur helper)"
    git clone https://aur.archlinux.org/yay.git /tmp/yay
    cd /tmp/yay
    makepkg -si

    if [[ -z "${AUR_PACKAGES[*]}" ]]; then
        fn_log_error "Aur packages list is empty"
        exit 1
    fi

    fn_log_info "Downloading aur packages"
    # THIS FAILED! ssmtp, smenu
    yay -S --noconfirm --sudoloop --needed "${AUR_PACKAGES[@]}"
}

function fn_dependency_check {
    fn_log_info "Checking dependencies..."
    fn_check_cmd "pipx"
    fn_check_cmd "cargo"
    fn_check_cmd "curl"
    fn_check_cmd "go"
    fn_check_cmd "yarn"
    fn_check_cmd "flatpak"
    fn_check_cmd "git"
}

function fn_restore_dotfiles {
    if [[ ! -d "${DOTFILES_DIR}" ]]; then
        git clone "${DOTFILES_REPO_URL}" "${DOTFILES_DIR}"
    fi
    cd "${DOTFILES_DIR}"
    ./restore
    cd "${HOME}"
}

function fn_systemctl {
    fn_log_info "Starting the power profiles daemon"
    sudo systemctl enable power-profiles-daemon.service

    fn_log_info "Starting the acpid daemon"
    sudo systemctl enable --now acpid

    fn_log_info "Starting the smartd daemon"
    sudo systemctl enable smartd.service --now
}

function fn_install_cargo_packages {
    fn_log_info "Installing rust"
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y

    fn_log_info "Installing cargo packages"
    cargo install stylua
    cargo install tree-sitter-cli
    cargo install --git https://github.com/mesalilac/cmus-rpc.git
    cargo install du-dust
    cargo install diesel_cli
    cargo install bat
    cargo install scout
    cargo install bacon
    cargo install ripgrep
    cargo install fd-find
    cargo install --features lsp --locked taplo-cli
    cargo install create-tauri-app --locked
    cargo install tauri-cli --version "^2.0.0" --locked
}

function fn_install_go_packages {
    fn_log_info "Installing hyprls"
    go install github.com/hyprland-community/hyprls/cmd/hyprls@latest
}

function fn_install_npm_packages {
    yarn global add @fsouza/prettierd
    yarn global add neovim
    yarn global add sass
    yarn global add bash-language-server
    yarn global add git-open
    yarn global add web-ext
}

function fn_install_pip_packages {
    pipx install discover-overlay
    pipx install identify
}

function fn_install_zsh_prompt {
    curl -sS https://starship.rs/install.sh | sh
}

function fn_install_flatpak_packages {
    flatpak install flathub com.stremio.Stremio
}

function fn_main {
    fn_print_banner
    fn_setup
    fn_install_pacman_packages
    fn_install_aur_packages
    fn_dependency_check
    fn_restore_dotfiles
    fn_systemctl
    fn_install_cargo_packages
    fn_install_go_packages
    fn_install_npm_packages
    fn_install_pip_packages
    fn_install_zsh_prompt
    fn_install_flatpak_packages
}

fn_main
