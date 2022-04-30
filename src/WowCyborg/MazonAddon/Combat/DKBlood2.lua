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

buttons["marrowrend"] = "5";
buttons["blood_boil"] = "6";
buttons["death_strike"] = "7";
buttons["heart_strike"] = "8";
buttons["shackle_the_unworthy"] = "9";

local dancingRuneWeapon = "F+7";
local vampiricBlood = "F+8";

WowCyborg_PAUSE_KEYS = {
  "1",
  "F3",
  "F4",
  "F10",
  "NUMPAD1"
}

function RenderMultiTargetRotation()
  Hekili.DB.profile.toggles.mode.value = "aoe";
  return RenderRotation();
end

function RenderSingleTargetRotation()
  Hekili.DB.profile.toggles.mode.value = "single";
  return RenderRotation();
end

function RenderRotation()
  if WowCyborg_INCOMBAT == false then
    return SetSpellRequest(nil);
  end

  local hpPercentage = GetHealthPercentage("player");
  if hpPercentage < 60 then
    if IsCastableAtEnemyTarget("Dancing Rune Weapon", 0) then
      WowCyborg_CURRENTATTACK = "Dancing Rune Weapon";
      return SetSpellRequest(dancingRuneWeapon);
    end
  end
  
  if hpPercentage < 50 then
    if IsCastableAtEnemyTarget("Vampiric blood", 0) then
      WowCyborg_CURRENTATTACK = "Vampiric blood";
      return SetSpellRequest(vampiricBlood);
    end
  end
  
  actionName = Hekili.GetQueue().Primary[1].actionName;
  WowCyborg_CURRENTATTACK = actionName;
  button = buttons[actionName];
  if button ~= nil then
    return SetSpellRequest(button);
  end
  return SetSpellRequest(nil);
end

print("DK blood rotation loaded");