--[[
  Button    Spell
]]--

local buttons = {}

buttons["serpent_sting"] = "1";
buttons["wildfire_bomb"] = "2";
buttons["raptor_strike"] = "3";
buttons["carve"] = "4";
buttons["kill_command"] = "5";
buttons["kill_shot"] = "6";
buttons["scars_of_fraternal_strife"] = "7";

WowCyborg_PAUSE_KEYS = {
  "F1",
  "F3",
  "F4",
  "F8",
  "F10",
  "NUMPAD1",
  "NUMPAD5"
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

  if IsCastableAtEnemyTarget("Serpent Sting", 0) then
    actionName = Hekili.GetQueue().Primary[1].actionName;
    if actionName == "resonating_arrow" then
      actionName = Hekili.GetQueue().Primary[2].actionName;
    end

    WowCyborg_CURRENTATTACK = actionName;
    button = buttons[actionName];
    if button ~= nil then
      return SetSpellRequest(button);
    end
  end

  return SetSpellRequest(nil);
end

print("Survhunter rotation loaded");