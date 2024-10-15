--[[
  Button    Spell
]]--
local buttons = {}
buttons["unstable_affliction"] = "1";
buttons["agony"] = "2";
buttons["corruption"] = "3";
buttons["malefic_rapture"] = "4";
buttons["seed_of_corruption"] = "5";
buttons["drain_soul"] = "6";
buttons["phantom_singularity"] = "6";
buttons["summon_darkglare"] = "7";
buttons["drain_life"] = "8";
buttons["blood_fury"] = "9";
buttons["shadow_bolt"] = "F+7";

WowCyborg_PAUSE_KEYS = {
  "LSHIFT",
  "NUMPAD2",
  "NUMPAD3",
  "NUMPAD4",
  "NUMPAD5",
  "F4",
  "F",
  "§"
}

function RenderMultiTargetRotation()
  return RenderSingleTargetRotation(true);
end

function RenderSingleTargetRotation(aoe)
  if aoe then
    Hekili.DB.profile.toggles.mode.value = "aoe";
  else
    Hekili.DB.profile.toggles.mode.value = "single";
  end

  if WowCyborg_INCOMBAT == false then
    return SetSpellRequest(nil);
  end

  local castingInfo = UnitChannelInfo("player");
  if castingInfo ~= nil then
    return SetSpellRequest(nil);
  end

  local actionName = GetHekiliQueue().Primary[1].actionName;

  WowCyborg_CURRENTATTACK = actionName;
  local button = buttons[actionName];
  
  if button ~= nil then
    return SetSpellRequest(button);
  end

  return SetSpellRequest(nil);
end

print("Affli lock rotation loaded");