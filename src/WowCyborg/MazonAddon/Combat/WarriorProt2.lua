--[[
  Button    Spell
]]--

local buttons = {};
buttons["shield_slam"] = "1";
buttons["thunder_clap"] = "2";
buttons["revenge"] = "3";
buttons["execute"] = "4";
buttons["shield_block"] = "5";
buttons["ignore_pain"] = "6";
buttons["victory_rush"] = "7";
buttons["demoralizing_shout"] = "F+6";
buttons["battle_shout"] = "CTRL+3";

local avatar = "F+5";
local demoralizingShout = "F+6";
local shieldWall = "F+7";
local lastStand = "F+8";
local rallyingCry = "F+9";
local attack = "8";
local heroicThrow = "0";

WowCyborg_PAUSE_KEYS = {
  "F1",
  "F2",
  "F3",
  "F4",
  "R",
  "NUMPAD5",
  "NUMPAD7",
  "NUMPAD8",
  "§"
}

function InMeleeRange()
  return IsSpellInRange("Shield Slam", "target") == 1;
end

function RenderMultiTargetRotation()
  return RenderSingleTargetRotation();
end

function RenderSingleTargetRotation()
  actionName = GetHekiliQueue().Primary[1].actionName;
  WowCyborg_CURRENTATTACK = actionName;
  button = buttons[actionName];
  
  if UnitCanAttack("player", "target") == false then
    return false;
  end
  
  if InMeleeRange() == false then
    if InCombatLockdown() and IsCastableAtEnemyTarget("Heroic Throw", 0) then
      WowCyborg_CURRENTATTACK = "Heroic Throw";
      return SetSpellRequest(heroicThrow);
    end
  end


  if button ~= nil then
    return SetSpellRequest(button);
  end
  
  WowCyborg_CURRENTATTACK = "-";
  return SetSpellRequest(nil);
end

print("Protection warrior 2 rotation loaded");