# Glow themes for Ghostty

Two dark themes for [Ghostty](https://ghostty.org) that share one idea: the
text stays quiet, one accent colour leads, and an optional shader makes that
accent glow softly, and nothing else. The rule is "one thing glows at rest:
glow means live".

| Theme | Background | Accent | What it's built on |
| --- | --- | --- | --- |
| **Til Glow** (`til-glow`) | Navy `#0B1320` | Light blue `#8CC2F5` | Slate greys with a blue accent |
| **Clay Glow** (`clay-glow`) | Near-black `#141413` | Clay orange `#D97757` | Inspired by the colours Anthropic uses for Claude |

Each theme ships as three files:

| File | What it is |
| --- | --- |
| `themes/<theme>` | The colours: background, foreground, cursor, selection and the 16-colour palette |
| `shaders/<theme>.glsl` | The glow, tuned to that theme's accent |
| `claude-code/<theme>.json` | A matching [Claude Code](https://claude.com/claude-code) theme (optional) |

`install.sh` copies a theme into place and points your Ghostty config at it.

## Install

```sh
git clone https://github.com/Jmeza081/ghostty-glow-theme.git
cd ghostty-glow-theme
./install.sh              # Til Glow
./install.sh clay-glow    # or Clay Glow
```

Then reload Ghostty's config (`Cmd+Shift+,` on macOS) or open a new window.

Options, after the theme name:

- `--no-glow` installs the colours without the shader.
- `--claude-code` also installs the matching Claude Code theme. To turn it
  on, set `"theme": "custom:<theme>"` in `~/.claude/settings.json`.

To switch themes, run the script again with the other name. It replaces its
own block in your config rather than adding a second one.

### By hand

1. Copy `themes/<theme>` to `~/.config/ghostty/themes/<theme>`.
2. Copy `shaders/<theme>.glsl` to `~/.config/ghostty/shaders/<theme>.glsl`.
3. Add these lines to `~/.config/ghostty/config.ghostty` (or `config` on
   older installs):

   ```
   theme = clay-glow
   custom-shader = shaders/clay-glow.glsl
   ```

## Optional: the frosted window

Both themes were designed with these settings: slightly see-through, blurred,
with the title bar in the background colour.

```
background-opacity = 0.94
background-blur = 20
macos-titlebar-style = transparent
window-padding-x = 10
window-padding-y = 8
```

## Notes

- **Dark only.** Neither theme has a light variant.
- **What glows.** Each theme puts its accent in the terminal's blue and cyan
  slots, so whatever your shell draws in blue (prompt, paths, branch names)
  is what glows. In Clay Glow those slots are orange; the red and amber
  either side of it in hue stay flat.
- **Til Glow's amber glow depends on Claude Code.** It lights up only Claude
  Code's `warning` colour (`#F5B94A`, used for "auto mode on"), so you'll
  rarely see it without the matching Claude Code theme.
- **Shaders stack.** If you already have a `custom-shader`, both run, in
  order. Remove the other one if the result looks muddy.
- **If the glow doesn't show,** the shader probably failed to compile.
  Ghostty logs shader errors and doesn't report them as config errors.
- **To tune the glow,** edit `RADIUS` and `STRENGTH` at the top of the shader.
  Clay Glow also has `INTENSITY`, which sets it 25% dimmer than Til Glow.
- **Not an official Anthropic theme.** Clay Glow borrows the colours and
  nothing else.

## Uninstall

Delete the block between `# --- ghostty-glow-theme ---` and
`# --- end ghostty-glow-theme ---` in your Ghostty config. Then remove the
theme's files from `~/.config/ghostty/themes/`, `~/.config/ghostty/shaders/`
and, if you installed it, `~/.claude/themes/`.

## Licence

[MIT](LICENSE)
