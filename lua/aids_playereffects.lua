// lua\dm\AddGameStrings.lua
// - Dragon

local alienRanges = { }
local r, g, b, a, o = 0
r = 0
g = 1
b = 0
a = 1
o = 1

alienRanges["Parasite"] = 0.2
alienRanges["XenocideLeap"] = 0.2
alienRanges["SpitSpray"] = 5.3
alienRanges["BileBomb"] = 0.2
alienRanges["BabblerAbility"] = 0.2
alienRanges["Spores"] = 0.2
alienRanges["LerkUmbra"] = 17
alienRanges["SwipeBlink"] = 1.6
alienRanges["StabBlink"] = 1.9
alienRanges["Gore"] = 2.2 //This is a guess, its changed by viewangle...
alienRanges["BoneShield"] = 0.2
alienRanges["Metabolize"] = 0.2
alienRanges["DropStructureAbility"] = 0.2

Player.screenEffects.biteaid = Client.CreateScreenEffect("shaders/BiteAid.screenfx")
Player.screenEffects.biteaid:SetActive(false)

local biteAidEnabled = false
local function ToggleBiteAid(enabled)
    biteAidEnabled = enabled ~= "false"
	Shared.Message("Bite Aid - " .. ConditionalValue(biteAidEnabled, "Enabled", "Disabled"))
end
Event.Hook("Console_togglebiteaid", ToggleBiteAid)

local originalPlayerSendKeyEvent
originalPlayerSendKeyEvent = Class_ReplaceMethod("Player", "SendKeyEvent",
	function(self, key, down)
		local t = originalPlayerSendKeyEvent(self, key, down)
		if not t and down then
			if GetIsBinding(key, "ToggleBiteAid") then
				biteAidEnabled = not biteAidEnabled
			end
		end
		return t
	end
)

local originalAlienUpdateClientEffects
originalAlienUpdateClientEffects = Class_ReplaceMethod("Alien", "UpdateClientEffects",
	function(self, deltaTime, isLocal)
		originalAlienUpdateClientEffects(self, deltaTime, isLocal)
		local player = Client.GetLocalPlayer()
        if Player.screenEffects.biteaid and player then
			local ability = player:GetActiveWeapon()
			local range = 0
			if ability and ability:isa("Ability") then
				if alienRanges[ability:GetClassName()] then
					range = alienRanges[ability:GetClassName()]
				else
					range = ability:GetRange()
				end
			end
            Player.screenEffects.biteaid:SetActive(biteAidEnabled)
            Player.screenEffects.biteaid:SetParameter("abilityRange", range)
			Player.screenEffects.biteaid:SetParameter("r", r)
			Player.screenEffects.biteaid:SetParameter("g", g)
			Player.screenEffects.biteaid:SetParameter("b", b)
			Player.screenEffects.biteaid:SetParameter("opacityValue", o)
        end
    end
)

local function SetBiteAidOpacity(opacityValue)

	local opacity = tonumber(opacityValue)
	if IsNumber(opacity) and opacity >= 0 and opacity <= 1 then
		o = opacity
		Shared.Message("Bite Aid opacity value set at: " .. opacityValue)
	end
    
end

 Event.Hook("Console_setbiteaidopacity", SetBiteAidOpacity)
 
 local function SetBiteAidColors(r1, g1, b1, a1)
	
    if tonumber(r1) and tonumber(g1) and tonumber(b1) then
		r = Clamp(tonumber(r1) or 0 / 255, 0, 1)
		g = Clamp(tonumber(g1) or 0 / 255, 0, 1)
		b = Clamp(tonumber(b1) or 0 / 255, 0, 1)
		a = Clamp(tonumber(a1) or 0 / 255, 0, 1)
		Shared.Message(string.format("Bite aid colors set to (%s, %s, %s, %s)", ToString(r), ToString(g), ToString(b), ToString(a)))
    end
    
end

 Event.Hook("Console_setbiteaidcolors", SetBiteAidColors)