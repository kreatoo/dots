#!/bin/sh
cyan='\033[0;36m'
red='\033[0;31m'
yellow='\033[0;33m'
reset='\033[0m'

info() {
    if [ -n "$2" ]; then
       printf "${cyan}info${reset}: $@"
    else
       printf "${cyan}info${reset}: $@\n"
    fi
}

warn() {
    printf "${yellow}warn${reset}: $1 is not installed, config may not work properly\n"
}

err() {
    printf "${red}error${reset}: $@\n"
    exit 1
}


warnerr() {
    if [ "$KREATO_SKIP_DEPENDENCIES" = "1" ]; then
	warn "$1"
    else
	err "$1 is not installed, config may not work properly. Set 'KREATO_SKIP_DEPENDENCIES' to '1' to convert this into a warning."
    fi
}

down() {
    if [ -n "$KREATO_DOWNLOADER" ]; then
	$KREATO_DOWNLOADER "$1"
    else
	if ! command -v wget > /dev/null 2>&1; then
	    err "wget not installed, cannot install font"
	fi
	
	wget "$1"
    fi
}

lnk() {
    if [ "$REMOVEBEFOREHAND" = "1" ]; then
       info "Removing $2"
       rm -rf "$2"
    fi

    if [ -e "$2" ]; then
       err "$2 already exists in the filesystem, cannot continue. Run with -r to override this."
    fi

    ln -s "$1" "$2"
}

info "This will install Kreato's dotfiles using symbolic links. You CANNOT change the path of the dotfiles repository after continuing. Do you want to proceed? (Y/n) " " "

read -r proceed

case $proceed in
    "y" | "Y" | "yes" | "Yes")
       info "Proceeding..."
    ;;
    *)
       info "Closing."
       exit
    ;;
esac

if [ "$1" = "-r" ]; then
    export REMOVEBEFOREHAND="1"
else
    export REMOVEBEFOREHAND="0"
fi


info "Kreato's Dotfiles setup script"

info "Checking dependencies"

for i in sway swaylock brightnessctl nvim waybar node rofi wal jq ffmpeg grimshot ags bun sass; do
    (command -v $i >/dev/null 2>&1 && info "$i installed") || warnerr "$i"
done

info "Do you want to enable work configurations? If not Kreato or in doubt, please say n. (Y/n) " ""

read -r workyn

case $workyn in
    "y" | "Y" | "yes" | "Yes")
       info "Proceeding..."
       info "Checking work-specific dependencies"
       for i in swaysome; do
	    (command -v $i >/dev/null 2>&1 && info "$i installed") || warnerr "$i"
       done
       echo "include ~/.config/sway/config.d/work/*.conf" > main/sway/config.d/enable-work.conf
    ;;
    *)
       info "Skipping..."
       echo "include ~/.config/sway/config.d/home/*.conf" > main/sway/config.d/enable-work.conf
    ;;
esac

if ! (fc-list | grep "NotoSans Nerd Font,NotoSans NF:style=Regular" >/dev/null 2>&1); then
    warn "NotoSans Nerd Font"
    info "Do you want to install the font? (Y/n) " " "
    read -r ynfont
    case $ynfont in
	"y" | "Y" | "yes" | "Yes")
	    info "Proceeding..."
	    mkdir -p "$HOME"/.fonts
	    cd "$HOME"/.fonts
	    KREATO_DOWNLOADER=$KREATO_DOWNLOADER down "https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/Noto/Sans/NotoSansNerdFont-Regular.ttf"
	    fc-cache -f
	    cd - >/dev/null 2>&1
	    info "Fonts installed."
	    ;;
	*)
	    info "Skipping..."
	;;
    esac
	
fi

info "Installing main dotfiles"

cd main || err "please enter source directory before continuing"


for i in *; do
    lnk "$PWD/$i" "$HOME"/.config/"$i"
done

mkdir -p "$HOME/.cache/ags"
lnk "$HOME/.cache/wal/ags-options.json" "$HOME/.cache/ags/options.json"
cd ..

info "Installing scripts"

cd scripts/home/.local/bin || err "unknown error"

mkdir -p "$HOME"/.local/bin

for i in *; do
    lnk "$PWD/$i" "$HOME"/.local/bin/"$i"
done

mkdir -p "$HOME/.local/share/warp-terminal/themes"
lnk "$HOME/.cache/wal/colors-warp.yml" "$HOME/.local/share/warp-terminal/themes/colors-pywal.yml"

info "Do you want to fix screenshare? (Requires swayfx to be currently running) (Y/n) " " "
read -r FIX_SCREENSHARE

if [ "$FIX_SCREENSHARE" = "y" ] || [ "$FIX_SCREENSHARE" = "Y" ] && [ "$(pgrep -x "sway" > /dev/null)" ]; then
    info "Fixing screenshare"
    mkdir $HOME/.config/xdg-desktop-portal
    echo $'[preferred]\ndefault=gtk\norg.freedesktop.impl.portal.ScreenCast=wlr' > $HOME/.config/xdg-desktop-portal/sway-portals.conf
    export XDG_CURRENT_DESKTOP=sway
    systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP
    dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP
    systemctl --user restart pipewire wireplumber xdg-desktop-portal xdg-desktop-portal-wlr
fi
