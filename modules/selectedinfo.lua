local Prefs = import('/lua/user/prefs.lua')
local options = Prefs.GetFromCurrentProfile('options')

local selectionOverlay = {
        key = 'selection',
        Label = "<LOC map_options_0006>Selection",
        Pref = 'range_RenderSelected',
        Type = 3,
        Tooltip = "overlay_selection",
}

SelectedInfoOn = true
SelectedOverlayOn = true

if options.gui_enhanced_unitview == 0 then 
   SelectedInfoOn = false
end
if options.gui_enhanced_unitrings == 0 then 
   SelectedOverlayOn = false
end

function GetUnitRolloverInfo(unit)
	local info = {}

	info.blueprintId = unit:GetBlueprint().BlueprintId

	local econData = unit:GetEconData()

	info.energyConsumed = econData["energyConsumed"]
	info.energyProduced = econData["energyProduced"]
	info.energyRequested = econData["energyRequested"]
	info.massConsumed = econData["massConsumed"]
	info.massProduced = econData["massProduced"]
	info.massRequested = econData["massRequested"]

	info.entityId = unit:GetEntityId()

	info.maxHealth = unit:GetMaxHealth()
	info.health = unit:GetHealth()
	info.fuelRatio = unit:GetFuelRatio()
	info.workProgress = unit:GetWorkProgress()

# Modification by Brute51 for compatibility with Nomads
# Nomads is abusing the shield ratio thing for the capacitor. GAZ_UI should not look at the shield ratio when the unit has a capacitor.
# TODO: remove this once a better method to display the capacitor state is implemented.
# original:	info.shieldRatio = unit:GetShieldRatio()

        if unit:GetBlueprint().Capacitor then
            info.shieldRatio = 0
        else
            info.shieldRatio = unit:GetShieldRatio()
        end

# end modification

	if unit:GetFocus() then
		info.focus = GetUnitRolloverInfo(unit:GetFocus())
	end
   
	local killStat = unit:GetStat('KILLS')
	info.kills = killStat.Value

	local missileInfo = unit:GetMissileInfo()
	info.nukeSiloBuildCount = missileInfo.nukeSiloBuildCount 
	info.nukeSiloMaxStorageCount = missileInfo.nukeSiloMaxStorageCount
	info.nukeSiloStorageCount = missileInfo.nukeSiloStorageCount
	info.tacticalSiloBuildCount = missileInfo.tacticalSiloBuildCount
	info.tacticalSiloMaxStorageCount = missileInfo.tacticalSiloMaxStorageCount
	info.tacticalSiloStorageCount = missileInfo.tacticalSiloStorageCount

	info.customName = unit:GetCustomName(unit)
	info.userUnit = unit
	info.armyIndex = unit:GetArmy() - 1
--   info.teamColor="ffe80a0a"

	return info
end

function ToggleOn()
   if SelectedInfoOn then
      SelectedInfoOn = false
   else
      SelectedInfoOn = true
   end
end

function ToggleOverlayOn()
   if SelectedOverlayOn then
      SelectedOverlayOn = false
      DeactivateSingleRangeOverlay()
   else
      SelectedOverlayOn = true
      local selUnits = GetSelectedUnits()
      if selUnits and table.getn(selUnits) == 1 then
         ActivateSingleRangeOverlay()
      end         
   end
end

function ActivateSingleRangeOverlay()
   ConExecute('range_RenderSelected true')
end

function DeactivateSingleRangeOverlay()
   local info = selectionOverlay
   local pref = Prefs.GetFromCurrentProfile(info.Pref)
   if pref == nil then
      pref = true
   end
   ConExecute(info.Pref..' '..tostring(pref))
end
