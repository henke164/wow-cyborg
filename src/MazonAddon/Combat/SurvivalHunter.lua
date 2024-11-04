
--[[
NAME: Survival Hunter
ICON: ability_hunter_camouflage
]]--
local buttons = {}
buttons["kill_command"] = "1";
buttons["raptor_strike"] = "2";
buttons["wildfire_bomb"] = "3";
buttons["explosive_shot"] = "4";
buttons["butchery"] = "5";
buttons["kill_shot"] = "6";
buttons["coordinated_assault"] = "7";

WowCyborg_PAUSE_KEYS = {
}

function IsMelee()
  return IsSpellInRange("Muzzle", "target") == 1;
end

function RenderMultiTargetRotation()
end

function RenderSingleTargetRotation()
  if WowCyborg_INCOMBAT == false then
    WowCyborg_CURRENTATTACK = "-";
    return SetSpellRequest(nil);
  end

  if UnitCanAttack("player", "target") == false then
    WowCyborg_CURRENTATTACK = "-";
    return SetSpellRequest(nil);
  end

  local actionName = GetHekiliQueue().Primary[1].actionName;
  local button = buttons[actionName];
  WowCyborg_CURRENTATTACK = actionName;
  if button ~= nil then
    WowCyborg_CURRENTATTACK = actionName;
    return SetSpellRequest(button);
  end
  
  return SetSpellRequest(nil);
end

print("Survival Hunter rotation loaded");
            