# xkb-cyrillic-phonetic-extended

XKB keyboard layout `cyrex` (extended Cyrillic phonetic), packaged as an
xkeyboard-config **extension** for libxkbcommon ≥ 1.13 / Wayland.
X11 (Xorg server) is intentionally not supported.

## Layout of the repo

- `symbols/cyrex` — the layout. `default` map `cyrex` (common Cyrillic) plus
  variants `rus`, `ukr`, `bel` that `include "cyrex(cyrex)"` and override only
  the keys where that language's letters go to the base level (displaced
  letters move to levels 3/4). Each key line ends with a comment listing the
  characters; keep it in sync when editing.
- `rules/evdev.xml` — a complete `xkbConfigRegistry` document with one
  `<layout>` and a `<variantList>` for rus/ukr/bel; libxkbregistry merges it
  into the system list. Keep each `<description>` identical to the matching
  `name[Group1]` in `symbols/cyrex`, and the README variants table in sync.
- `Makefile` — `check`, `install`/`uninstall` (system-wide into
  `$(pkg-config --variable=xkb_unversioned_extensions_path xkbcommon)/cyrex`),
  `install-user`/`uninstall-user` (`~/.config/xkb`).
- `packaging/arch/PKGBUILD` — `-git` package, delegates to `make install`.
- `layout.png` — screenshot used by README; regenerate by hand when keys change.

## Rules

- Never modify files owned by `xkeyboard-config` (`/usr/share/X11/xkb`,
  `/usr/share/xkeyboard-config-2`). That was the old `install/` approach and it
  was removed on purpose.
- No custom `rules/evdev` file is needed: the stock `* = pc+%l%(v)` rule resolves
  `symbols/cyrex`. Add `rules/evdev.post` only if an XKB *option* is introduced.
- Install logic lives in the `Makefile`; packaging files only call it.

## Verify changes

```sh
make check   # xmllint on evdev.xml + compile every map and assert a key per map
```

`xkbcli compile-keymap` exits 0 even for an unknown layout or variant, so
`check` greps the compiled keymap instead of trusting the exit code. In zsh,
build xkbcli arguments as arrays: `${v:+--variant $v}` is passed as ONE word.

Test the installed-package path without installing:

```sh
cd packaging/arch && makepkg -f   # builds from GitHub HEAD, not the work tree
XKB_CONFIG_UNVERSIONED_EXTENSIONS_PATH=$PWD/pkg/*/usr/share/xkeyboard-config.d \
  xkbcli list | grep -A3 "layout: 'cyrex'"
```

The installed package (`/usr/share/xkeyboard-config.d/cyrex`) is also on the
default include path; in ad-hoc tests pass `--include .` first so the work tree
wins over it.
