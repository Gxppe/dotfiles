#!/bin/bash
# =============================================================================
#  backup.sh — Actualizar dotfiles desde la config actual
#  Ejecutar en el PC fuente cuando hagas cambios en los configs
# =============================================================================

set -euo pipefail

GREEN='\033[0;32m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

ok()      { echo -e "${GREEN}[OK]${NC}    $*"; }
info()    { echo -e "${BLUE}[INFO]${NC}  $*"; }
section() { echo -e "\n${CYAN}━━━ $* ━━━${NC}"; }

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
H="$HOME"

section "Actualizando dotfiles desde ~/.config/"

rsync -a --delete "$H/.config/hypr/hyprland.conf"  "$DOTFILES/hyprland/.config/hypr/hyprland.conf"
rsync -a --delete "$H/.config/hypr/monitors.conf"  "$DOTFILES/hyprland/.config/hypr/monitors.conf"
rsync -a --delete "$H/.config/hypr/workspaces.conf" "$DOTFILES/hyprland/.config/hypr/workspaces.conf"
ok "hyprland"

rsync -a --delete "$H/.config/waybar/"   "$DOTFILES/waybar/.config/waybar/"
ok "waybar"

rsync -a --delete "$H/.config/kitty/"   "$DOTFILES/kitty/.config/kitty/"
ok "kitty"

rsync -a --delete "$H/.config/alacritty/" "$DOTFILES/alacritty/.config/alacritty/"
ok "alacritty"

rsync -a --delete "$H/.config/rofi/"    "$DOTFILES/rofi/.config/rofi/"
ok "rofi"

rsync -a --delete "$H/.config/mako/"    "$DOTFILES/mako/.config/mako/"
ok "mako"

rsync -a --delete "$H/.config/swaync/"  "$DOTFILES/swaync/.config/swaync/"
ok "swaync"

rsync -a --delete "$H/.config/swaylock/" "$DOTFILES/swaylock/.config/swaylock/"
ok "swaylock"

rsync -a --delete "$H/.config/swayosd/" "$DOTFILES/swayosd/.config/swayosd/"
ok "swayosd"

rsync -a --delete "$H/.config/wlogout/" "$DOTFILES/wlogout/.config/wlogout/"
ok "wlogout"

rsync -a --delete --exclude='.git' "$H/.config/nvim/" "$DOTFILES/nvim/.config/nvim/"
ok "nvim"

rsync -a --delete "$H/.config/cava/"    "$DOTFILES/cava/.config/cava/"
ok "cava"

rsync -a --delete "$H/.config/gammastep/" "$DOTFILES/gammastep/.config/gammastep/"
ok "gammastep"

rsync -a --delete "$H/.config/yazi/"    "$DOTFILES/yazi/.config/yazi/"
ok "yazi"

# fastfetch: solo archivos de texto (excluir GIFs binarios grandes)
rsync -a --delete --include="*.json" --include="*.jsonc" --include="*.txt" \
    --exclude="*.gif" --exclude="*.png" --exclude="*.jpg" \
    "$H/.config/fastfetch/" "$DOTFILES/fastfetch/.config/fastfetch/"
ok "fastfetch"

rsync -a --delete "$H/.config/btop/"    "$DOTFILES/btop/.config/btop/"
ok "btop"

rsync -a --delete "$H/.config/zathura/" "$DOTFILES/zathura/.config/zathura/"
ok "zathura"

rsync -a --delete "$H/.config/atuin/"   "$DOTFILES/atuin/.config/atuin/"
ok "atuin"

rsync -a --delete "$H/.config/espanso/" "$DOTFILES/espanso/.config/espanso/"
ok "espanso"

section "Actualizando dotfiles del home"

cp "$H/.bashrc"       "$DOTFILES/bash/.bashrc"
cp "$H/.bash_profile" "$DOTFILES/bash/.bash_profile"
cp "$H/.gitconfig"    "$DOTFILES/git/.gitconfig"
cp "$H/.npmrc"        "$DOTFILES/misc/.npmrc" 2>/dev/null || true
cp "$H/.latexmkrc"    "$DOTFILES/misc/.latexmkrc" 2>/dev/null || true
ok "home dotfiles"

section "Exportando lista de pip packages"
pip list --user --format=freeze 2>/dev/null > "$DOTFILES/misc/pip-requirements.txt" || true
ok "pip-requirements.txt"

section "Exportando lista de npm globales"
npm list -g --depth=0 2>/dev/null | tail -n +2 | sed 's/[├└─ ]*//g' | sed 's/@.*//' | grep -v '^$' > "$DOTFILES/misc/npm-globals.txt" || true
ok "npm-globals.txt"

echo ""
echo -e "${GREEN}Backup completo. Haz commit y push para guardar los cambios.${NC}"
echo "  cd $DOTFILES && git add -A && git commit -m 'chore: sync dotfiles' && git push"
