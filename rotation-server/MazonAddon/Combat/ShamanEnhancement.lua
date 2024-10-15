--[[
  flametongue = "2"
  frostbrand = "4"
  stormstrike = "5"
  lavaLash = "7"
  crashLightning = "8"
  lightningShield = "9"
]]--
local buttons = {}
buttons["stormstrike"] = "1";
buttons["flame_shock"] = "2";
buttons["lava_lash"] = "3";
buttons["lightning_bolt"] = "4";
buttons["crash_lightning"] = "5";
buttons["chain_lightning"] = "6";
buttons["frost_shock"] = "7";
WowCyborg_PAUSE_KEYS = {
}

function IsMelee()
  return IsSpellInRange("Lava Lash", "target") == 1;
end

-- Multi target
function RenderMultiTargetRotation()
  return RenderSingleTargetRotation();
end

-- Single target
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
  
  WowCyborg_CURRENTATTACK = "-";
  return SetSpellRequest(nil);
end

print("Enhancement shaman rotation loaded");