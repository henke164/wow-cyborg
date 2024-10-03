--[[
  Button    Spell
  Shift+1   Avatar
  Shift+2   Demoralizing Shout
  Shift+3   Shield Wall
  Shift+4   Last Stand
  Ctrl+1    Rallying Cry
  1         Shield Slam
  2         Thunder Clap
  3         Revenge
  4         Devastate
  5         Shield Block
  6         Ignore Pain
  7         Victory Rush
]]--

local incomingDamage = {}
local meleeDamageInLast5Seconds = 0
local rangedDamageInLast5Seconds = 0

local avatar = "F+5";
local demoralizingShout = "F+6";
local shieldWall = "F+7";
local lastStand = "F+8";
local rallyingCry = "F+9";
local shieldSlam = "1";
local thunderClap = "2";
local revenge = "3";
local execute = "4";
local shieldBlock = "5";
local ignorePain = "6";
local victoryRush = "7";
local attack = "8";
local battleShout = "CTRL+3";
local heroicThrow = "0";

local eightYardCheck = 316593;--"Intimidating Shout";

WowCyborg_PAUSE_KEYS = {
  "F1",
  "F2",
  "F3",
  "F4",
  "R",
  "NUMPAD5",
  "NUMPAD7",
  "NUMPAD8",
  "§"
}


function GetClapCooldown()
  local sStart, sDuration = GetSpellCooldown("Thunder Clap");
  local tl = sStart + sDuration - GetTime();
  if tl < 1 then
    return 0;
  end

  return tl;
end

function RenderMultiTargetRotation()
  return SetSpellRequest("G");
end

function RenderSingleTargetRotation()
  local nearbyEnemies = GetNearbyEnemyCount(316593);
  local targetHp = GetHealthPercentage("target");
  local bsBuff = FindBuff("player", "Battle Shout");  
  local holActive = C_Spell.GetOverrideSpell(6343) == 435222 and GetClapCooldown() == 0;

  if holActive and InCombatLockdown() then
    WowCyborg_CURRENTATTACK = "Thunder Clap";
    return SetSpellRequest(thunderClap);
  end
  
  if bsBuff == nil and IsCastable("Battle Shout", 0) then
    --WowCyborg_CURRENTATTACK = "Battle Shout";
    --return SetSpellRequest(battleShout);
  end

  if InMeleeRange() == false then
    if (IsCastable("Thunder Clap", 0) or holActive) and nearbyEnemies > 0 then
      WowCyborg_CURRENTATTACK = "Thunder Clap";
      return SetSpellRequest(thunderClap);
    end

    if InCombatLockdown() and IsCastableAtEnemyTarget("Heroic Throw", 0) then
      WowCyborg_CURRENTATTACK = "Heroic Throw";
      return SetSpellRequest(heroicThrow);
    end

    WowCyborg_CURRENTATTACK = "-";
    return SetSpellRequest(nil);
  end

  local maxHp = UnitHealthMax("player");
  local rage = UnitPower("player");
  local hpPercentage = GetHealthPercentage("player");
  
  local outburst = FindBuff("player", "Outburst")
  local vrBuff = FindBuff("player", "Victorious")
  if hpPercentage < 70 and IsCastableAtEnemyTarget("Impending Victory", 10) then
    WowCyborg_CURRENTATTACK = "Impending Victory";
    return SetSpellRequest(victoryRush);
  end

  if hpPercentage < 60 then
    if IsCastable("Last Stand", 0) then
      WowCyborg_CURRENTATTACK = "Last Stand";
      return SetSpellRequest(lastStand);
    end

    if IsCastable("Shield Wall", 0) then
      WowCyborg_CURRENTATTACK = "Shield Wall";
      return SetSpellRequest(shieldWall);
    end

    if IsCastable("Rallying Cry", 0) then
      WowCyborg_CURRENTATTACK = "Rallying Cry";
      return SetSpellRequest(rallyingCry);
    end
  end

  local requiredAmount = 2000000;
    
  local ipBuff, ipTl, _, __, ___, points = FindBuff("player", "Ignore Pain");
  local ipAmount = 0;
  if points ~= nil then
    ipAmount = points[1]
  end
  
  local needIgnorePain = InCombatLockdown() and (ipBuff == nil or ipTl < 3 or ipAmount < requiredAmount);

  if InCombatLockdown() then
    if InMeleeRange() then
      local sbBuff = FindBuff("player", "Shield Block")
      if sbBuff == nil and IsCastable("Shield Block", 30) then
        WowCyborg_CURRENTATTACK = "Shield Block";
        return SetSpellRequest(shieldBlock);
      end
    end

    if (ipBuff == nil or ipTl < 3) and IsCastable("Ignore Pain", 35) then
      WowCyborg_CURRENTATTACK = "Ignore Pain";
      return SetSpellRequest(ignorePain);
    end
  end

  if nearbyEnemies > 1 then
    if IsCastable("Thunder Clap", 0) or holActive then
      WowCyborg_CURRENTATTACK = "Thunder Clap";
      return SetSpellRequest(thunderClap);
    end

    if IsCastable("Demoralizing Shout", 0) and rage < 70 then
      WowCyborg_CURRENTATTACK = "Demoralizing Shout";
      return SetSpellRequest(demoralizingShout);
    end

    if nearbyEnemies > 4 then
      if IsCastable("Revenge", 50) and (ipBuff ~= nil and ipTl > 3) then
        WowCyborg_CURRENTATTACK = "Revenge";
        return SetSpellRequest(revenge);
      end
    end

    if rage < 50 then
      if IsCastableAtEnemyTarget("Shield Slam", 0) then
        WowCyborg_CURRENTATTACK = "Shield Slam";
        return SetSpellRequest(shieldSlam);
      end
    end

    if IsCastable("Thunder Clap", 0) or holActive then
      WowCyborg_CURRENTATTACK = "Thunder Clap";
      return SetSpellRequest(thunderClap);
    end

    local revBuff = FindBuff("player", "Revenge!");
    if (revBuff == "Revenge!" or IsCastable("Revenge", 80)) then
      if IsCastable("Revenge", 0) then
        WowCyborg_CURRENTATTACK = "Revenge";
        return SetSpellRequest(revenge);
      end
    end

    if IsCastableAtEnemyTarget("Shield Slam", 0) then
      WowCyborg_CURRENTATTACK = "Shield Slam";
      return SetSpellRequest(shieldSlam);
    end
  else -- SINGLE target
    if IsCastableAtEnemyTarget("Shield Slam", 0) then
      WowCyborg_CURRENTATTACK = "Shield Slam";
      return SetSpellRequest(shieldSlam);
    end

    if IsCastable("Demoralizing Shout", 0) and (nearbyEnemies > 0 or InMeleeRange() and rage < 70) then
      WowCyborg_CURRENTATTACK = "Demoralizing Shout";
      return SetSpellRequest(demoralizingShout);
    end
    
    if rage > 20 then
      if targetHp < 20 and IsCastableAtEnemyTarget("Execute", 0) then
        WowCyborg_CURRENTATTACK = "Execute";
        return SetSpellRequest(execute);
      end
    end

    if IsCastable("Thunder Clap", 0) or holActive then
      WowCyborg_CURRENTATTACK = "Thunder Clap";
      return SetSpellRequest(thunderClap);
    end
    
    local revBuff = FindBuff("player", "Revenge!");
    if (revBuff == "Revenge!" or IsCastable("Revenge", 80)) then
      if IsCastable("Revenge", 0) then
        WowCyborg_CURRENTATTACK = "Revenge";
        return SetSpellRequest(revenge);
      end
    end
  end

  if needIgnorePain and IsCastable("Ignore Pain", 35) then
    WowCyborg_CURRENTATTACK = "Ignore Pain";
    return SetSpellRequest(ignorePain);
  end
  
  if IsCastableAtEnemyTarget("Shield Slam", 0) then
    WowCyborg_CURRENTATTACK = "Shield Slam";
    return SetSpellRequest(shieldSlam);
  end
  
  WowCyborg_CURRENTATTACK = "-";
  return SetSpellRequest(nil);
end

function InMeleeRange()
  return IsSpellInRange("Shield Slam", "target") == 1;
end

function CreateDamageTakenFrame()
  local frame = CreateFrame("Frame")
  frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")

  frame:SetScript("OnEvent", function()
    local timestamp, type, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, amountDetails = CombatLogGetCurrentEventInfo()
    if destGUID ~= UnitGUID("player") then
      return;
    end
    
    local DamageDetails
    if type == "SPELL_DAMAGE" or type == "SPELL_PERIODIC_DAMAGE" or type == "RANGE_DAMAGE" then
      _, _, _, damage = amountDetails
      DamageDetails = { damage = damage, melee = false };
    elseif type == "SWING_DAMAGE" then
      damage = amountDetails;
      DamageDetails = { damage = damage, melee = true };
    elseif type == "ENVIRONMENTAL_DAMAGE" then
      _, damage = amountDetails
      DamageDetails = { damage = damage, melee = false };
    end

    if DamageDetails and DamageDetails.damage then
      DamageDetails.timestamp = timestamp;

      tinsert(incomingDamage, 1, DamageDetails);

      local cutoff = timestamp - 5
      meleeDamageInLast5Seconds = 0
      rangedDamageInLast5Seconds = 0;
      for i = #incomingDamage, 1, -1 do
          local damage = incomingDamage[i]
          if damage.timestamp < cutoff then
            incomingDamage[i] = nil
          else
            if damage.melee then
              meleeDamageInLast5Seconds = meleeDamageInLast5Seconds + incomingDamage[i].damage;
            else
              rangedDamageInLast5Seconds = rangedDamageInLast5Seconds + incomingDamage[i].damage;
            end
          end
      end
    end

  end)
end

print("Protection warrior rotation loaded");
CreateDamageTakenFrame();