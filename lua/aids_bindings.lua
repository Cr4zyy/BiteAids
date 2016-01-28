// lua\aids_bindings.lua
// - Dragon

local function GetUpValue(origfunc, name)

	local index = 1
	local foundValue = nil
	while true do
	
		local n, v = debug.getupvalue(origfunc, index)
		if not n then
			break
		end
		
		-- Find the highest index matching the name.
		if n == name then
			foundValue = v
		end
		
		index = index + 1
		
	end
	
	return foundValue
	
end


local origControlBindings = GetUpValue( BindingsUI_GetBindingsData,   "globalControlBindings" )
for i = 1, #origControlBindings do
    if origControlBindings[i] == "ToggleFlashlight" then
        table.insert(origControlBindings, i + 4, "ToggleBiteAid")
        table.insert(origControlBindings, i + 5, "input")
        table.insert(origControlBindings, i + 6, Locale.ResolveString("Toggle Bite Aid"))
        table.insert(origControlBindings, i + 7, "I")
    end    
end
ReplaceLocals(BindingsUI_GetBindingsData, { globalControlBindings = origControlBindings })

local defaults = GetUpValue( GetDefaultInputValue,   "defaults" )
table.insert(defaults, { "ToggleBiteAid", "I" })