#!/bin/sh
# Installs the mod into TF3's local mods folder: symlink by default, or a plain copy with --copy.
set -e
cd "$(dirname "$0")/.."
MOD=snidd_railsignals_leftsided
MODS_DIR="${TF3_MODS_DIR:-$(ls -d "$HOME"/Library/Application\ Support/Steam/userdata/*/3493540/local/mods | head -1)}"
[ -d "$MODS_DIR" ] || { echo "TF3 local mods folder not found; set TF3_MODS_DIR" >&2; exit 1; }
TARGET="$MODS_DIR/$MOD"
if [ -L "$TARGET" ]; then rm "$TARGET"; elif [ -e "$TARGET" ]; then rm -r "$TARGET"; fi
if [ "$1" = "--copy" ]; then
	cp -R "$PWD/$MOD" "$TARGET"
	echo "Copied $MOD -> $TARGET"
else
	ln -s "$PWD/$MOD" "$TARGET"
	echo "Linked $TARGET -> $PWD/$MOD"
fi
