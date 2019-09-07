--[[
  Button    Spell
]]--

local startedFollowingAt = 0;
local startedAssistAt = 0;
local startedWaitAt = 0;
local serpentSting = "1";
local attack = "2";
local raptorStrike = "3";
local arcaneShot = "4";
local feedPet = "8";
local eat = "9";
local aspectOfTheHawk = "SHIFT+1";
local huntersMark = "SHIFT+2";

function IsMelee()
  return CheckInteractDistance("target", 5);
end

function RenderMultiTargetRotation()
  return SetSpellRequest(nil);
end

function RenderSingleTargetRotation()
  local hp = GetHealthPercentage("player");

  if WowCyborg_INCOMBAT == false then
    local happiness = GetPetHappiness();
    if happiness < 3 then
      local feedbuff = FindBuff("pet", "Feed Pet Effect");
      if feedbuff == nil then
        WowCyborg_CURRENTATTACK = "Feed Pet";
        return SetSpellRequest(feedPet);
      end
    end
  end

  local aothBuff = FindBuff("player", "Aspect of the Hawk");
  if aothBuff == nil then
    if IsCastableAtEnemyTarget("Aspect of the Hawk", 20) then
      WowCyborg_CURRENTATTACK = "Aspect of the Hawk";
      return SetSpellRequest(aspectOfTheHawk);
    end
  end

  if IsMelee() ~= true then
    local hmDebuff = FindDebuff("target", "Hunter's Mark");
    if hmDebuff == nil then
      if IsCastableAtEnemyTarget("Hunter's Mark", 15) then
        WowCyborg_CURRENTATTACK = "Hunter's Mark";
        return SetSpellRequest(huntersMark);
      end
    end

    local ssDebuff = FindDebuff("target", "Serpent Sting");
    if ssDebuff == nil then
      if IsCastableAtEnemyTarget("Serpent Sting", 15) then
        WowCyborg_CURRENTATTACK = "Serpent Sting";
        return SetSpellRequest(serpentSting);
      end
    end

    if IsCastableAtEnemyTarget("Arcane Shot", 15) then
      WowCyborg_CURRENTATTACK = "Arcane Shot";
      return SetSpellRequest(arcaneShot);
    end

    if IsCastableAtEnemyTarget("Auto Shot", 0) and IsCurrentSpell(75) == false then
      WowCyborg_CURRENTATTACK = "Attack";
      return SetSpellRequest(attack);
    end

    WowCyborg_CURRENTATTACK = "-";
    return SetSpellRequest(nil);
  end
  
  if IsMelee() == true then
    WowCyborg_CURRENTATTACK = "Raptor Strike";
    return SetSpellRequest(raptorStrike);
  end

  WowCyborg_CURRENTATTACK = "-";
  return SetSpellRequest(nil);
end

print("Classic hunter runner rotation loaded");