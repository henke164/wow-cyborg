--[[
NAME: Rogue Subtlety
ICON: ability_stealth
]]--
local buttons = {}
buttons["shadow_blades"] = "1";
buttons["slice_and_dice"] = "2";
buttons["rupture"] = "3";
buttons["symbols_of_death"] = "4";
buttons["shadowstrike"] = "5";
buttons["shadow_dance"] = "5";
buttons["backstab"] = "6";
buttons["gloomblade"] = "6";
buttons["eviscerate"] = "7";
buttons["cold_blood"] = "8";
buttons["black_powder"] = "9";
buttons["shuriken_storm"] = "0";
buttons["shuriken_tornado"] = "F+6";
buttons["vanish"] = "F+7";
buttons["secret_technique"] = "F+8";
buttons["thistle_tea"] = "F+9";

WowCyborg_PAUSE_KEYS = {
  "F2",
  "F3",
  "R",
  "LSHIFT",
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
  return RenderRotation(true);
end

function RenderSingleTargetRotation()
  return RenderRotation(false);
end

function RenderRotation(holdBurst)
  if IsMelee() == false then
    WowCyborg_CURRENTATTACK = "Out of range";
    return SetSpellRequest(nil);
  end

  if UnitChannelInfo("player") or UnitCastingInfo("player") then
    WowCyborg_CURRENTATTACK = "-";
    return SetSpellRequest(nil);
  end

  local actionName = GetHekiliQueue().Cooldowns[1].actionName;
  WowCyborg_CURRENTATTACK = actionName;
  local button = buttons[actionName];
  local ready = true;

  if button ~= nil then    
    if actionName == "shadow_blades" then
      if IsCastableAtEnemyTarget("Shadow Blades", 0) == false or holdBurst == true then
        ready = false;
      end
    end

    if actionName == "shadow_dance" then
      if IsCastableAtEnemyTarget("Shadow Dance", 0) == false or holdBurst == true then
        ready = false;
      end
    end
    
    if actionName == "thistle_tea" then
      if IsCastable("Thistle Tea", 0) == false then
        ready = false;
      end
    end

    if actionName == "vanish" then
      if IsCastable("Vanish", 0) == false then
        ready = false;
      end
    end

    if ready then
      return SetSpellRequest(button);
    end
  end

  actionName = GetHekiliQueue().Primary[1].actionName;
  
  if holdBurst == true then
    if actionName == "symbols_of_death" then
      actionName = GetHekiliQueue().Primary[2].actionName;
    end

    if actionName == "cold_blood" then
      actionName = GetHekiliQueue().Primary[2].actionName;
    end

    if actionName == "secret_technique" then
      actionName = GetHekiliQueue().Primary[2].actionName;
    end

    if actionName == "secret_technique" then
      actionName = GetHekiliQueue().Primary[3].actionName;
    end
  end

  local points = GetComboPoints("player", "target");
  if actionName == "shuriken_storm" and points > 6 then
    actionName = GetHekiliQueue().Primary[2].actionName
  end
  
  if actionName == "symbols_of_death" then
    if IsCastableAtEnemyTarget("symbols of death", 0) == false then
      actionName = GetHekiliQueue().Primary[2].actionName;
    end
  end

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