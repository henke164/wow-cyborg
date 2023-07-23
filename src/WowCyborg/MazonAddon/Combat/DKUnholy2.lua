--[[
  Button    Spell
  1   deathsCaress
  2   marrowrend
  3   bloodboil
  4   deathstrike
  5   heartstrike
  6   bonestorm
]]--

local buttons = {}

buttons["unholy_blight"] = "1";
buttons["outbreak"] = "2";
buttons["festering_strike"] = "3";
buttons["scourge_strike"] = "4";
buttons["dark_transformation"] = "5";
buttons["death_coil"] = "6";
buttons["death_strike"] = "7";
buttons["apocalypse"] = "8";
buttons["shackle_the_unworthy"] = "9";
buttons["empowered_rune_weapon"] = "F+3";

local dancingRuneWeapon = "F+7";
local vampiricBlood = "F+8";

WowCyborg_PAUSE_KEYS = {
  "F1",
  "F2",
  "F3",
  "F4",
  "F10",
  "NUMPAD1",
  "NUMPAD5"
}

function RenderMultiTargetRotation()
  return RenderRotation();
end

function RenderSingleTargetRotation()
  return RenderRotation();
end

function RenderRotation()
  if WowCyborg_INCOMBAT == false then
    return SetSpellRequest(nil);
  end

  actionName = GetHekiliQueue().Primary[1].actionName;
  WowCyborg_CURRENTATTACK = actionName;
  button = buttons[actionName];
  if button ~= nil then
    return SetSpellRequest(button);
  end
  return SetSpellRequest(nil);
end

print("DK blood rotation loaded");