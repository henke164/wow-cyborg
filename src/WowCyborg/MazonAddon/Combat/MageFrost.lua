--[[
  Button    Spell
]]--
local buttons = {}
buttons["frostbolt"] = "1";
buttons["ice_lance"] = "2";
buttons["shifting_power"] = "3";
buttons["rune_of_power"] = "4";
buttons["flurry"] = "5";
buttons["blizzard"] = "6";
buttons["ice_floes"] = "7";
buttons["ice_nova"] = "8";

WowCyborg_PAUSE_KEYS = {
  "F1",
  "F2",
  "F3",
  "NUMPAD5",
  "R",
  "F",
  "§"
}

function RenderMultiTargetRotation()
  Hekili.DB.profile.toggles.mode.value = "aoe";
  if WowCyborg_INCOMBAT == false then
    return SetSpellRequest(nil);
  end

  return RenderRotation();
end

function RenderSingleTargetRotation()
  Hekili.DB.profile.toggles.mode.value = "single";
  if WowCyborg_INCOMBAT == false then
    return SetSpellRequest(nil);
  end

  return RenderRotation();
end


function RenderRotation()
  if UnitChannelInfo("player") ~= nil then
    return SetSpellRequest(nil);
  end

  local quaking = FindDebuff("player", "Quake");
  if quaking then
    return SetSpellRequest(nil);
  end

  local actionName = Hekili.GetQueue().Primary[1].actionName;
  button = buttons[actionName];

  WowCyborg_CURRENTATTACK = actionName;
  
  if actionName == "frostbolt" then
    local speed = GetUnitSpeed("player");
    if speed > 0 then
      if FindBuff("player", "Ice Floes") == nil then
        if IsCastable("Ice Floes", 0) then
          return SetSpellRequest("7");
        else
          return SetSpellRequest("8");
        end
      end
    end
  end

  if button ~= nil then
    return SetSpellRequest(button);
  end
  
  return SetSpellRequest(nil);
end

print("Mage rotation loaded");