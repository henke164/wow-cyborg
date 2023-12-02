--[[
  Button    Spell
]]--
local buttons = {}
buttons["blackout_kick"] = "1";
buttons["keg_smash"] = "2";
buttons["breath_of_fire"] = "3";
buttons["rushing_jade_wind"] = "4";
buttons["tiger_palm"] = "5";
buttons["spinning_crane_kick"] = "6";
buttons["rising_sun_kick"] = "7";
buttons["exploding_keg"] = "8";
buttons["black_ox_brew"] = "9";
buttons["chi_wave"] = "0";
buttons["celestial_brew"] = "F+5";
buttons["purifying_brew"] = "F+6";
buttons["fortifying_brew"] = "F+7";
buttons["expel_harm"] = "F+8";

WowCyborg_PAUSE_KEYS = {
  "F2",
  "F3",
  "F4",
  "R",
  "LSHIFT",
  "NUMPAD1",
  "NUMPAD2",
  "NUMPAD3",
  "NUMPAD4",
  "NUMPAD5",
  "NUMPAD7",
  "NUMPAD8",
  "F",
  "§"
}

function RenderMultiTargetRotation()
  return RenderRotation(true);
end

function RenderSingleTargetRotation()
  return RenderRotation();
end

function RenderRotation()
  if UnitChannelInfo("player") or UnitCastingInfo("player") then
    WowCyborg_CURRENTATTACK = "-";
    return SetSpellRequest(nil);
  end

  actionName = GetHekiliQueue().Primary[1].actionName;
  WowCyborg_CURRENTATTACK = actionName;
  button = buttons[actionName];
  
  if
    actionName == "blackout_kick" or
    actionName == "rising_sun_kick" or
    actionName == "tiger_palm" or
    actionName == "breath_of_fire"
  then
    if IsMelee() == false then
      WowCyborg_CURRENTATTACK = "Out of range";
      return SetSpellRequest(nil);
    end
  end

  if actionName == "chi_wave" then
    if IsCastableAtEnemyTarget("Chi Wave", 0) == false then
      WowCyborg_CURRENTATTACK = "Out of range";
      return SetSpellRequest(nil);
    end
  end

  if button ~= nil then
    return SetSpellRequest(button);
  end
end

function IsMelee()
  if UnitCanAttack("player", "target") == false then
    return false;
  end

  if TargetIsAlive() == false then
    return false;
  end;

  return true;
end

print("Brewmaster rotation loaded");