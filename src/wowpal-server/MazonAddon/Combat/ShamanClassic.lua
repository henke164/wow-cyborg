--[[
  Button    Spell
  1         Lightning Bolt
  2         Healing Wave
  6         Attack
]]--

local lightningBolt = "1";
local healingWave = "2";
local attack = "6";

function IsMelee()
  return CheckInteractDistance("target", 5);
end

-- Multi target
function RenderMultiTargetRotation()
  return RenderSingleTargetRotation();
end

-- Single target
function RenderSingleTargetRotation()
  local hp = GetHealthPercentage("player");

  if IsMelee() ~= true then
    if hp < 50 then
      if IsCastable("Healing Wave", 25) then
        WowCyborg_CURRENTATTACK = "Healing Wave";
        return SetSpellRequest(healingWave);
      end
    end

    if IsCastableAtEnemyTarget("Lightning Bolt", 15) and WowCyborg_INCOMBAT == false then
      WowCyborg_CURRENTATTACK = "Lightning Bolt";
      return SetSpellRequest(lightningBolt);
    end

    if hp < 80 then
      WowCyborg_CURRENTATTACK = "eat";
      return SetSpellRequest(eat);
    end
      
    WowCyborg_CURRENTATTACK = "-";
    return SetSpellRequest(nil);
  end
  
  if IsCastableAtEnemyTarget("Lightning Bolt", 0) and IsCurrentSpell(6603) == false then
    WowCyborg_CURRENTATTACK = "Attack";
    return SetSpellRequest(attack);
  end
  
  if IsMelee() then
    WowCyborg_CURRENTATTACK = "None";
    return SetSpellRequest("9");
  end
end

print("Classic shaman rotation loaded!");