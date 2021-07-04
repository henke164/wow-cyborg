--[[
  bloodthirst = "1";
  overpower = "2";
  whirlwind = "2";
  heroicStrike = "3";
  execute = "4";
  attack = "7";
  cleave = "8";
  hamstring = "9";
  battleshout = "0";
  bloodRage = "SHIFT+2";
]]--

local mortalStrike = "1";
local overpower = "2";
local whirlwind = "2";
local heroicStrike = "3";
local execute = "4";
local attack = "7";
local cleave = "8";
local hamstring = "9";
local battleshout = "0";
local bloodRage = "SHIFT+2";

function IsMelee()
  return IsSpellInRange("Rend", "target") == 1;
end

-- Multi target
function RenderMultiTargetRotation()
  local hamstringDebuff = FindDebuff("target", "Hamstring");
  if hamstringDebuff == nil then
    if IsCastableAtEnemyTarget("Hamstring", 10) then
      WowCyborg_CURRENTATTACK = "Hamstring";
      return SetSpellRequest(hamstring);
    end
  end

  return RenderSingleTargetRotation();
end

-- Single target
function RenderSingleTargetRotation()

  if WowCyborg_INCOMBAT == false then
    WowCyborg_CURRENTATTACK = "-";
    return SetSpellRequest(nil);
  end
  
  if IsCurrentSpell(6603) == false then
    WowCyborg_CURRENTATTACK = "Attack";
    return SetSpellRequest(attack);
  end

  local bsBuff = FindBuff("player", "Battle Shout");
  if bsBuff == nil and IsCastable("Battle Shout", 10) then
    WowCyborg_CURRENTATTACK = "Battle Shout";
    return SetSpellRequest(battleshout);
  end

  local opBuff = IsUsableSpell("Overpower");
  if opBuff == true then
    if IsCastableAtEnemyTarget("Overpower", 5) then
      WowCyborg_CURRENTATTACK = "Overpower";
      return SetSpellRequest(overpower);
    end
  end

  local targetHp = GetHealthPercentage("target");
  if targetHp > 0 and targetHp < 20 then
    WowCyborg_CURRENTATTACK = "Execute";
    return SetSpellRequest(execute);
  end
  
  if IsCastableAtEnemyTarget("Mortal Strike", 0) then
    WowCyborg_CURRENTATTACK = "Mortal Strike";
    return SetSpellRequest(mortalStrike);
  end

  if IsMelee() and IsCastableAtEnemyTarget("Whirlwind", 0) then
    WowCyborg_CURRENTATTACK = "Whirlwind";
    return SetSpellRequest(whirlwind);
  end
  
  if IsMelee() and IsCastable("Bloodrage", 0) then
    WowCyborg_CURRENTATTACK = "Bloodrage";
    return SetSpellRequest(bloodRage);
  end

  local wwCd, wwTotal = GetSpellCooldown("Whirlwind", "spell");
  local wwTimeLeft = wwTotal - (GetTime() - wwCd);
  
  local msCd, btTotal = GetSpellCooldown("Mortal Strike", "spell");
  local msTimeLeft = btTotal - (GetTime() - msCd);
  local hsRageReq = 12;

  if wwTimeLeft < 4 or msTimeLeft < 4 then
    hsRageReq = 42;
  end
    
  if IsMelee() and IsCastableAtEnemyTarget("Heroic Strike", hsRageReq) then
    WowCyborg_CURRENTATTACK = "Heroic Strike";
    return SetSpellRequest(heroicStrike);
  end

  WowCyborg_CURRENTATTACK = "-";
  return SetSpellRequest(nil);
end

print("Classic ARMS warrior rotation loaded!");