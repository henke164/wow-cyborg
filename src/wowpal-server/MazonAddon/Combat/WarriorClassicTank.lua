--[[
  Button    Spell
  1         Charge
  2         Rend
  3         Heroic strike
  4         Overpower
  5         Battleshout
  6         Attack
]]--

local thunderclap = "1";
local shieldSlam = "2";
local revenge = "3";
local cleave = "4";
local heroicStrike = "5";
local demoShout = "8";
local shieldBlock = "7";
local bloodRage = "9";
local attack = "0";

WowCyborg_PAUSE_KEYS = {
  "LSHIFT",
  "F1",
  "F2",
  "F3",
  "F5",
  "NUMPAD5",
  "NUMPAD6",
}

function IsMelee()
  return IsSpellInRange("Rend", "target") == 1;
end

-- Multi target
function RenderMultiTargetRotation()
  return RenderSingleTargetRotation(true);
end

-- Single target
function RenderSingleTargetRotation(aoe)
  local rage = UnitPower("player");
  local hp = GetHealthPercentage("player");

  if IsMelee() and IsCurrentSpell(6603) == false then
    WowCyborg_CURRENTATTACK = "Attack";
    return SetSpellRequest(attack);
  end

  if IsMelee() and IsCastable("Bloodrage", 0) and rage < 20 then
    WowCyborg_CURRENTATTACK = "Bloodrage";
    return SetSpellRequest(bloodRage);
  end

  if IsMelee() and aoe == true and IsCastableAtEnemyTarget("Thunder Clap", 16) then
    WowCyborg_CURRENTATTACK = "Thunder Clap";
    return SetSpellRequest(thunderclap);
  end

  if IsCastableAtEnemyTarget("Revenge", 5) then
    WowCyborg_CURRENTATTACK = "Revenge";
    return SetSpellRequest(revenge);
  end

  if IsCastableAtEnemyTarget("Shield Slam", 20) then
    WowCyborg_CURRENTATTACK = "Shield Slam";
    return SetSpellRequest(shieldSlam);
  end

  if hp < 70 and IsCastableAtEnemyTarget("Shield Block", 10) then
    WowCyborg_CURRENTATTACK = "Shield Block";
    return SetSpellRequest(shieldBlock);
  end
  
  if aoe == true then
    if IsCastableAtEnemyTarget("Cleave", 20) then
      WowCyborg_CURRENTATTACK = "Cleave";
      return SetSpellRequest(cleave);
    end
    
    local demoDebuff = FindDebuff("target", "Demoralizing Shout");
    if demoDebuff == nil and IsMelee() and IsCastableAtEnemyTarget("Demoralizing Shout", 10) then
      WowCyborg_CURRENTATTACK = "Demoralizing Shout";
      return SetSpellRequest(demoShout);
    end
  else
    if IsCastableAtEnemyTarget("Heroic Strike", 15) then
      WowCyborg_CURRENTATTACK = "Heroic Strike";
      return SetSpellRequest(heroicStrike);
    end
  end

  WowCyborg_CURRENTATTACK = "-";
  return SetSpellRequest(nil);
end

function CreateEmoteListenerFrame()
  local frame = CreateFrame("Frame");
  frame:RegisterEvent("PLAYER_TARGET_CHANGED");
  frame:SetScript("OnEvent", function(self, event, ...)
    if WowCyborg_INCOMBAT then
      if IsCastableAtEnemyTarget("Heroic Strike", 0) then
        SendChatMessage("wait", "PARTY");
      end
    end
  end)
end

CreateEmoteListenerFrame();

print("Classic tank rotation loaded!");