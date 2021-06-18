--[[
  Button    Spell
  1   deathsCaress
  2   marrowrend
  3   bloodboil
  4   deathstrike
  5   heartstrike
  6   bonestorm
]]--

local incomingDamage = {}
local meleeDamageInLast5Seconds = 0
local rangedDamageInLast5Seconds = 0

local deathsCaress = "1";
local marrowrend = "2";
local bloodboil = "3";
local deathstrike = "4";
local heartstrike = "5";
local bonestorm = "6";

WowCyborg_PAUSE_KEYS = {
  "F3",
  "F4",
  "F10"
}

function RenderMultiTargetRotation()
  if IsCastableAtEnemyTarget("Bonestorm", 0) then
    WowCyborg_CURRENTATTACK = "Bonestorm";
    return SetSpellRequest(bonestorm);
  end

  return RenderSingleTargetRotation();
end

function RenderSingleTargetRotation()
  local bsBuff, bsTs, bsStacks = FindBuff("player", "Bone Shield");

  if bsBuff == nil or bsStacks == nil or bsStacks < 6 or bsTs < 4 then
    if IsCastableAtEnemyTarget("Marrowrend", 0) then
      WowCyborg_CURRENTATTACK = "Marrowrend";
      return SetSpellRequest(marrowrend);
    else
      return SetSpellRequest(nil);
    end
  end

  local bbCharges = GetSpellCharges("Blood Boil");

  if bbCharges ~= nil and bbCharges > 0 then
    if IsCastableAtEnemyTarget("Death Strike", 0) then
      WowCyborg_CURRENTATTACK = "Blood Boil";
      return SetSpellRequest(bloodboil);
    end
  end

  if IsCastableAtEnemyTarget("Death Strike", 45) then
    WowCyborg_CURRENTATTACK = "Death Strike";
    return SetSpellRequest(deathstrike);
  end

  local runeCount = GetRuneCount();
  local runeLimit = 3;
  if bsBuff == nil or bsTs > 10 then
    runeLimit = 0;
  end

  if runeCount >= runeLimit then
    if IsCastableAtEnemyTarget("Heart Strike", 0) then
      WowCyborg_CURRENTATTACK = "Heart Strike";
      return SetSpellRequest(heartstrike);
    end
  end

  if bsBuff == nil or bsStacks == nil or bsStacks < 10 or bsTs < 4 then
    if IsCastableAtEnemyTarget("Marrowrend", 0) then
      WowCyborg_CURRENTATTACK = "Marrowrend";
      return SetSpellRequest(marrowrend);
    end
  end

  WowCyborg_CURRENTATTACK = "-";
  return SetSpellRequest(nil);
end

function GetRuneCount()
  local runeAmount = 0
  for i=1,6 do
    local start, duration, runeReady = GetRuneCooldown(i)
    if runeReady == true then
      runeAmount = runeAmount+1
    end
  end
  return runeAmount;
end

print("DK blood rotation loaded");