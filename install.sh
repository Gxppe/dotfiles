#!/bin/bash
# =============================================================================
#  install.sh — Fedora 43 Hyprland Desktop Setup
#  Basado en la configuración de bonpepe
#  Ejecutar en una instalación limpia de Fedora 43
# =============================================================================

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

info()    { echo -e "${BLUE}[INFO]${NC}  $*"; }
ok()      { echo -e "${GREEN}[OK]${NC}    $*"; }
warn()    { echo -e "${YELLOW}[WARN]${NC}  $*"; }
section() { echo -e "\n${CYAN}━━━ $* ━━━${NC}"; }
error()   { echo -e "${RED}[ERROR]${NC} $*"; exit 1; }

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
USER_HOME="$HOME"

# Verificar que no se ejecuta como root
[[ "$EUID" -eq 0 ]] && error "No ejecutes este script como root. Usa un usuario normal con sudo."

# =============================================================================
section "1 · Actualización del sistema"
# =============================================================================
info "Actualizando sistema..."
sudo dnf update -y
ok "Sistema actualizado"

# =============================================================================
section "2 · Repositorios"
# =============================================================================

# RPM Fusion
info "Añadiendo RPM Fusion..."
sudo dnf install -y \
    "https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm" \
    "https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm"
ok "RPM Fusion añadido"

# COPR: SwayNotificationCenter
info "Añadiendo COPR erikreider/SwayNotificationCenter..."
sudo dnf copr enable -y erikreider/SwayNotificationCenter

# COPR: nwg-shell (nwg-displays, nwg-look)
info "Añadiendo COPR tofik/nwg-shell..."
sudo dnf copr enable -y tofik/nwg-shell

# Docker CE
info "Añadiendo repositorio Docker CE..."
sudo dnf config-manager addrepo \
    --from-repofile=https://download.docker.com/linux/fedora/docker-ce.repo 2>/dev/null || \
sudo dnf install -y dnf-plugins-core && \
sudo dnf config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo

# VS Code
info "Añadiendo repositorio VS Code..."
sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
sudo sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo'

# Tailscale
info "Añadiendo repositorio Tailscale..."
sudo dnf config-manager addrepo \
    --from-repofile=https://pkgs.tailscale.com/stable/fedora/tailscale.repo 2>/dev/null || \
sudo dnf install -y 'dnf-command(config-manager)' && \
sudo dnf config-manager --add-repo https://pkgs.tailscale.com/stable/fedora/tailscale.repo

ok "Repositorios añadidos"

# =============================================================================
section "3 · Paquetes del sistema"
# =============================================================================

info "Instalando paquetes base del sistema..."
sudo dnf install -y \
    kernel-devel kernel-headers \
    git curl wget \
    stow \
    btop htop fastfetch \
    bat fzf zoxide atuin \
    ripgrep fd-find \
    neovim tmux \
    python3-pip python3-devel \
    nodejs npm \
    golang \
    protobuf-compiler \
    perl-Image-ExifTool \
    nmap \
    snapd
ok "Paquetes base instalados"

# Rust/Cargo
info "Instalando Rust..."
if ! command -v rustup &>/dev/null; then
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    source "$HOME/.cargo/env"
fi
ok "Rust instalado"

info "Instalando herramientas de desarrollo..."
sudo dnf install -y \
    gcc gcc-c++ make cmake \
    glib2-devel gtk4-devel \
    wayland-devel libxkbcommon-devel \
    glfw glfw-devel glm-devel \
    mesa-libEGL-devel \
    libxml2-devel libxslt-devel \
    mesa-libGL-devel
ok "Herramientas de desarrollo instaladas"

# =============================================================================
section "4 · Entorno de escritorio Hyprland"
# =============================================================================

info "Instalando Hyprland y ecosistema..."
sudo dnf install -y \
    hyprland \
    hyprlock \
    hypridle \
    hyprpicker \
    xdg-desktop-portal-hyprland \
    waybar \
    alacritty \
    kitty \
    rofi-wayland \
    mako \
    swaylock \
    wlogout \
    SwayNotificationCenter \
    swww \
    hyprland-guiutils \
    nwg-displays \
    nwg-look \
    qt5ct \
    qt6ct \
    gammastep \
    espanso \
    cava \
    yazi \
    zathura \
    zathura-pdf-mupdf \
    wl-clipboard \
    cliphist \
    grim \
    slurp \
    pamixer \
    playerctl \
    brightnessctl \
    network-manager-applet \
    blueman \
    pavucontrol
ok "Entorno Hyprland instalado"

# SwayOSD (puede no estar en repos, compilar si es necesario)
info "Intentando instalar swayosd..."
sudo dnf install -y swayosd 2>/dev/null || {
    warn "swayosd no encontrado en repos. Compilando desde fuente..."
    if command -v cargo &>/dev/null; then
        cargo install swayosd 2>/dev/null || warn "No se pudo compilar swayosd"
    fi
}

# =============================================================================
section "5 · Media y productividad"
# =============================================================================

info "Instalando paquetes de media..."
sudo dnf install -y \
    mpv \
    obs-studio \
    aria2 \
    yt-dlp \
    intel-media-driver \
    libva-utils

info "Instalando LaTeX (proceso largo ~2-5 min)..."
sudo dnf install -y texlive-scheme-full || warn "texlive falló, instalar manualmente"

info "Instalando herramientas gráficas..."
sudo dnf install -y krita

ok "Media y productividad instalados"

# =============================================================================
section "6 · VS Code"
# =============================================================================
sudo dnf install -y code
ok "VS Code instalado"

# =============================================================================
section "7 · Steam y juegos (RPM Fusion)"
# =============================================================================
info "Instalando Steam..."
sudo dnf install -y \
    steam \
    steam-devices
ok "Steam instalado"

# =============================================================================
section "8 · VirtualBox (RPM Fusion)"
# =============================================================================
info "Instalando VirtualBox..."
sudo dnf install -y \
    VirtualBox \
    akmod-VirtualBox
sudo usermod -aG vboxusers "$USER"
ok "VirtualBox instalado"

# =============================================================================
section "9 · Docker"
# =============================================================================
info "Instalando Docker CE..."
sudo dnf install -y \
    docker-ce \
    docker-ce-cli \
    containerd.io \
    docker-buildx-plugin \
    docker-compose-plugin
sudo systemctl enable --now docker
sudo usermod -aG docker "$USER"
ok "Docker instalado"

# =============================================================================
section "10 · Virtualización (KVM/QEMU)"
# =============================================================================
info "Instalando virtualización KVM..."
sudo dnf install -y @virtualization
sudo systemctl enable --now libvirtd
sudo usermod -aG libvirt "$USER"
ok "KVM instalado"

# =============================================================================
section "11 · Podman y Distrobox"
# =============================================================================
info "Instalando Podman y Distrobox..."
sudo dnf install -y podman distrobox
ok "Podman y Distrobox instalados"

# =============================================================================
section "12 · Tailscale"
# =============================================================================
info "Instalando Tailscale..."
sudo dnf install -y tailscale
sudo systemctl enable --now tailscaled
ok "Tailscale instalado. Ejecuta 'sudo tailscale up' para conectar."

# =============================================================================
section "13 · NVIDIA (GTX 1660 Ti)"
# =============================================================================
info "Instalando drivers NVIDIA..."
sudo dnf install -y \
    akmod-nvidia \
    xorg-x11-drv-nvidia \
    xorg-x11-drv-nvidia-cuda \
    libva-nvidia-driver

# Forzar modeset en el kernel (necesario para Wayland/Hyprland)
if ! grep -q "nvidia-drm.modeset=1" /etc/default/grub 2>/dev/null; then
    sudo sed -i 's/GRUB_CMDLINE_LINUX="\(.*\)"/GRUB_CMDLINE_LINUX="\1 nvidia-drm.modeset=1 nvidia.NVreg_PreserveVideoMemoryAllocations=1"/' /etc/default/grub
    sudo grub2-mkconfig -o /boot/grub2/grub.cfg
    info "Parámetros de kernel NVIDIA añadidos. Reinicia para aplicar."
fi

# Habilitar servicio de suspensión NVIDIA
sudo systemctl enable nvidia-suspend nvidia-hibernate nvidia-resume 2>/dev/null || true

ok "Drivers NVIDIA instalados"

# =============================================================================
section "14 · Flatpak"
# =============================================================================
info "Configurando Flatpak..."
sudo dnf install -y flatpak
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
info "Instalando apps de Flatpak..."
flatpak install -y flathub \
    com.discordapp.Discord \
    com.spotify.Client \
    org.freecad.FreeCAD \
    org.gimp.GIMP \
    sh.cider.Cider \
    sh.ppy.osu
ok "Flatpak configurado"

# =============================================================================
section "15 · Herramientas adicionales (npm, cargo, go)"
# =============================================================================

info "Configurando npm global directory..."
mkdir -p "$HOME/.npm-global"
npm config set prefix "$HOME/.npm-global"
export PATH="$HOME/.npm-global/bin:$PATH"

info "Instalando paquetes npm globales..."
npm install -g \
    @anthropic-ai/claude-code \
    prettier
ok "npm globals instalados"

info "Instalando paquetes cargo..."
source "$HOME/.cargo/env" 2>/dev/null || true
cargo install ripdrag 2>/dev/null || warn "ripdrag falló"
ok "Cargo packages instalados"

info "Instalando paquetes go..."
export PATH="$PATH:$HOME/go/bin"
go install github.com/charmbracelet/glow@latest 2>/dev/null || warn "glow falló"
go install google.golang.org/protobuf/cmd/protoc-gen-go@latest 2>/dev/null || warn "protoc-gen-go falló"
go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest 2>/dev/null || warn "protoc-gen-go-grpc falló"
ok "Go tools instalados"

# Atuin (shell history mejorado)
info "Instalando Atuin..."
if ! command -v atuin &>/dev/null; then
    curl --proto '=https' --tlsv1.2 -LsSf https://setup.atuin.sh | sh || \
    cargo install atuin 2>/dev/null || warn "Atuin falló"
fi
ok "Atuin instalado"

# =============================================================================
section "16 · JetBrainsMono Nerd Font"
# =============================================================================
info "Instalando JetBrainsMono Nerd Font..."
FONTS_DIR="$HOME/.local/share/fonts"
mkdir -p "$FONTS_DIR"

if ! fc-list | grep -qi "JetBrainsMono Nerd"; then
    FONT_URL="https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.tar.xz"
    TMP_FONTS=$(mktemp -d)
    curl -L "$FONT_URL" -o "$TMP_FONTS/JetBrainsMono.tar.xz"
    tar -xf "$TMP_FONTS/JetBrainsMono.tar.xz" -C "$TMP_FONTS"
    cp "$TMP_FONTS"/*.ttf "$FONTS_DIR/" 2>/dev/null || cp "$TMP_FONTS"/**/*.ttf "$FONTS_DIR/" 2>/dev/null || true
    fc-cache -f
    rm -rf "$TMP_FONTS"
    ok "JetBrainsMono Nerd Font instalada"
else
    ok "JetBrainsMono Nerd Font ya estaba instalada"
fi

# Papirus icon theme
info "Instalando tema de iconos Papirus..."
sudo dnf install -y papirus-icon-theme
ok "Papirus instalado"

# Catppuccin cursor
info "Instalando cursor Catppuccin Mocha Dark..."
CURSOR_DIR="$HOME/.local/share/icons"
mkdir -p "$CURSOR_DIR"
if [ ! -d "$CURSOR_DIR/catppuccin-mocha-dark-cursors" ]; then
    TMP_CUR=$(mktemp -d)
    curl -L "https://github.com/catppuccin/cursors/releases/latest/download/catppuccin-mocha-dark-cursors.zip" \
         -o "$TMP_CUR/cursor.zip" 2>/dev/null && \
    unzip -q "$TMP_CUR/cursor.zip" -d "$CURSOR_DIR/" 2>/dev/null && \
    ok "Cursor Catppuccin instalado" || warn "No se pudo instalar el cursor automáticamente"
    rm -rf "$TMP_CUR"
fi

# =============================================================================
section "17 · Zoom"
# =============================================================================
warn "Zoom debe instalarse manualmente:"
echo "  Descarga: https://zoom.us/download (Linux, .rpm 64-bit)"
echo "  Instala: sudo dnf install ./zoom_x86_64.rpm"

# =============================================================================
section "18 · Telegram"
# =============================================================================
info "Instalando Telegram..."
sudo dnf install -y telegram-desktop 2>/dev/null || \
    flatpak install -y flathub org.telegram.desktop 2>/dev/null || \
    warn "Telegram no encontrado, instalar manualmente"

# =============================================================================
section "19 · Herramientas de red y seguridad"
# =============================================================================
info "Instalando herramientas de red..."
sudo dnf install -y \
    nmap \
    tigervnc \
    wayvnc
ok "Herramientas de red instaladas"

# =============================================================================
section "20 · Despliegue de dotfiles"
# =============================================================================
info "Desplegando dotfiles con stow..."

# Crear directorios necesarios
mkdir -p "$HOME/.config"
mkdir -p "$HOME/Pictures/Wallpapers"
mkdir -p "$HOME/Pictures/Screenshots"

# Backup de configs existentes
BACKUP_DIR="$HOME/.config-backup-$(date +%Y%m%d-%H%M%S)"
info "Haciendo backup de configs existentes en $BACKUP_DIR..."
mkdir -p "$BACKUP_DIR"

# Lista de paquetes stow a desplegar
STOW_PACKAGES=(
    "hyprland"
    "zsh"
    "bash"
    "git"
    "misc"
    "tmux"
    "waybar"
    "kitty"
    "alacritty"
    "rofi"
    "mako"
    "swaync"
    "swaylock"
    "swayosd"
    "wlogout"
    "nvim"
    "cava"
    "gammastep"
    "yazi"
    "fastfetch"
    "btop"
    "zathura"
    "atuin"
    "espanso"
)

for pkg in "${STOW_PACKAGES[@]}"; do
    if [ -d "$DOTFILES/$pkg" ]; then
        # Mover archivos conflictivos al backup
        stow --dir="$DOTFILES" --target="$HOME" --simulate "$pkg" 2>/dev/null || {
            warn "Conflicto en $pkg — moviendo al backup"
            # Identificar y mover conflictos
            stow --dir="$DOTFILES" --target="$HOME" --simulate "$pkg" 2>&1 | \
                grep "existing target" | awk '{print $NF}' | while read conflict; do
                mkdir -p "$BACKUP_DIR/$(dirname "$conflict")"
                mv "$HOME/$conflict" "$BACKUP_DIR/$conflict" 2>/dev/null || true
            done
        }
        stow --dir="$DOTFILES" --target="$HOME" --restow "$pkg"
        ok "  $pkg desplegado"
    fi
done

ok "Dotfiles desplegados"

# =============================================================================
section "21 · Configuración post-instalación"
# =============================================================================

# Habilitar Docker
sudo systemctl enable --now docker 2>/dev/null || true

# Habilitar Tailscale
sudo systemctl enable --now tailscaled 2>/dev/null || true

# Configurar npm global (por si no está en .bashrc todavía)
grep -q "npm-global" "$HOME/.bashrc" 2>/dev/null || \
    echo 'export PATH="$HOME/.npm-global/bin:$PATH"' >> "$HOME/.bashrc"

# Snap (socket)
sudo systemctl enable --now snapd.socket 2>/dev/null || true
sudo ln -s /var/lib/snapd/snap /snap 2>/dev/null || true

# Crear directorio de wallpapers (recordatorio)
mkdir -p "$HOME/Pictures/Wallpapers"
mkdir -p "$HOME/Pictures/Screenshots"

# =============================================================================
echo ""
echo -e "${GREEN}╔════════════════════════════���═════════════════════════╗${NC}"
echo -e "${GREEN}║           INSTALACIÓN COMPLETADA                    ║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${YELLOW}Pasos manuales pendientes:${NC}"
echo "  1. Copiar wallpapers a ~/Pictures/Wallpapers/"
echo "  2. Instalar Zoom: https://zoom.us/download"
echo "  3. Instalar NVIDIA (si aplica): sudo dnf install akmod-nvidia xorg-x11-drv-nvidia"
echo "  4. Conectar Tailscale: sudo tailscale up"
echo "  5. Iniciar sesión en Docker Hub (si necesitas): docker login"
echo "  6. Configurar Git: git config --global user.email 'tu@email.com'"
echo "  7. Instalar Burp Suite desde https://portswigger.net/burp"
echo "  8. Instalar Postman desde https://www.postman.com/downloads/"
echo "  9. Generar SSH key: ssh-keygen -t ed25519 -C 'tu@email.com'"
echo "  10. Reinstalar pip packages: pip install --user -r $DOTFILES/misc/pip-requirements.txt"
echo ""
echo -e "${YELLOW}REINICIA el sistema para aplicar:${NC}"
echo "  - Grupos de usuario (docker, libvirt, vboxusers)"
echo "  - Módulos del kernel (akmod-VirtualBox, akmod-nvidia)"
echo ""
echo -e "${CYAN}¡Listo! Inicia Hyprland con: Hyprland${NC}"
