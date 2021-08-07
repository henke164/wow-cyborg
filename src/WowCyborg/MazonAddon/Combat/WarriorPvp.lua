--[[
  Button    Spell
  1         Hamstring
  2         Slam
  3         Execute
  4         Mortal Strike
  5         Overpower
]]--

local hamstring = "1";
local bladestorm = "2";
local execute = "3";
local mortalStrike = "4";
local overpower = "5";
local slam = "6";
local rend = "7";
local sweepingStrikes = "8";
local ignorePain = "9";

local warbreaker = "F+9";
local victoryRush = "SHIFT+3";

WowCyborg_PAUSE_KEYS = {
  "F",
  "G",
  "R",
  "LSHIFT",
  "F1",
  "F2",
  "F3",
  "F5",
  "F6",
  "F7",
  "F11",
  "NUMPAD5",
  "NUMPAD9",
}

function RenderRangedRotation()
  local sdBuff = FindBuff("player", "Sudden Death");
  if sdBuff ~= nil then
    if IsCastableAtEnemyTarget("Execute", 0) then
      WowCyborg_CURRENTATTACK = "Execute";
      return SetSpellRequest(execute);
    end
  end

  if IsCastableAtEnemyTarget("Execute", 70) then
    WowCyborg_CURRENTATTACK = "Execute";
    return SetSpellRequest(execute);
  end
  
  if IsCastableAtEnemyTarget("Heroic Throw", 0) and WowCyborg_INCOMBAT then
    WowCyborg_CURRENTATTACK = "Heroic Throw";
    return SetSpellRequest(rend);
  end

  WowCyborg_CURRENTATTACK = "-";
  return SetSpellRequest(nil);
end

function RenderMultiTargetRotation()
  return RenderSingleTargetRotation(true)
end

function RenderSingleTargetRotation(defensive)
  local casting = UnitChannelInfo("player");

  if casting == "Shackles of Malediction" then
    WowCyborg_CURRENTATTACK = "Shackles of Malediction";
    return SetSpellRequest(nil);
  end

  local thornsBuff = FindBuff("target", "Thorns");

  if thornsBuff ~= nil then
    print("THORNS!");
    WowCyborg_CURRENTATTACK = "THORNS!";
    return SetSpellRequest(nil);
  end

  if InMeleeRange() == false then
    return RenderRangedRotation();
  end

  local nearbyEnemies = GetNearbyEnemyCount();
  local hpPercentage = GetHealthPercentage("player");
  local sdBuff = FindBuff("player", "Sudden Death");
  local speared = FindDebuff("target", "Spear of Bastion");
  local avatarBuff = FindBuff("player", "Avatar");
  local freedomBuff = FindBuff("target", "Blessing of Freedom");
  local phowlDebuff = FindDebuff("target", "Piercing howl");

  local vrBuff = FindBuff("player", "Victorious")
  if hpPercentage < 80 and 
    IsCastableAtEnemyTarget("Victory Rush", 0) and 
    vrBuff == "Victorious" then
    WowCyborg_CURRENTATTACK = "Victory Rush";
    return SetSpellRequest(victoryRush);
  end

  if avatarBuff ~= nil or speared ~= nil then
    if IsCastableAtEnemyTarget("Warbreaker", 0) then
      WowCyborg_CURRENTATTACK = "Warbreaker";
      return SetSpellRequest(warbreaker);
    end
  end

  local hamstringDebuff, hamstringTimeLeft = FindDebuff("target", "Hamstring");
  if freedomBuff == nil and phowlDebuff == nil then
    if hamstringDebuff == nil or hamstringTimeLeft < 3 then
      if IsCastableAtEnemyTarget("Hamstring", 10) then
        WowCyborg_CURRENTATTACK = "Hamstring";
        return SetSpellRequest(hamstring);
      end
    end
  end

  local ssStart, ssDuration = GetSpellCooldown("Sweeping Strikes");
  local ssCdLeft = ssStart + ssDuration - GetTime();
  if nearbyEnemies > 1 and ssCdLeft < 1 then
    WowCyborg_CURRENTATTACK = "Sweeping strikes";
    return SetSpellRequest(sweepingStrikes);
  end

  if sdBuff ~= nil then
    if IsCastableAtEnemyTarget("Execute", 0) then
      WowCyborg_CURRENTATTACK = "Execute";
      return SetSpellRequest(execute);
    end
  end

  if IsCastableAtEnemyTarget("Execute", 20) then
    WowCyborg_CURRENTATTACK = "Execute";
    return SetSpellRequest(execute);
  end

  -- If mortal strike is ready
  if IsCastableAtEnemyTarget("Mortal Strike", 0) then
    if IsCastableAtEnemyTarget("Mortal Strike", 30) then
      WowCyborg_CURRENTATTACK = "Mortal Strike";
      return SetSpellRequest(mortalStrike);
    end

    if IsCastableAtEnemyTarget("Overpower", 0) then
      WowCyborg_CURRENTATTACK = "Overpower";
      return SetSpellRequest(overpower);
    end

    WowCyborg_CURRENTATTACK = "Mortal Strike";
    return SetSpellRequest(mortalStrike);
  end
  
  local hpp = GetHealthPercentage("target");

  if tostring(hpp) ~= "-nan(ind)" and hpp > 0 and hpp < 50 then
    if IsCastable("Sharpen Blade", 0) then
      WowCyborg_CURRENTATTACK = "Sharpen Blade";
      return SetSpellRequest("0");
    end
  end

  local ignorePainBuff = FindBuff("player", "Ignore Pain");
  local hp = GetHealthPercentage("player");
  if hp < 40 and ignorePainBuff == nil then
    if IsCastable("Ignore Pain", 70) then
      WowCyborg_CURRENTATTACK = "Ignore Pain";
      return SetSpellRequest(ignorePain);
    end
  end

  if InMeleeRange() == false then
    WowCyborg_CURRENTATTACK = "-";
    return SetSpellRequest(nil);
  end

  local rendDot = FindDebuff("target", "Rend");
  if rendDot == nil then
    if IsCastableAtEnemyTarget("Rend", 30) then
      WowCyborg_CURRENTATTACK = "Rend";
      return SetSpellRequest(rend);
    end
  end

  local colossusDebuff = FindDebuff("target", "Colossus Smash");
  if colossusDebuff ~= nil and IsCastableAtEnemyTarget("Bladestorm", 0) then
    WowCyborg_CURRENTATTACK = "Bladestorm";
    return SetSpellRequest(bladestorm);
  end
  
  if IsCastableAtEnemyTarget("Mortal Strike", 30) then
    WowCyborg_CURRENTATTACK = "Mortal Strike";
    return SetSpellRequest(mortalStrike);
  end

  if IsCastableAtEnemyTarget("Overpower", 0) then
    WowCyborg_CURRENTATTACK = "Overpower";
    return SetSpellRequest(overpower);
  end

  if defensive == true and ignorePainBuff == nil then
    if IsCastable("Ignore Pain", 40) then
      WowCyborg_CURRENTATTACK = "Ignore Pain";
      return SetSpellRequest(ignorePain);
    end
  end

  if IsCastableAtEnemyTarget("Slam", 60) then
    WowCyborg_CURRENTATTACK = "Slam";
    return SetSpellRequest(slam);
  end

  WowCyborg_CURRENTATTACK = "-";
  return SetSpellRequest(nil);
end

function InMeleeRange()
  return IsSpellInRange("Overpower", "target") == 1;
end

print("Arms pvp warrior rotation loaded");