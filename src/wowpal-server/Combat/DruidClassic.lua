--[[
  Button    Spell
  1         Heal player 1
  2         Self heal
  3         Assist
]]--

local heal = "1";
local heal2 = "2";
local assist = "3";

-- Multi target
function RenderMultiTargetRotation()
  return RenderSingleTargetRotation();
end

-- Single target
function RenderSingleTargetRotation()
  local hp1 = GetHealthPercentage("party1");
  if hp1 < 70 then
    WowCyborg_CURRENTATTACK = "Heal player one";
    return SetSpellRequest(heal);
  end

  local hp2 = GetHealthPercentage("player");
  if hp2 < 70 then
    WowCyborg_CURRENTATTACK = "Self heal";
    return SetSpellRequest(heal2);
  end
  
  WowCyborg_CURRENTATTACK = "-";
  return SetSpellRequest(nil);
end

print("Classic druid rotation loaded");