--[[
  Button    Spell
  Ctrl+1    Macro: /target player
  Ctrl+2    Macro: /target party1
  Ctrl+3    Macro: /target party2
  Ctrl+4    Macro: /target party3
  Ctrl+5    Macro: /target party4
  1         Regrowth
  2         Lifebloom
  3         Rejuvenation
  4         Swiftmend
  5         Wild Growth
]]--

local regrowth = 4;
local lifebloom = 5;
local rejuvenation = 6;
local swiftmend = 7;
local cenarionWard = 8;
local adaptiveSwarm = 9;
local overgrowth = "F+4";
local cancelCast = "CTRL+4";

WowCyborg_PAUSE_KEYS = {
  "F2",
  "R",
  "F3",
  "NUMPAD3",
  "NUMPAD4",
  "NUMPAD5",
  "NUMPAD6",
  "NUMPAD7",
  "NUMPAD8",
  "NUMPAD9",
  "F10",
  "LSHIFT"
}

function RenderMultiTargetRotation()
  return RenderSingleTargetRotation(true);
end

function RenderSingleTargetRotation(attack)
  local casting = UnitChannelInfo("player");

  if casting == "Shackles of Malediction" then
    WowCyborg_CURRENTATTACK = "Shackles of Malediction";
    return SetSpellRequest(nil);
  end

  if UnitChannelInfo("player") ~= nil then
    WowCyborg_CURRENTATTACK = "-";
    return SetSpellRequest(nil);
  end
  
  local travel = FindBuff("player", "Ghost Wolf");
  if travel ~= nil then
    WowCyborg_CURRENTATTACK = "-";
    return SetSpellRequest(nil);
  end

  local speed = GetUnitSpeed("player");

  local target = "target";
  if UnitCanAttack("player", "target") == true or UnitName("target") == nil then
    target = "player";
  end

  local riptideBuff = FindBuff("target", "Riptide");
  local riptideCharges = GetSpellCharges("Riptide");

  if hp > 95 then
    WowCyborg_CURRENTATTACK = "-";
    return SetSpellRequest(nil);
  end

  if IsCastableAtFriendlyUnit(target, "Unleash Life", 0) then
    WowCyborg_CURRENTATTACK = "Unleash Life";
    return SetSpellRequest(riptide);
  end

  if riptideBuff == nil and 
    IsCastableAtFriendlyUnit(target, "Riptide", 0) and 
    riptideCharges > 0 then
    WowCyborg_CURRENTATTACK = "Riptide";
    return SetSpellRequest(riptide);
  end

  WowCyborg_CURRENTATTACK = "-";
  return SetSpellRequest(nil);
end

print("Arena resto shaman rotation loaded");