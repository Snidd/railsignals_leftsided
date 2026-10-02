-- Teal type-check config. Run: scripts/check.sh
local tf3 = os.getenv("TF3_DIR") or (os.getenv("HOME") .. "/Library/Application Support/Steam/steamapps/common/Transport Fever 3/")
return {
	include_dir = {
		tf3 .. "api/tealdef",
		tf3 .. "base/tealdef",
		tf3 .. "vscode-template",
	},
	global_env_def = "all_def",
}
