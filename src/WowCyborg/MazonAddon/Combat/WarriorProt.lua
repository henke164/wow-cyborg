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

WowCyborg_PAUSE_KEYS = {
  "F2",
  "F3",
  "R",
  "NUMPAD5",
  "NUMPAD7",
}

function RenderMultiTargetRotation()
  return RenderSingleTargetRotation(true);
end

function RenderSingleTargetRotation(aoe)
  local targetHp = GetHealthPercentage("target");
  local bsBuff = FindBuff("player", "Battle Shout")
  if bsBuff == nil and IsCastable("Battle Shout", 0) then
    WowCyborg_CURRENTATTACK = "Battle Shout";
    return SetSpellRequest(battleShout);
  end

  if InMeleeRange() == false then
    if IsCastableAtEnemyTarget("Thunder Clap", 0) and CheckInteractDistance("target", 3) then
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
  
  local dangerHpLossLimit = UnitHealthMax("player") * 0.5;

  local vrBuff = FindBuff("player", "Victorious")
  if hpPercentage < 80 and 
    IsCastableAtEnemyTarget("Victory Rush", 0) and 
    vrBuff == "Victorious" then
    WowCyborg_CURRENTATTACK = "Victory Rush";
    return SetSpellRequest(victoryRush);
  end

  if meleeDamageInLast5Seconds > dangerHpLossLimit or 
    rangedDamageInLast5Seconds > dangerHpLossLimit or
    hpPercentage < 60 then

    if IsCastableAtEnemyTarget("Last Stand", 0) then
      WowCyborg_CURRENTATTACK = "Last Stand";
      return SetSpellRequest(lastStand);
    end

    if IsCastableAtEnemyTarget("Shield Wall", 0) then
      WowCyborg_CURRENTATTACK = "Shield Wall";
      return SetSpellRequest(shieldWall);
    end

    if IsCastableAtEnemyTarget("Rallying Cry", 0) then
      WowCyborg_CURRENTATTACK = "Rallying Cry";
      return SetSpellRequest(rallyingCry);
    end
  end

  if InCombatLockdown() then
    if InMeleeRange() then
      local sbBuff = FindBuff("player", "Shield Block")
      if sbBuff == nil and IsCastable("Shield Block", 30) then
        WowCyborg_CURRENTATTACK = "Shield Block";
        return SetSpellRequest(shieldBlock);
      end
    end

    if hpPercentage < 95 then
      local ipBuff, ipTl = FindBuff("player", "Ignore Pain");
      if (ipBuff == nil or ipTl < 3) and IsCastableAtEnemyTarget("Ignore Pain", 40) then
        WowCyborg_CURRENTATTACK = "Ignore Pain";
        return SetSpellRequest(ignorePain);
      end
    end
  end

  local avatarBuff = FindBuff("player", "Avatar")

  if IsCastableAtEnemyTarget("Avatar", 0) and targetHp > 10 then
    WowCyborg_CURRENTATTACK = "Avatar";
    return SetSpellRequest(avatar);
  end
  
  if aoe ~= true then
    if IsCastableAtEnemyTarget("Shield Slam", 0) then
      WowCyborg_CURRENTATTACK = "Shield Slam";
      return SetSpellRequest(shieldSlam);
    end
    
    if IsCastableAtEnemyTarget("Thunder Clap", 0) then
      WowCyborg_CURRENTATTACK = "Thunder Clap";
      return SetSpellRequest(thunderClap);
    end
    
    local revBuff = FindBuff("player", "Revenge!");
    if (revBuff == "Revenge!") then
      if IsCastableAtEnemyTarget("Revenge", 0) then
        WowCyborg_CURRENTATTACK = "Revenge";
        return SetSpellRequest(revenge);
      end
    end
  else
    if IsCastableAtEnemyTarget("Thunder Clap", 0) then
      WowCyborg_CURRENTATTACK = "Thunder Clap";
      return SetSpellRequest(thunderClap);
    end
    
    local revBuff = FindBuff("player", "Revenge!");
    if (revBuff == "Revenge!" or IsCastableAtEnemyTarget("Revenge", 60)) then
      if IsCastableAtEnemyTarget("Revenge", 0) then
        WowCyborg_CURRENTATTACK = "Revenge";
        return SetSpellRequest(revenge);
      end
    end

    if IsCastableAtEnemyTarget("Shield Slam", 0) then
      WowCyborg_CURRENTATTACK = "Shield Slam";
      return SetSpellRequest(shieldSlam);
    end
  end

  if targetHp < 95 and IsCastableAtEnemyTarget("Demoralizing Shout", 0) then
    WowCyborg_CURRENTATTACK = "Demoralizing Shout";
    return SetSpellRequest(demoralizingShout);
  end

  if rage > 70 then
    if targetHp < 20 and IsCastableAtEnemyTarget("Execute", 60) then
      WowCyborg_CURRENTATTACK = "Execute";
      return SetSpellRequest(execute);
    end

    if IsCastableAtEnemyTarget("Revenge", 30) then
      WowCyborg_CURRENTATTACK = "Revenge";
      return SetSpellRequest(revenge);
    end
  end

  if IsCurrentSpell(6603) == false then
    WowCyborg_CURRENTATTACK = "Attack";
    return SetSpellRequest(attack);
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