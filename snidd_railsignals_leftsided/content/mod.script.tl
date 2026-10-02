-- Redirects every track-snapped construction (signals) to the left-side wrapper script.
local WRAPPER = "snidd_railsignals_leftsided::/leftsided.script@updateFn"

local mod = {}

-- Makes a relative script reference ("x.script@updateFn") absolute, using the construction's own folder.
local function absoluteScriptRef(fileName : string, conName : string) : string
	if fileName:find("::", 1, true) ~= nil or fileName:sub(1, 1) == "/" then
		return fileName
	end
	local dir = conName:match("^(.*/)") or ""
	return dir .. fileName
end

mod.postRunFn = function(_captureParams : any, _configDict : {{string, string}}, _allModParams : {string : {string : integer}})
	for id, name in pairs(api.res.constructionRep.getAll(true)) do
		local con = api.res.constructionRep.get(id)
		local edgeObject = con.edgeObject
		local updateScript = con.updateScript
		if edgeObject ~= nil and edgeObject.snapToTrack and updateScript ~= nil and updateScript.fileName ~= "" then
			local originalParams = (updateScript.params or {}) as {string : any}
			if originalParams.leftsidedIgnore == true then
				debugPrint("[leftsided] skipped (leftsidedIgnore): ", name)
			else
				local original = absoluteScriptRef(updateScript.fileName, name)
				local ref = api.type.ScriptRef.new()
				ref.fileName = WRAPPER
				ref.params = { original = original, originalParams = originalParams }
				con.updateScript = ref
				debugPrint("[leftsided] wrapped ", name, " -> ", original)
			end
		end
	end
end

return mod
