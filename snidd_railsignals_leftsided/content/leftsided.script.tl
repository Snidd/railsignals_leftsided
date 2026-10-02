-- Calls a signal's original updateFn and mirrors its models to the left side of the track.
-- X runs along the track, Y is lateral (vanilla signals sit at -Y, the right side), Z is up.

local record Closure
	-- Absolute reference to the wrapped script, "path.script@fn.path"
	original : string
	-- The wrapped script's own closure params
	originalParams : table
end

local type OriginalUpdateFn = function(captureParams : any, params : any, closure : any) : table

local G = _G as {string : any}
local cache : {string : OriginalUpdateFn} = {}

-- Walks a dotted lua path ("updateFn" or "a.b") inside a loaded script module.
local function lookup(module : table, luaPath : string) : any
	local value : any = module
	for key in luaPath:gmatch("[^%.]+") do
		if type(value) ~= "table" then
			return nil
		end
		value = (value as table)[key]
	end
	return value
end

-- Loads a script by extension-less path. Supports both module scripts (return a table)
-- and legacy scripts (define a global `function data()` returning a table).
local function loadModule(path : string) : table
	for _, ext in ipairs({ ".lua", ".tl" }) do
		local savedData = G.data
		G.data = false
		local ok, ret = pcall(ug_require, path .. ext)
		local legacyData = G.data
		G.data = savedData
		if ok then
			if type(ret) == "table" then
				return ret as table
			elseif type(legacyData) == "function" then
				return (legacyData as function() : table)()
			end
		end
	end
	error("[leftsided] could not load script " .. path)
end

local function resolveOriginal(ref : string) : OriginalUpdateFn
	local fn = cache[ref]
	if fn == nil then
		local path, luaPath = ref:match("^(.-)@(.+)$")
		if path == nil then
			error("[leftsided] malformed script reference " .. ref)
		end
		fn = lookup(loadModule(path), luaPath) as OriginalUpdateFn
		if fn == nil then
			error("[leftsided] " .. luaPath .. " not found in " .. path)
		end
		cache[ref] = fn
	end
	return fn
end

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

function leftsided.updateFn(captureParams : any, params : any, closure : Closure) : table
	local result = resolveOriginal(closure.original)(captureParams, params, closure.originalParams)
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
