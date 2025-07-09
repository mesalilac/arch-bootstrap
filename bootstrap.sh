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

export PATH="${HOME}/.cargo/bin:${PATH}"

function log_info() {
    echo -e "${On_Green}${BBlack}[$(date +'%Y-%m-%d %H:%M:%S') INFO ]${NO_COLOR} $1"
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

    local PROMPT_MESSAGE="Press any key to continue... "

    # stop executing the script and wait for any key press
    read -rsn1 -p "${PROMPT_MESSAGE}" ; echo
}

function fn_setup {
    log_info "Creating Directories"
    mkdir -pv ~/Downloads
    mkdir -pv ~/sources
    mkdir -pv ~/.local/
    mkdir -pv ~/.local/bin/
    mkdir -pv ~/.local/bin/app-images

    log_info "Enabling multilib"
    sudo sed -i "/\[multilib\]/,/Include/"'s/^#//' /etc/pacman.conf

    log_info "Enabling parallel downloads"
    sudo sed -i "/^#ParallelDownloads/"'s/^#//' /etc/pacman.conf
}

function fn_install_pacman_packages {
    sudo pacman -Syyu --noconfirm

    # TODO: Check if PACMAN_PACKAGES array is empty or not set
    log_info "Downloading pacman packages"
    sudo pacman -Syu --noconfirm --needed "${PACMAN_PACKAGES[@]}"

    log_info "Changing default shell to zsh!"
    ZSH_PATH="$(command -v zsh)"
    chsh -s "${ZSH_PATH}"
}

function fn_install_aur_packages {
    # TODO: use paru
    log_info "Installing yay (aur helper)"
    git clone https://aur.archlinux.org/yay.git /tmp/yay
    cd /tmp/yay
    makepkg -si

    log_info "Downloading aur packages"
    # THIS FAILED! ssmtp, smenu
    yay -S --noconfirm --sudoloop --needed "${AUR_PACKAGES[@]}"
}

function fn_restore_dotfiles {
    git clone "${DOTFILES_REPO_URL}" "${DOTFILES_DIR}"
    cd "${DOTFILES_DIR}"
    ./restore
    cd "${HOME}"
}

function fn_systemctl {
    log_info "Starting the power profiles daemon"
    sudo systemctl enable power-profiles-daemon.service

    log_info "Starting the acpid daemon"
    sudo systemctl enable --now acpid

    log_info "Starting the smartd daemon"
    sudo systemctl enable smartd.service --now
}

function fn_install_cargo_packages {
    log_info "Installing rust"
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y

    log_info "Installing cargo packages"
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
    log_info "Installing hyprls"
    go install github.com/hyprland-community/hyprls/cmd/hyprls@latest
}

function fn_install_npm_packages {
    yarn global add @fsouza/prettierd
    yarn global add neovim
    yarn global add sass
    yarn global add bash-language-server
    yarn global add git-open
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
