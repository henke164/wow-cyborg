--[[
  Button    Spell
  1         Blade Dance
  2         Chaos Strike
  3         Execute
  4         Eye Beam
  5         Overpower
]]--

local buttons = {}
buttons["spirit_bomb"] = "1";
buttons["fracture"] = "2";
buttons["soul_cleave"] = "3";
buttons["immolation_aura"] = "4";
buttons["sigil_of_flame"] = "5";
buttons["demon_spikes"] = "6";
buttons["throw_glaive"] = "7";
buttons["fiery_brand"] = "8";
buttons["sigil_of_spite"] = "9";
buttons["soul_carver"] = "F+7";
buttons["fel_devastation"] = "F+6";


local spiritBomb = "1";
local fracture = "2";
local soulCleave = "3";
local immolationAura = "4";
local sigilOfFlame = "5";
local demonSpikes = "6";
local glaive = "7";
local fieryBrand = "8";

WowCyborg_PAUSE_KEYS = {
  "F2",
  "F",
  "F3",
  "F4",
  "F7",
  "0",
  "R",
  "F10",
  "LSHIFT",
  "NUMPAD1",
  "NUMPAD5",
  "NUMPAD7",
  "NUMPAD8",
  "NUMPAD9"
}

function RenderMultiTargetRotation()
  return RenderSingleTargetRotation()
end

function RenderSingleTargetRotation()
  if UnitCanAttack("player", "target") == false then
    return SetSpellRequest(nil);
  end

  if IsSpellInRange("target", "Spirit Bomb") == false then
    return SetSpellRequest(nil);
  end

  if UnitChannelInfo("player") then
    WowCyborg_CURRENTATTACK = "-";
    return SetSpellRequest(nil);
  end
  
  local actionName = GetHekiliQueue().Primary[1].actionName;

  local button = buttons[actionName];
  WowCyborg_CURRENTATTACK = actionName;
  if button ~= nil then
    WowCyborg_CURRENTATTACK = actionName;
    return SetSpellRequest(button);
  end

  WowCyborg_CURRENTATTACK = "-";
  return SetSpellRequest(nil);
end

function InMeleeRange()
  return IsSpellInRange("Disrupt", "target") == 1;
end

print("Demon hunter tank rotation loaded");