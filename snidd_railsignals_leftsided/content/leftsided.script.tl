-- Calls a signal's original updateFn and mirrors its models to the left side of the track.
-- X runs along the track, Y is lateral (vanilla signals sit at -Y, the right side), Z is up.
local util = ug_require "::/scripts/util.tl" as Util

local record Closure
	-- Absolute reference to the wrapped script, "path.script@fn.path"
	original : string
	-- The wrapped script's own closure params
	originalParams : table
end

local type OriginalUpdateFn = function(closureParams : table, params : table) : table

-- Mirrors a column-major 4x4 transform across the track centreline: M * T with M = diag(1, -1, 1, 1).
local function mirrorY(transf : {number}) : {number}
	local t : {number} = {}
	for i = 1, 16 do
		t[i] = transf[i]
	end
	for _, i in ipairs({ 2, 6, 10, 14 }) do
		t[i] = -t[i]
	end
	return t
end

local leftsided = {}

-- Called by the engine as fn(closureParams, constructionParams), see ::/scripts/construction/construction.script.tl.
function leftsided.updateFn(closure : Closure, params : table) : table
	local original = util.useFn(closure.original) as OriginalUpdateFn
	if original == nil then
		error("[leftsided] could not load " .. closure.original)
	end
	local result = original(closure.originalParams, params)
	if result == nil or result.signal == nil then
		return result
	end
	for _, edgeModel in ipairs((result.edgeModels or {}) as {table}) do
		local model = edgeModel.model as table
		if model ~= nil and model.transf ~= nil then
			model.transf = mirrorY(model.transf as {number})
		end
	end
	return result
end

return leftsided
