#!/usr/bin/env bash

# TODO: rewrite this script

set -euo pipefail

USER_ID="$(id -u)"
if [[ "${USER_ID}" -eq 0 ]]; then
    echo "Don't run this script as root..."
    exit 1
fi

. "include/colors.bash"
. "include/log.bash"
. "include/packages.bash"

DOTFILES_REPO_URL="https://github.com/mesalilac/dotfiles"
DOTFILES_DIR="${HOME}/.dotfiles"

function pause_execution {
    local PROMPT_MESSAGE="Press any key to continue... "

    # stop executing the script and wait for any key press
    read -rsn1 -p "${PROMPT_MESSAGE}" ; echo
}

# Main
# ____________________________________________________________

echo -e "$IGreen"
cat << "EOF"
    __                __       __
   / /_  ____  ____  / /______/ /__________ _____
  / __ \/ __ \/ __ \/ __/ ___/ __/ ___/ __ `/ __ \
 / /_/ / /_/ / /_/ / /_(__  ) /_/ /  / /_/ / /_/ /
/_.___/\____/\____/\__/____/\__/_/   \__,_/ .___/
                                         /_/
EOF
echo -e "$NO_COLOR"

echo -e "arch bootstrap script"
echo -e "repo: https://github.com/mesalilac/arch-bootstrap"

pause_execution

# -----------------------------------------------------------
log_info "Creating Directories"
mkdir -pv ~/Downloads
mkdir -pv ~/sources
mkdir -pv ~/.local/
mkdir -pv ~/.local/bin/
mkdir -pv ~/.local/bin/app-images
# -----------------------------------------------------------

# -----------------------------------------------------------
log_info "Enabling multilib"
sudo sed -i "/\[multilib\]/,/Include/"'s/^#//' /etc/pacman.conf

log_info "Enabling parallel downloads"
sudo sed -i "/^#ParallelDownloads/"'s/^#//' /etc/pacman.conf

sudo pacman -Syyu --noconfirm

# TODO: Check if PACMAN_PACKAGES array is empty or not set
log_info "Downloading pacman packages"
sudo pacman -Syu --noconfirm --needed "${PACMAN_PACKAGES[@]}"
# -----------------------------------------------------------

# -----------------------------------------------------------
log_info "Changing default shell to zsh!"
ZSH_PATH="$(command -v zsh)"
chsh -s "${ZSH_PATH}"
# -----------------------------------------------------------

# -----------------------------------------------------------
# TODO: use paru
log_info "Installing yay (aur helper)"
git clone https://aur.archlinux.org/yay.git /tmp/yay
cd /tmp/yay
makepkg -si
# -----------------------------------------------------------

# -----------------------------------------------------------
log_info "Downloading aur packages"
# THIS FAILED! ssmtp, smenu
yay -S --noconfirm --sudoloop --needed "${AUR_PACKAGES[@]}"
# -----------------------------------------------------------

# -----------------------------------------------------------
git clone "${DOTFILES_REPO_URL}" "${DOTFILES_DIR}"
cd "${DOTFILES_DIR}"
./restore
cd "${HOME}"
# -----------------------------------------------------------

# -----------------------------------------------------------
log_info "Starting the power profiles daemon"
sudo systemctl enable power-profiles-daemon.service
# -----------------------------------------------------------

# -----------------------------------------------------------
log_info "Starting the acpid daemon"
sudo systemctl enable --now acpid
# -----------------------------------------------------------

# -----------------------------------------------------------
log_info "Starting the smartd daemon"
sudo systemctl enable smartd.service --now
# -----------------------------------------------------------

# -----------------------------------------------------------
log_info "Installing vimv (bulk name files)"
git clone https://github.com/thameera/vimv.git
mv vimv/vimv ~/.local/bin/
chmod +x ~/.local/bin/vimv
# -----------------------------------------------------------

# -----------------------------------------------------------
log_info "Installing rust"
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y

export PATH="${HOME}/.cargo/bin:${PATH}"

# -----------------------------------------------------------

# -----------------------------------------------------------
log_info "Installing cargo packages"
# https://github.com/mozilla/sccache
cargo install sccache
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
# -----------------------------------------------------------

log_info "Installing hyprls"
go install github.com/hyprland-community/hyprls/cmd/hyprls@latest

# -----------------------------------------------------------

# yarn global add prettier
yarn global add @fsouza/prettierd
yarn global add neovim
yarn global add sass
yarn global add bash-language-server
yarn global add git-open

pipx install discover-overlay
pipx install identify

curl -sS https://starship.rs/install.sh | sh

if [[ ! -d "${HOME}/.tmux/plugins/tpm" ]] ; then
    mkdir -p "${HOME}/.tmux/plugins"
    git clone "https://github.com/tmux-plugins/tpm" "${HOME}/.tmux/plugins/tpm"
fi

flatpak install flathub com.stremio.Stremio

# -----------------------------------------------------------

# ____________________________________________________________
