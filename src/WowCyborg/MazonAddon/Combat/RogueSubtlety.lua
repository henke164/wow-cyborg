--[[
  Button    Spell
]]--
local buttons = {}
buttons["shadow_blades"] = "1";
buttons["slice_and_dice"] = "2";
buttons["rupture"] = "3";
buttons["symbols_of_death"] = "4";
buttons["shadowstrike"] = "5";
buttons["shadow_dance"] = "5";
buttons["backstab"] = "6";
buttons["eviscerate"] = "7";
buttons["flagellation"] = "8";
buttons["black_powder"] = "9";
buttons["shuriken_storm"] = "0";
buttons["shuriken_tornado"] = "F+6";
buttons["vanish"] = "F+7";

WowCyborg_PAUSE_KEYS = {
  "F2",
  "F3",
  "R",
  "LSHIFT",
  "NUMPAD2",
  "NUMPAD3",
  "NUMPAD4",
  "NUMPAD5",
  "F4",
  "F",
  "§"
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
  if IsMelee() == false then
    WowCyborg_CURRENTATTACK = "Out of range";
    return SetSpellRequest(nil);
  end

  local actionName = Hekili.GetQueue().Cooldowns[1].actionName;
  WowCyborg_CURRENTATTACK = actionName;
  local button = buttons[actionName];
  
  if button ~= nil then
    local ready = true;
    if actionName == "shuriken_tornado" then
      if IsCastableAtEnemyTarget("Shuriken Tornado", 0) == false then
        ready = false;
      end
    end
    
    if actionName == "symbols_of_death" then
      if IsCastableAtEnemyTarget("Symbols of Death", 0) == false then
        ready = false;
      end
    end
    
    if actionName == "shadow_blades" then
      if IsCastableAtEnemyTarget("Shadow Blades", 0) == false then
        ready = false;
      end
    end

    if ready then
      return SetSpellRequest(button);
    end
  end

  actionName = Hekili.GetQueue().Primary[1].actionName;
  WowCyborg_CURRENTATTACK = actionName;
  button = buttons[actionName];
  
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

  return IsSpellInRange("Eviscerate") == 1;
end

print("Sub rogue rotation loaded");