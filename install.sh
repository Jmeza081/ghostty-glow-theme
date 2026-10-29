#!/usr/bin/env bash
# Installs Til Glow into Ghostty, and optionally into Claude Code.
#
#   ./install.sh                 theme + glow shader
#   ./install.sh --no-glow       theme only
#   ./install.sh --claude-code   also copy the Claude Code theme
#
# Safe to re-run: files are overwritten, the config block is only added once.
set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
glow=1
claude=0
for arg in "$@"; do
  case "$arg" in
    --no-glow) glow=0 ;;
    --claude-code) claude=1 ;;
    -h|--help) sed -n '2,8p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *) echo "Unknown option: $arg (try --help)" >&2; exit 1 ;;
  esac
done

ghostty_dir="${XDG_CONFIG_HOME:-$HOME/.config}/ghostty"
mkdir -p "$ghostty_dir/themes" "$ghostty_dir/shaders"
cp "$here/themes/til-glow" "$ghostty_dir/themes/til-glow"
cp "$here/shaders/til-glow.glsl" "$ghostty_dir/shaders/til-glow.glsl"
echo "Copied the theme and shader to $ghostty_dir"

# Ghostty reads config.ghostty; older installs use a file named config.
if [[ -f "$ghostty_dir/config.ghostty" ]]; then
  config="$ghostty_dir/config.ghostty"
elif [[ -f "$ghostty_dir/config" ]]; then
  config="$ghostty_dir/config"
else
  config="$ghostty_dir/config.ghostty"
  touch "$config"
fi

marker="# --- til-glow ---"
if grep -qF "$marker" "$config"; then
  echo "$config already has the til-glow block; left it alone."
else
  {
    printf '\n%s\n' "$marker"
    echo "# Later lines win, so this overrides any theme set above."
    echo "theme = til-glow"
    if [[ $glow -eq 1 ]]; then
      echo "custom-shader = shaders/til-glow.glsl"
    fi
  } >> "$config"
  echo "Added the til-glow block to $config"
fi

if [[ $claude -eq 1 ]]; then
  mkdir -p "$HOME/.claude/themes"
  cp "$here/claude-code/til-glow.json" "$HOME/.claude/themes/til-glow.json"
  echo "Copied the Claude Code theme to ~/.claude/themes/til-glow.json"
  echo "Turn it on with \"theme\": \"custom:til-glow\" in ~/.claude/settings.json."
fi

echo "Reload Ghostty's config (Cmd+Shift+, on macOS) or open a new window."
