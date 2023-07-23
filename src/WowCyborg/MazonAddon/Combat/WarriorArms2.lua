--[[
  Button    Spell
]]--
local buttons = {}
buttons["warbreaker"] = "1";
buttons["colossus_smash"] = "1";
buttons["rend"] = "2";
buttons["mortal_strike"] = "3";
buttons["execute"] = "4";
buttons["overpower"] = "5";
buttons["slam"] = "6";
buttons["whirlwind"] = "7";
buttons["cleave"] = "8";
buttons["skullsplitter"] = "8";
buttons["thunder_clap"] = "9";
buttons["sweeping_strikes"] = "F+4";
buttons["thunderous_roar"] = "F+8";
buttons["wrecking_throw"] = "0";

WowCyborg_PAUSE_KEYS = {
  "LSHIFT",
  "NUMPAD2",
  "NUMPAD3",
  "NUMPAD4",
  "NUMPAD5",
  "F",
  "§"
}

function RenderMultiTargetRotation()
  if WowCyborg_INCOMBAT == false then
    return SetSpellRequest(nil);
  end

  local castingInfo = UnitChannelInfo("player");
  if castingInfo ~= nil then
    return SetSpellRequest(nil);
  end

  local actionName = GetHekiliQueue().Cooldowns[1].actionName;
  WowCyborg_CURRENTATTACK = actionName;
  local button = buttons[actionName];
  
  if button ~= nil then
    local replaced = string.gsub(actionName, "_", " ");
    if (IsCastable(replaced, 0)) then
      return SetSpellRequest(button);
    end
  end
  
  return RenderSingleTargetRotation(true);
end

function RenderSingleTargetRotation()
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

print("Warr rotation loaded");