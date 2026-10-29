#!/usr/bin/env bash
# Installs a glow theme into Ghostty, and optionally into Claude Code.
#
#   ./install.sh                       Til Glow, with its glow shader
#   ./install.sh clay-glow             Clay Glow instead
#   ./install.sh <theme> --no-glow     colours only, no shader
#   ./install.sh <theme> --claude-code also copy the matching Claude Code theme
#
# Safe to re-run, and to switch themes: the config block is replaced, not added twice.
set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
theme=til-glow
glow=1
claude=0
for arg in "$@"; do
  case "$arg" in
    --no-glow) glow=0 ;;
    --claude-code) claude=1 ;;
    -h|--help) sed -n '2,9p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    -*) echo "Unknown option: $arg (try --help)" >&2; exit 1 ;;
    *) theme="$arg" ;;
  esac
done

if [[ ! -f "$here/themes/$theme" ]]; then
  echo "No theme called $theme. Pick one of: $(ls "$here/themes" | tr '\n' ' ')" >&2
  exit 1
fi

ghostty_dir="${XDG_CONFIG_HOME:-$HOME/.config}/ghostty"
mkdir -p "$ghostty_dir/themes" "$ghostty_dir/shaders"
cp "$here/themes/$theme" "$ghostty_dir/themes/$theme"
cp "$here/shaders/$theme.glsl" "$ghostty_dir/shaders/$theme.glsl"
echo "Copied $theme and its shader to $ghostty_dir"

# Ghostty reads config.ghostty; older installs use a file named config.
if [[ -f "$ghostty_dir/config.ghostty" ]]; then
  config="$ghostty_dir/config.ghostty"
elif [[ -f "$ghostty_dir/config" ]]; then
  config="$ghostty_dir/config"
else
  config="$ghostty_dir/config.ghostty"
  touch "$config"
fi

# Drop any block an earlier run wrote, including the single-marker one
# the first version of this script used, then append a fresh one.
begin="# --- ghostty-glow-theme ---"
end="# --- end ghostty-glow-theme ---"
tmp="$(mktemp)"
awk -v begin="$begin" -v end="$end" '
  $0 == begin { skip = 1; next }
  skip && $0 == end { skip = 0; next }
  skip { next }
  $0 == "# --- til-glow ---" { legacy = 1; next }
  legacy && /^(# Later lines win|theme = til-glow$|custom-shader = shaders\/til-glow\.glsl$)/ { next }
  { legacy = 0; print }
' "$config" > "$tmp"
# Trim the blank lines a removed block leaves at the end.
sed -e :a -e '/^\n*$/{$d;N;ba' -e '}' "$tmp" > "$config"
rm -f "$tmp"
{
  printf '\n%s\n' "$begin"
  echo "# Later lines win, so this overrides any theme set above."
  echo "theme = $theme"
  if [[ $glow -eq 1 ]]; then
    echo "custom-shader = shaders/$theme.glsl"
  fi
  echo "$end"
} >> "$config"
echo "Set $config to use $theme"

if [[ $claude -eq 1 ]]; then
  mkdir -p "$HOME/.claude/themes"
  cp "$here/claude-code/$theme.json" "$HOME/.claude/themes/$theme.json"
  echo "Copied the Claude Code theme to ~/.claude/themes/$theme.json"
  echo "Turn it on with \"theme\": \"custom:$theme\" in ~/.claude/settings.json."
fi

echo "Reload Ghostty's config (Cmd+Shift+, on macOS) or open a new window."
