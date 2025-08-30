--[[
NAME: Warrior Fury
ICON: ability_warrior_innerrage
]]--
local buttons = {}
buttons["rampage"] = "1";
buttons["recklessness"] = "2";
buttons["execute"] = "3";
buttons["bloodthirst"] = "4";
buttons["bloodbath"] = "4";
buttons["raging_blow"] = "5";
buttons["crushing_blow"] = "5";
buttons["whirlwind"] = "6";
buttons["odyns_fury"] = "7";
buttons["sweeping_strikes"] = "F+4";
buttons["onslaught"] = "8";
buttons["thunder_clap"] = "0";

WowCyborg_PAUSE_KEYS = {
  "LSHIFT",
  "R",
  "NUMPAD2",
  "NUMPAD3",
  "NUMPAD4",
  "NUMPAD5",
  "NUMPAD7",
  "NUMPAD8",
  "NUMPAD9",
  "F",
  "§"
}

function IsMelee()
  return IsSpellInRange("Rampage", "target") and UnitCanAttack("player", "target") == true;
end

function RenderMultiTargetRotation()
  return RenderSingleTargetRotation(true);
end

function RenderSingleTargetRotation()
  if IsMelee() ~= true then
    WowCyborg_CURRENTATTACK = "Idle";
    return SetSpellRequest(nil);
  end

  local hp = GetHealthPercentage("target");
  if hp <= 0 then
    WowCyborg_CURRENTATTACK = "-";
    return SetSpellRequest(nil);
  end

  local castingInfo = UnitChannelInfo("player");
  if castingInfo ~= nil then
    WowCyborg_CURRENTATTACK = "Channeling";
    return SetSpellRequest(nil);
  end

  local health = GetHealthPercentage("player");
  if health < 70 and IsCastableAtEnemyTarget("Impending Victory", 10) then
    WowCyborg_CURRENTATTACK = "Impending Victory";
    return SetSpellRequest("X");
  end
  
  local actionName = GetHekiliQueue().Primary[1].actionName;

  WowCyborg_CURRENTATTACK = actionName;
  local button = buttons[actionName];
  
  if button ~= nil then
    return SetSpellRequest(button);
  end

  WowCyborg_CURRENTATTACK = "-";
  return SetSpellRequest(nil);
end

print("Warr rotation loaded");