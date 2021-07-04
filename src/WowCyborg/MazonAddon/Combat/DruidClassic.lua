--[[
  Button    Spell
  1         Wrath
  2         Moonfire
  6         Attack
  7         Healing Wave
  8         Mark of the Wild
]]--

local wrath = "1";
local moonfire = "2";
local attack = "6";
local rejuvenation = "SHIFT+1";
local thorns = "SHIFT+2";
local healingTouch = "SHIFT+3";
local motw = "SHIFT+4";

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

  local motwBuff = FindBuff("player", "Mark of the Wild");
  if motwBuff == nil then
    if IsCastable("Mark of the Wild", 20) then
      WowCyborg_CURRENTATTACK = "Mark of the Wild";
      return SetSpellRequest(motw);
    end
  end
  
  local thornsBuff = FindBuff("player", "Thorns");
  if thornsBuff == nil then
    if IsCastable("Thorns", 35) then
      WowCyborg_CURRENTATTACK = "Thorns";
      return SetSpellRequest(thorns);
    end
  end

  if IsMelee() ~= true then
    if hp < 50 then
      if IsCastable("Healing Touch", 25) then
        WowCyborg_CURRENTATTACK = "Healing Touch";
        return SetSpellRequest(healingTouch);
      end
    end

    if IsCastableAtEnemyTarget("Wrath", 20) and WowCyborg_INCOMBAT == false then
      WowCyborg_CURRENTATTACK = "Wrath";
      return SetSpellRequest(wrath);
    end
    
    if IsCastableAtEnemyTarget("Moonfire", 25) then
      WowCyborg_CURRENTATTACK = "Moonfire";
      return SetSpellRequest(moonfire);
    end

    if hp < 80 then
      WowCyborg_CURRENTATTACK = "eat";
      return SetSpellRequest(eat);
    end
      
    WowCyborg_CURRENTATTACK = "-";
    return SetSpellRequest(nil);
  end

  if hp < 50 then
    if IsCastable("Rejuvenation", 25) then
      WowCyborg_CURRENTATTACK = "Rejuvenation";
      return SetSpellRequest(rejuvenation);
    end
  end

  if IsCastableAtEnemyTarget("Wrath", 0) and IsCurrentSpell(6603) == false then
    WowCyborg_CURRENTATTACK = "Attack";
    return SetSpellRequest(attack);
  end
  
  if IsMelee() then
    WowCyborg_CURRENTATTACK = "None";
    return SetSpellRequest("9");
  end
end

print("Classic druid rotation loaded!");