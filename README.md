# dotfiles

Configuración personal de escritorio — Fedora 43 + Hyprland + Catppuccin Mocha.

## Stack

| Categoría | Herramientas |
|---|---|
| GPU | NVIDIA GTX 1660 Ti (akmod-nvidia + modeset) |
| WM | Hyprland |
| Bar | Waybar |
| Terminal | Kitty · Alacritty |
| Launcher | Rofi |
| Editor | Neovim (LazyVim) |
| Notificaciones | SwayNC |
| Lock | Hyprlock · Swaylock |
| Shell | Bash (fzf · zoxide · atuin · fastfetch) |
| Theme | Catppuccin Mocha en todo |

---

## Instalación en PC nuevo (Fedora 43 limpio)

### 1. Clonar el repo

```bash
git clone git@github.com:Gxppe/dotfiles.git ~/dotfiles
```

> Si todavía no tienes SSH key en el nuevo PC, usa HTTPS:
> ```bash
> git clone https://github.com/Gxppe/dotfiles.git ~/dotfiles
> ```

### 2. Ejecutar el instalador

```bash
cd ~/dotfiles
bash install.sh
```

El script hace todo automáticamente:
- Actualiza el sistema
- Añade repos (RPM Fusion, Docker, VS Code, Tailscale, COPRs)
- Instala todos los paquetes dnf
- Instala Flatpaks (Discord, Spotify, GIMP, FreeCAD, osu!, Cider)
- Despliega los dotfiles con GNU Stow
- Instala fuentes, cursor Catppuccin, iconos Papirus
- Instala npm globals, cargo y go tools

### 3. Reiniciar

```bash
sudo reboot
```

> Necesario para aplicar grupos de usuario (docker, libvirt, vboxusers) y módulos del kernel.

### 4. Pasos manuales post-instalación

```bash
# Conectar Tailscale
sudo tailscale up

# Copiar wallpapers
cp -r /ruta/origen/Wallpapers ~/Pictures/Wallpapers

# Configurar SSH key nueva
ssh-keygen -t ed25519 -C "giuseppe.queirolo@usm.cl"
cat ~/.ssh/id_ed25519.pub  # añadir en github.com/settings/keys

# Instalar pip packages
pip install --user -r ~/dotfiles/misc/pip-requirements.txt

# NVIDIA GTX 1660 Ti — el install.sh lo hace automáticamente.
# Si necesitas reinstalar manualmente:
sudo dnf install akmod-nvidia xorg-x11-drv-nvidia xorg-x11-drv-nvidia-cuda libva-nvidia-driver
# Tras reiniciar, akmod compila el módulo del kernel (~2-5 min en el primer boot)

# Zoom (descarga manual)
# https://zoom.us/download → Linux → .rpm 64-bit
sudo dnf install ./zoom_x86_64.rpm
```

---

## Actualizar dotfiles desde el PC fuente

Después de hacer cambios en los configs:

```bash
bash ~/dotfiles/backup.sh
cd ~/dotfiles && git add -A && git commit -m "chore: sync dotfiles" && git push
```

## Estructura

```
dotfiles/
├── install.sh          ← instalador completo
├── backup.sh           ← sincroniza configs → dotfiles
│
├── hyprland/           → ~/.config/hypr/
├── waybar/             → ~/.config/waybar/
├── kitty/              → ~/.config/kitty/
├── alacritty/          → ~/.config/alacritty/
├── rofi/               → ~/.config/rofi/
├── swaync/             → ~/.config/swaync/
├── swaylock/           → ~/.config/swaylock/
├── swayosd/            → ~/.config/swayosd/
├── wlogout/            → ~/.config/wlogout/
├── mako/               → ~/.config/mako/
├── nvim/               → ~/.config/nvim/
├── cava/               → ~/.config/cava/
├── btop/               → ~/.config/btop/
├── yazi/               → ~/.config/yazi/
├── zathura/            → ~/.config/zathura/
├── fastfetch/          → ~/.config/fastfetch/
├── gammastep/          → ~/.config/gammastep/
├── atuin/              → ~/.config/atuin/
├── espanso/            → ~/.config/espanso/
│
├── bash/               → ~/.bashrc · ~/.bash_profile
├── git/                → ~/.gitconfig
├── tmux/               → ~/.tmux.conf
├── zsh/                → ~/.zshrc
└── misc/               → ~/.npmrc · ~/.latexmkrc
```

> Cada paquete es compatible con [GNU Stow](https://www.gnu.org/software/stow/) — las rutas son relativas a `$HOME`.
