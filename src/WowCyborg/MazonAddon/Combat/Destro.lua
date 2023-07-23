--[[
  Button    Spell
]]--
local buttons = {}
buttons["incinerate"] = "2";
buttons["conflagrate"] = "3";
buttons["cataclysm"] = "1";
buttons["immolate"] = "4";
buttons["channel_demonfire"] = "5";
buttons["soul_rot"] = "6";
buttons["chaos_bolt"] = "7";
buttons["dark_soul_instability"] = "F+1";
buttons["havoc"] = "F+2";
buttons["rain_of_fire"] = "8";
local stopCast = "F+7";

WowCyborg_PAUSE_KEYS = {
  "LSHIFT",
  "5",
  "NUMPAD1",
  "NUMPAD2",
  "NUMPAD3",
  "NUMPAD4",
  "NUMPAD5",
  "F2",
  "F4",
  "F",
  "§"
}

local doRainOfFireUntil = 0;

function doRainOfFire()
  return doRainOfFireUntil > GetTime();
end

function RenderMultiTargetRotation()
  Hekili.DB.profile.toggles.mode.value = "aoe";
  
  if WowCyborg_INCOMBAT == false and doRainOfFire() == false then
    return SetSpellRequest(nil);
  end

  if doRainOfFire() == true then
    local shards = UnitPower("player", 7)
    local rorBuff = FindBuff("player", "Ritual of Ruin");
    local castingInfo, _, _, _, endTime = UnitCastingInfo("player");

    if shards >= 3 or rorBuff ~= nil then
      if castingInfo ~= nil and ((endTime / 1000) - GetTime()) < 0.5 then
        WowCyborg_CURRENTATTACK = "Cancel";
        return SetSpellRequest(stopCast);
      end
      
      WowCyborg_CURRENTATTACK = "Rain of fire";
      return SetSpellRequest("8");
    end

    local immolateDot, immolateDotTL = FindDebuff("target", "Immolate");
    if (immolateDot ~= nil and immolateDotTL > 5) then
      if IsCastableAtEnemyTarget("Conflagrate", 500) then
        WowCyborg_CURRENTATTACK = "Conflagrate";
        return SetSpellRequest("3");
      end

      if IsCastableAtEnemyTarget("Incinerate", 750) then
        WowCyborg_CURRENTATTACK = "Incinerate";
        return SetSpellRequest("2");
      end
    end
  end

  return RenderRotation();
end

function RenderSingleTargetRotation()
  Hekili.DB.profile.toggles.mode.value = "single";
  
  
  if UnitChannelInfo("player") then
    WowCyborg_CURRENTATTACK = "-";
    return SetSpellRequest(nil);
  end

  if WowCyborg_INCOMBAT == false and doRainOfFire() == false then
    return SetSpellRequest(nil);
  end

  local rorBuff = FindBuff("player", "Ritual of Ruin");
  if rorBuff ~= nil then
    WowCyborg_CURRENTATTACK = "Chaos Bolt";
    return SetSpellRequest("7");
  end

  return RenderRotation();
end


function RenderRotation()
  local quaking = FindDebuff("player", "Quake");
  if quaking then
    return SetSpellRequest(nil);
  end

  local actionName = GetHekiliQueue().Cooldowns[1].actionName;
  WowCyborg_CURRENTATTACK = actionName;
  local button = buttons[actionName];
  
  actionName = GetHekiliQueue().Primary[1].actionName;
  WowCyborg_CURRENTATTACK = actionName;
  button = buttons[actionName];
  
  for nextAction = 2,3 do
    if actionName == "immolate" then
      local immolateDot, immolateDotTL = FindDebuff("target", "Immolate");
      if (immolateDot ~= nil and immolateDotTL > 5) then
        actionName = GetHekiliQueue().Primary[nextAction].actionName;
        WowCyborg_CURRENTATTACK = actionName;
        button = buttons[actionName];
      end
    else
      break;
    end
  end

  if actionName == "rain_of_fire" then
    if doRainOfFire() == false then
      return SetSpellRequest("9");
    end
  end
  
  if button ~= nil then
    return SetSpellRequest(button);
  end
end

local frame = CreateFrame("Frame");

frame:SetPropagateKeyboardInput(true);
frame:EnableKeyboard(true);
frame:SetScript("OnKeyDown", function(self, key)
  if key == "NUMPAD1" then
    doRainOfFireUntil = GetTime() + 0.5;
  end
end)

frame:SetScript("OnChar", function(self, key)
  if key == "1" then
    doRainOfFireUntil = GetTime() + 0.5;
  end
end)

print("Destro lock rotation loaded!!");