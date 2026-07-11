#!/usr/bin/env bash

WALLPAPER_DIR="$HOME/Pictures/Wallpapers"
CACHE_DIR="$HOME/.cache/rofi/wallpaper-thumbs"

mkdir -p "$CACHE_DIR"

is_video() {
  local f="${1,,}"
  [[ "$f" == *.mp4 || "$f" == *.mkv || "$f" == *.webm || "$f" == *.avi || "$f" == *.mov ]]
}

generate_thumbnail() {
  local source="$1"
  local dest="$2"

  if [[ ! -f "$dest" ]] || [[ "$source" -nt "$dest" ]]; then
    if is_video "$source"; then
      ffmpeg -y -i "$source" -vframes 1 -ss 00:00:01 \
        -vf "scale=300:200:force_original_aspect_ratio=increase,crop=300:200" \
        "$dest" 2>/dev/null
    elif [[ "${source,,}" == *.gif ]]; then
      magick "${source}[0]" -resize 300x200^ -gravity center -extent 300x200 "$dest" 2>/dev/null
    else
      magick "$source" -resize 300x200^ -gravity center -extent 300x200 "$dest" 2>/dev/null
    fi
  fi
}

mapfile -t images < <(find "$WALLPAPER_DIR" -maxdepth 1 -type f \
  \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.gif" \
     -o -iname "*.mp4" -o -iname "*.mkv" -o -iname "*.webm" \
     -o -iname "*.avi" -o -iname "*.mov" \) |
  sort)

entries=()
for img in "${images[@]}"; do
  filename=$(basename "$img")
  thumbnail="$CACHE_DIR/${filename%.*}.png"
  generate_thumbnail "$img" "$thumbnail" &
  entries+=("$filename\0icon\x1f$thumbnail")
done

wait

selected_name=$(printf '%b\n' "${entries[@]}" | rofi -dmenu -i -p "🖼 " \
  -theme ~/.config/rofi/wallpaper.rasi \
  -show-icons)

[ -z "$selected_name" ] && exit 0

selected_wallpaper=$(printf '%s\n' "${images[@]}" | grep "/$selected_name$")

if is_video "$selected_wallpaper"; then
  pkill swww-daemon 2>/dev/null
  pkill mpvpaper 2>/dev/null
  mpvpaper -o "no-audio loop" '*' "$selected_wallpaper" &
elif [[ "${selected_wallpaper,,}" == *.gif ]]; then
  pkill mpvpaper 2>/dev/null
  swww-daemon 2>/dev/null &
  sleep 0.3
  swww img "$selected_wallpaper" --transition-type none
else
  pkill mpvpaper 2>/dev/null
  swww-daemon 2>/dev/null &
  sleep 0.3
  swww img "$selected_wallpaper" --transition-type any --transition-fps 60 --transition-duration 1.5
fi

echo "$selected_wallpaper" >"$HOME/.cache/current_wallpaper"
