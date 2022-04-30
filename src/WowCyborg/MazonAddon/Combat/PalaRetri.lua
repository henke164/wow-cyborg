--[[
  Button    Spell
]]--

local buttons = {}
buttons["wake_of_ashes"] = "1";
buttons["blade_of_justice"] = "2";
buttons["judgment"] = "3";
buttons["hammer_of_wrath"] = "4";
buttons["crusader_strike"] = "5";
buttons["templars_verdict"] = "6";
buttons["divine_storm"] = "7";
buttons["consecration"] = "9";

WowCyborg_PAUSE_KEYS = {
  "F1",
  "F2",
  "F3",
  "F4",
  "F5",
  "F7",
  "0",
  "F",
  "R",
  "LSHIFT",
  "NUMPAD1",
  "NUMPAD2",
  "NUMPAD5",
  "NUMPAD7",
  "NUMPAD8",
  "NUMPAD9",
  "ESCAPE",
  "NUMPAD5"
}

function IsMelee()
  return IsSpellInRange("Crusader Strike") == 1;
end

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

print("Retri pala rotation loaded");