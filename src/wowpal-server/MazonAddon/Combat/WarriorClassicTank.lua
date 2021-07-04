--[[
  Button    Spell
  1         Charge
  2         Rend
  3         Heroic strike
  4         Overpower
  5         Battleshout
  6         Attack
]]--

local startTargetChange = 0;

local thunderclap = "1";
local shieldSlam = "2";
local revenge = "3";
local cleave = "4";
local devastate = "5";
local battleshout = "6";
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
  if startTargetChange > GetTime() - 0.5 then
    WowCyborg_CURRENTATTACK = "Target Swap";
    return SetSpellRequest("F+9");
  end

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

  if aoe ~= true and IsCastableAtEnemyTarget("Shield Slam", 15) then
    WowCyborg_CURRENTATTACK = "Shield Slam";
    return SetSpellRequest(shieldSlam);
  end

  if hp < 90 and IsCastable("Shield Block", 10) and IsMelee() then
    WowCyborg_CURRENTATTACK = "Shield Block";
    return SetSpellRequest(shieldBlock);
  end
  
  local bs = FindBuff("player", "Battle Shout");

  if bs == nil then
    if IsCastable("Battle Shout", 10) then
      WowCyborg_CURRENTATTACK = "Battle Shout";
      return SetSpellRequest(battleshout);
    end
  end

  if aoe == true then
    if IsCastableAtEnemyTarget("Cleave", 40) then
      WowCyborg_CURRENTATTACK = "Cleave";
      return SetSpellRequest(cleave);
    end
    
    local demoDebuff = FindDebuff("target", "Demoralizing Shout");
    if demoDebuff == nil and IsMelee() and IsCastableAtEnemyTarget("Demoralizing Shout", 10) then
      WowCyborg_CURRENTATTACK = "Demoralizing Shout";
      return SetSpellRequest(demoShout);
    end
  else
    if IsCastableAtEnemyTarget("Devastate", 12) then
      WowCyborg_CURRENTATTACK = "Devastate";
      return SetSpellRequest(devastate);
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
      if IsSpellInRange("Heroic Strike", "target") then
        startTargetChange = GetTime();
      end
    end
  end)
end

CreateEmoteListenerFrame();

print("Classic tank rotation loaded!");