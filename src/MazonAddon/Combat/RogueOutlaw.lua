--[[
NAME: Rouge Outlaw
ICON: ability_rogue_waylay
]]--
local buttons = {}
buttons["roll_the_bones"] = "1";
buttons["blade_flurry"] = "2";
buttons["between_the_eyes"] = "3";
buttons["sinister_strike"] = "4";
buttons["dispatch"] = "5";
buttons["pistol_shot"] = "6";
buttons["slice_and_dice"] = "7";
buttons["blade_rush"] = "8";
buttons["ambush"] = "9";
buttons["keep_it_rolling"] = "0";
buttons["echoing_reprimand"] = "8";
buttons["vanish"] = "F+7";
buttons["adrenaline_rush"] = "F+2";
buttons["shadow_dance"] = "F+8";
buttons["shiv"] = "F+6";
buttons["killing_spree"] = "F+8";
buttons["ghostly_strike"] = "F+9";
buttons["manic_grieftorch"] = "F+6";

WowCyborg_PAUSE_KEYS = {
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
  if Hekili.DB.profile.toggles.cooldowns.value == false then
    Hekili:FireToggle("cooldowns");
    Hekili:Query("UI").Minimap:RefreshDataText();
  end
  return RenderRotation(true);
end

function RenderSingleTargetRotation()
  if Hekili.DB.profile.toggles.cooldowns.value == true then
    Hekili:FireToggle("cooldowns");
    Hekili:Query("UI").Minimap:RefreshDataText();
  end
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