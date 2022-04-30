--[[
  Button    Spell
]]--
local buttons = {}
buttons["fireball"] = "1";
buttons["fire_blast"] = "2";
buttons["phoenix_flames"] = "3";
buttons["pyroblast"] = "4";
buttons["flamestrike"] = "5";
buttons["dragons_breath"] = "6";
buttons["rune_of_power"] = "7";
buttons["arcane_explosion"] = "8";
buttons["scorch"] = "8";

WowCyborg_PAUSE_KEYS = {
  "F2"
}

function RenderMultiTargetRotation()
  Hekili.DB.profile.toggles.mode.value = "aoe";
  
  if WowCyborg_INCOMBAT == false then
    return SetSpellRequest(nil);
  end

  return RenderRotation();
end

function RenderSingleTargetRotation()
  Hekili.DB.profile.toggles.mode.value = "single";
  
  if WowCyborg_INCOMBAT == false then
    return SetSpellRequest(nil);
  end

  return RenderRotation();
end


function RenderRotation()
  if UnitChannelInfo("player") ~= nil then
    return SetSpellRequest(nil);
  end

  local quaking = FindDebuff("player", "Quake");
  if quaking then
    return SetSpellRequest(nil);
  end

  local actionName = Hekili.GetQueue().Primary[1].actionName;
  button = buttons[actionName];
  WowCyborg_CURRENTATTACK = actionName;
  
  if button ~= nil then
    return SetSpellRequest(button);
  end
  
  return SetSpellRequest(nil);
end

print("Mage rotation loaded");