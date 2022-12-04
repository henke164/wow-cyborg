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
buttons["gladiators_badge"] = "9";
buttons["exorcism"] = "8";
buttons["seraphim"] = "0";
buttons["shield_of_vengeance"] = "F+1";

WowCyborg_PAUSE_KEYS = {
  "F2",
  "F3",
  "F4",
  "F5",
  "F7",
  "NUMPAD1",
  "NUMPAD2",
  "NUMPAD5",
  "NUMPAD9",
  "0",
  "F",
  "R",
  "LSHIFT",
  "ESCAPE"
}

function IsMelee()
  return IsSpellInRange("Crusader Strike") == 1;
end

function RenderMultiTargetRotation()
  if WowCyborg_INCOMBAT == false then
    return SetSpellRequest(nil);
  end

  local actionName = Hekili.GetQueue().Primary[1].actionName;
  
  WowCyborg_CURRENTATTACK = actionName;
  local button = buttons[actionName];
  if actionName == "templars_verdict" and IsMelee() then
    button = "7"
  end
  
  if button ~= nil then
    return SetSpellRequest(button);
  end

  return RenderSingleTargetRotation();
end

function RenderSingleTargetRotation()
  if WowCyborg_INCOMBAT == false then
    return SetSpellRequest(nil);
  end

  local actionName = Hekili.GetQueue().Primary[1].actionName;

  WowCyborg_CURRENTATTACK = actionName;
  local button = buttons[actionName];

  if actionName == "templars_verdict" and IsMelee() == false then
    return SetSpellRequest(nil);
  end

  if button ~= nil then
    return SetSpellRequest(button);
  end

  return SetSpellRequest(nil);
end

print("Retri pala rotation loaded");