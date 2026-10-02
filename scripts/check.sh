#!/bin/sh
# Type-checks the mod's Teal scripts against the game's own definitions.
# Needs Lua 5.4 (the tl CLI breaks on 5.5) and tl: brew install lua@5.4 luarocks && luarocks install --local tl
set -e
cd "$(dirname "$0")/.."
LUA="${LUA:-$(brew --prefix lua@5.4)/bin/lua5.4}"
TL_SHARE="${TL_SHARE:-$(ls -d "$HOME"/.luarocks/share/lua/5.* | tail -1)}"
export LUA_PATH="$TL_SHARE/?.lua;$TL_SHARE/?/init.lua;;"
for f in snidd_railsignals_leftsided/content/*.tl; do
	"$LUA" "$HOME/.luarocks/bin/tl" check "$f"
done
