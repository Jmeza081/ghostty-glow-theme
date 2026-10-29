# Til Glow for Ghostty

A dark navy theme for [Ghostty](https://ghostty.org). Slate greys carry the
text and a light-blue accent is the primary colour. An optional shader makes
that accent glow softly, and nothing else. Its rule is "one thing glows at
rest: glow means live".

| File | What it is |
| --- | --- |
| `themes/til-glow` | The colours: background, foreground, cursor, selection and the 16-colour palette |
| `shaders/til-glow.glsl` | The glow. A blue bloom on the accent, plus a faint amber one on Claude Code's warning colour |
| `claude-code/til-glow.json` | A matching [Claude Code](https://claude.com/claude-code) theme (optional) |
| `install.sh` | Copies the files into place and points your Ghostty config at them |

## Install

```sh
git clone https://github.com/Jmeza081/ghostty-glow-theme.git
cd ghostty-glow-theme
./install.sh
```

Then reload Ghostty's config (`Cmd+Shift+,` on macOS) or open a new window.

Options:

- `./install.sh --no-glow` installs the colours without the shader.
- `./install.sh --claude-code` also installs the Claude Code theme. To turn it
  on, set `"theme": "custom:til-glow"` in `~/.claude/settings.json`.

You can run the script again safely. It overwrites the theme files and adds
its config block only once.

### By hand

1. Copy `themes/til-glow` to `~/.config/ghostty/themes/til-glow`.
2. Copy `shaders/til-glow.glsl` to `~/.config/ghostty/shaders/til-glow.glsl`.
3. Add these lines to `~/.config/ghostty/config.ghostty` (or `config` on
   older installs):

   ```
   theme = til-glow
   custom-shader = shaders/til-glow.glsl
   ```

## Optional: the frosted window

The theme was designed with these settings: slightly see-through, blurred,
with the title bar in the background colour.

```
background-opacity = 0.94
background-blur = 20
macos-titlebar-style = transparent
window-padding-x = 10
window-padding-y = 8
```

## Notes

- **Dark only.** There is no light variant.
- **The amber glow depends on Claude Code.** It only lights up Claude Code's
  `warning` colour (`#F5B94A`, used for "auto mode on"), so you'll rarely see
  it without the Claude Code theme. The shell's own amber (`#E0B25C`) stays
  flat on purpose.
- **Shaders stack.** If you already have a `custom-shader`, both run, in
  order. Remove the other one if the result looks muddy.
- **If the glow doesn't show,** the shader probably failed to compile.
  Ghostty logs shader errors and doesn't report them as config errors.
- **To tune the glow,** edit `RADIUS` and `STRENGTH` at the top of
  `shaders/til-glow.glsl`.

## Uninstall

Delete the `# --- til-glow ---` block from your Ghostty config, then remove
`~/.config/ghostty/themes/til-glow`, `~/.config/ghostty/shaders/til-glow.glsl`
and, if you installed it, `~/.claude/themes/til-glow.json`.
