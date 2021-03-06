--[[
  Button    Spell
]]--

local rake = "1";
local rip = "2";
local shred = "3";
local ferociousBite = "4";
local brutalSlash = "5";
local berserk = "6";
local tigersFury = "7";
local thrash = "8";
local feralFrenzy = "9";
local regrowth = "0";
local maim = "SHIFT+2";

WowCyborg_PAUSE_KEYS = {
  "F1",
  "F4",
  "F5",
  "F6",
  "F",
  "X",
  "LSHIFT",
  "ESCAPE"
}

function IsMelee()
  return IsSpellInRange("Shred") == 1;
end

function RenderMultiTargetRotation()
  return RenderSingleTargetRotation(false);
end

function RenderSingleTargetRotation(useComboPoints)
  if useComboPoints == nil then
    useComboPoints = true;
  end
  
  if UnitChannelInfo("player") == "Convoke the Spirits" then
    WowCyborg_CURRENTATTACK = "BURSTING";
    return SetSpellRequest(nil);
  end

  local cat = FindBuff("player", "Cat Form");

  if cat == nil then
    WowCyborg_CURRENTATTACK = "Not Cat";
    return SetSpellRequest(nil);
  end

  local energy = UnitPower("player");
  local hp = GetHealthPercentage("player");
  local targetHp = GetHealthPercentage("player");
  
  if IsMelee() == false then
    WowCyborg_CURRENTATTACK = "-";
    return SetSpellRequest(nil);
  end
  
  local predaSwiftBuff = FindBuff("player", "Predatory Swiftness");
  if hp < 80 and predaSwiftBuff ~= nil then
    WowCyborg_CURRENTATTACK = "Regrowth";
    return SetSpellRequest(regrowth);
  end

  local rakeDot = FindDebuff("target", "Rake");
  if rakeDot == nil and IsCastableAtEnemyTarget("Rake", 35) then
    WowCyborg_CURRENTATTACK = "Rake";
    return SetSpellRequest(rake);
  end

  local tfuryBuff = FindBuff("player", "Tiger's Fury");
  if energy <= 30 and tfuryBuff == nil and IsCastable("Tiger's Fury", 0) then
    WowCyborg_CURRENTATTACK = "Tiger's Fury";
    return SetSpellRequest(tigersFury);
  end

  if IsCastable("Berserk", 0) then
    WowCyborg_CURRENTATTACK = "Berserk";
    return SetSpellRequest(berserk);
  end
  local points = GetComboPoints("player", "target");

  local ripDot, ripCd = FindDebuff("target", "Rip");
  if points > 0 and ripDot == nil and IsCastableAtEnemyTarget("Rip", 20) then
    WowCyborg_CURRENTATTACK = "Rip";
    return SetSpellRequest(rip);
  end

  if points == 5 then
    if useComboPoints and IsCastableAtEnemyTarget("Ferocious Bite", 25) then
      WowCyborg_CURRENTATTACK = "Ferocious Bite";
      return SetSpellRequest(ferociousBite);
    elseif IsCastableAtEnemyTarget("Maim", 30) then
      WowCyborg_CURRENTATTACK = "Maim";
      return SetSpellRequest(maim);
    end
  end

  if useComboPoints then
    if points > 0 and ripCd ~= nil and ripCd < 5 and IsCastableAtEnemyTarget("Ferocious Bite", 25) then
      WowCyborg_CURRENTATTACK = "Ferocious Bite";
      return SetSpellRequest(ferociousBite);
    end
  end

  if points < 5 and IsCastableAtEnemyTarget("Feral Frenzy", 25) then
    WowCyborg_CURRENTATTACK = "Feral Frenzy";
    return SetSpellRequest(feralFrenzy);
  end

  local thrashDot, thrashDotCd = FindDebuff("target", "Thrash");
  if thrashDot == nil or thrashDotCd < 5 and IsCastableAtEnemyTarget("Thrash", 40) then
    WowCyborg_CURRENTATTACK = "Thrash";
    return SetSpellRequest(thrash);
  end
  
  local clearcastingBuff = FindBuff("player", "Clearcasting");
  if IsCastableAtEnemyTarget("Brutal Slash", 0) and clearcastingBuff == nil then
    WowCyborg_CURRENTATTACK = "Brutal Slash";
    return SetSpellRequest(brutalSlash);
  end

  if IsCastableAtEnemyTarget("Shred", 0) and ((useComboPoints and points < 5) or clearcastingBuff) then
    WowCyborg_CURRENTATTACK = "Shred";
    return SetSpellRequest(shred);
  end

  WowCyborg_CURRENTATTACK = "-";
  return SetSpellRequest(nil);
end

print("Druid feral rotation loaded");