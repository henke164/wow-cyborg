--[[
  Button    Spell
]]--
local buttons = {}
buttons["arcane_blast"] = "1";
buttons["arcane_missiles"] = "2";
buttons["ice_nova"] = "3";
buttons["arcane_barrage"] = "4";
buttons["blast_wave"] = "5";
buttons["nether_tempest"] = "6";
buttons["touch_of_the_magi"] = "7";
buttons["arcane_explosion"] = "F+5";
buttons["presence_of_mind"] = "F+1";
buttons["radiant_spark"] = "F+3";

WowCyborg_PAUSE_KEYS = {
  "F2",
  "§"
}

function RenderMultiTargetRotation()
  Hekili.DB.profile.toggles.mode.value = "aoe";
  return RenderRotation();
end

function RenderSingleTargetRotation()
  Hekili.DB.profile.toggles.mode.value = "single";
  return RenderRotation();
end


function RenderRotation()
  if IsCastableAtEnemyTarget("Arcane Blast", 0) == false then
    return SetSpellRequest(nil);
  end

  if UnitChannelInfo("player") ~= nil then
    return SetSpellRequest(nil);
  end

  local quaking = FindDebuff("player", "Quake");
  if quaking then
    return SetSpellRequest(nil);
  end

  local actionName = GetHekiliQueue().Primary[1].actionName;
  button = buttons[actionName];
  WowCyborg_CURRENTATTACK = actionName;
  
  if button ~= nil then
    return SetSpellRequest(button);
  end
  
  return SetSpellRequest(nil);
end

print("Mage rotation loaded");