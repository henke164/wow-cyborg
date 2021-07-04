--[[
  Button    Spell
  1         Charge
  2         Rend
  3         Heroic strike
  4         Overpower
  5         Battleshout
  6         Attack
]]--

local charge = "1";
local sunderArmor = "2";
local heroicStrike = "3";
local overpower = "4";
local battleshout = "5";
local attack = "6";
local demoShout = "7";
local execute = "8";
local eat = "9";
local shieldSlam = "0";

function IsMelee()
  return CheckInteractDistance("target", 5) and IsCastableAtEnemyTarget("Rend", 0) ;
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
      
    if IsCastableAtEnemyTarget("Charge", 0) then
      WowCyborg_CURRENTATTACK = "Charge";
      return SetSpellRequest(charge);
    end

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

  local opBuff = IsUsableSpell("Execute");
  if opBuff == true then
    if IsCastableAtEnemyTarget("Execute", 15) then
      WowCyborg_CURRENTATTACK = "Execute";
      return SetSpellRequest(execute);
    end
  end

  local opBuff = IsUsableSpell("Overpower");
  if opBuff == true then
    if IsCastableAtEnemyTarget("Overpower", 5) then
      WowCyborg_CURRENTATTACK = "Overpower";
      return SetSpellRequest(overpower);
    end
  end

  if IsMelee() then
    local demoDebuff = FindDebuff("target", "Demoralizing Shout");
    if demoDebuff == nil then
      if IsCastable("Demoralizing Shout", 0) then
        WowCyborg_CURRENTATTACK = "Demoralizing Shout";
        return SetSpellRequest(demoShout);
      end
    end  
  end

  if IsCastableAtEnemyTarget("Shield Slam", 0) then
    WowCyborg_CURRENTATTACK = "Shield Slam";
    return SetSpellRequest(shieldSlam);
  end

  local rendDot = FindDebuff("target", "Rend");
  if rendDot == nil then
    if IsCastableAtEnemyTarget("Rend", 10) then
      WowCyborg_CURRENTATTACK = "Rend";
      return SetSpellRequest(rend);
    end
  end

  if IsCastableAtEnemyTarget("Heroic Strike", 15) then
    WowCyborg_CURRENTATTACK = "Heroic Strike";
    return SetSpellRequest(heroicStrike);
  end
  
  if IsMelee() then
    WowCyborg_CURRENTATTACK = "Heroic Strike";
    return SetSpellRequest(heroicStrike);
  end
end

function CreateEmoteListenerFrame()
  local frame = CreateFrame("Frame");
  frame:RegisterEvent("PLAYER_TARGET_CHANGED");
  frame:SetScript("OnEvent", function(self, event, ...)
    print("Target changed");
  end)
end

print("Classic warrior rotation loaded!");

CreateEmoteListenerFrame();