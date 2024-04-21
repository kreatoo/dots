#!/bin/sh
# TODO: font check
# TODO: remove before linking
# TODO: confirmation prompt


cyan='\033[0;36m'
yellow='\033[0;33m'
reset='\033[0m'

info() {
    printf "${cyan}info${reset}: $@"
}

warn() {
    printf "${yellow}warn${reset}: $1 not installed, config may not work properly"
}

info "Kreato's Dotfiles setup script"

command -v sway >/dev/null 2>&1 && info "sway installed" || warn "sway"
command -v dunst >/dev/null 2>&1 && info "dunst installed" || warn "dunst"
command -v nvim  >/dev/null 2>&1 && info "neovim installed" || warn "neovim"
command -v waybar  >/dev/null 2>&1 && info "waybar installed" || warn "waybar"
command -v rofi  >/dev/null 2>&1 && info "rofi installed" || warn "rofi" 

cd main

mkdir -p "$HOME/.config/dunst"

for i in *; do
    ln -s "$PWD/$i" "$HOME"/.config/"$i"
done

ln -s "$HOME/.cache/wal/dunstrc" "$HOME/.config/dunst/dunstrc"
