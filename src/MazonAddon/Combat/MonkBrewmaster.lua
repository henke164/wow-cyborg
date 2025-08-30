--[[
NAME: Monk Brewmaster
ICON: spell_monk_brewmaster_spec
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
buttons["chi_burst"] = "0";
buttons["touch_of_death"] = "F+2";
buttons["celestial_brew"] = "F+5";
buttons["purifying_brew"] = "F+6";
buttons["fortifying_brew"] = "F+7";
buttons["vivify"] = "F+9";
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
  "F4",
  "F",
  "§"
}

function RenderMultiTargetRotation()
  return RenderRotation();
end

function RenderSingleTargetRotation()
  if UnitChannelInfo("player") or UnitCastingInfo("player") then
    WowCyborg_CURRENTATTACK = "-";
    return SetSpellRequest(nil);
  end

  actionName = GetHekiliQueue().Primary[1].actionName;
  WowCyborg_CURRENTATTACK = actionName;
  button = buttons[actionName];
  
  if (GetSpellCharges("Purifying Brew") == 0 and IsCastable("Celestial Brew", 0) == false and IsCastable("Black Ox Brew", 0)) then
    WowCyborg_CURRENTATTACK = "Black Ox Brew";
    return SetSpellRequest("9");
  end

  if (button ~= nil) then
    local replaced = string.gsub(actionName, "_", " ");
    if (IsCastable(replaced, 0)) then
      if
        actionName == "blackout_kick" or
        actionName == "rising_sun_kick"
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

      WowCyborg_CURRENTATTACK = actionName;
      return SetSpellRequest(button);
    end
  end
end

function IsMelee()
  if UnitCanAttack("player", "target") == false then
    return false;
  end

  if TargetIsAlive() == false then
    return false;
  end;

  return IsSpellInRange("Rising Sun Kick", "target");
end

print("BMMonk rotation loaded");
