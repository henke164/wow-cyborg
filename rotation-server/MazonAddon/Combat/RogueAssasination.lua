--[[
  Button    Spell
]]--
local buttons = {}
buttons["garrote"] = "1";
buttons["slice_and_dice"] = "2";
buttons["rupture"] = "3";
buttons["kingsbane"] = "4";
buttons["deathmark"] = "5";
buttons["envenom"] = "6";
buttons["mutilate"] = "7";
buttons["ambush"] = "7";
buttons["fan_of_knives"] = "8";
buttons["shiv"] = "9";
buttons["amplifying_poison"] = "F+5";
buttons["shadow_dance"] = "F+6";
buttons["poisoned_knife"] = "F+7";
buttons["thistle_tea"] = "F+8";
buttons["ghostly_strike"] = "F+9";
buttons["manic_grieftorch"] = "F+9";

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
  return RenderRotation();
end

function RenderRotation(skipVanish)
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
  if actionName ~= nil then
    if button ~= nil then
      local ready = true;

      local ambushAvail = IsCastable("Ambush", 0);
      if actionName == "vanish" then
        local vStarted, vTotalCd = GetSpellCooldown("Vanish");
        local vCd = vStarted + vTotalCd - GetTime();
        
        if vCd > 0 then
          ready = false;
        end

        if ambushAvail == false then
          ready = false;
        end
      end
      
      local sdStarted, sdTotalCd = GetSpellCooldown("Shadow Dance");
      local sdCd = sdStarted + sdTotalCd - GetTime();
      if actionName == "shadow_dance" then
        if sdCd > 0 then
          ready = false;
        end
      end

      if ready and skipVanish ~= true then
        return SetSpellRequest(button);
      end
    end
  end

  actionName = GetHekiliQueue().Primary[1].actionName;
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

print("Outlaw rogue rotation loaded");