--[[
  Button    Spell
]]--

local throw = "1";
local sinisterStrike = "2";
local eviscerate = "3";
local attack = "7";
local eat = "9";

function IsMelee()
  return IsSpellInRange("Sinister Strike", "target") == 1;
end

-- Multi target
function RenderMultiTargetRotation()
  return RenderSingleTargetRotation();
end

-- Single target
function RenderSingleTargetRotation()
  local targetFaction = UnitFactionGroup("target");
  if targetFaction ~= nil then
    WowCyborg_CURRENTATTACK = "Player targetted";
    return SetSpellRequest(nil);
  end

  local hp = GetHealthPercentage("player");
  
  if WowCyborg_INCOMBAT == false then
    if hp < 80 and hp > 1 then
      WowCyborg_CURRENTATTACK = "eat";
      return SetSpellRequest(eat);
    end
      
    if IsCastableAtEnemyTarget("Throw", 0) then
      WowCyborg_CURRENTATTACK = "Throw";
      return SetSpellRequest(throw);
    end

    WowCyborg_CURRENTATTACK = "-";
    return SetSpellRequest(nil);
  end
  
  if IsCurrentSpell(6603) == false then
    WowCyborg_CURRENTATTACK = "Attack";
    return SetSpellRequest(attack);
  end
  
  local points = GetComboPoints("player", "target");

  if points >= 3 then
    if IsCastableAtEnemyTarget("Eviscerate", 0) then
      WowCyborg_CURRENTATTACK = "Eviscerate";
      return SetSpellRequest(eviscerate);
    end
  end

  if IsMelee() then
    WowCyborg_CURRENTATTACK = "Sinister Strike";
    return SetSpellRequest(sinisterStrike);
  end
end

print("Classic warrior rotation loaded!");