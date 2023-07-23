--[[
  Button    Spell
]]--
local buttons = {}
buttons["power_siphon"] = "1";
buttons["demonbolt"] = "2";
buttons["call_dreadstalkers"] = "3";
buttons["shadow_bolt"] = "4";
buttons["grimoire_felguard"] = "5";
buttons["hand_of_guldan"] = "6";
buttons["summon_demonic_tyrant"] = "7";
buttons["implosion"] = "8";
buttons["blood_fury"] = "F+1";
buttons["demonic_strength"] = "9";
buttons["soul_strike"] = "0";
buttons["summon_vilefiend"] = "0";
buttons["doom"] = "F+6";
buttons["nether_portal"] = "F+7";
stopCast = "F+8";

WowCyborg_PAUSE_KEYS = {
  "LSHIFT",
  "NUMPAD1",
  "NUMPAD2",
  "NUMPAD3",
  "NUMPAD4",
  "NUMPAD5",
  "NUMPAD7",
  "R",
  "F4",
  "F",
  "§"
}

function RenderMultiTargetRotation()
  if WowCyborg_INCOMBAT == false then
    --return SetSpellRequest(nil);
  end

  local quaking = FindDebuff("player", "Quake");
  if quaking then
    return SetSpellRequest(nil);
  end

  local actionName = GetHekiliQueue().Cooldowns[1].actionName;
  
  WowCyborg_CURRENTATTACK = actionName;
  local button = buttons[actionName];
  
  if actionName == "grimoire_felguard" then
    if IsCastableAtEnemyTarget("Grimoire: Felguard", 0) == false then
      return RenderSingleTargetRotation();
    end
  end
  
  if actionName == "summon_demonic_tyrant" then
    if IsCastableAtEnemyTarget("Summon Demonic Tyrant", 0) == false then
      return RenderSingleTargetRotation();
    end
  end

  if actionName == "nether_portal" then
    if IsCastableAtEnemyTarget("Nether Portal", 0) == false then
      return RenderSingleTargetRotation();
    end
  end

  if actionName == "blood_fury" then
    if IsCastable("Blood Fury", 0) == false then
      return RenderSingleTargetRotation();
    end
  end

  if button ~= nil then
    return SetSpellRequest(button);
  end

  return RenderSingleTargetRotation();
end

function RenderSingleTargetRotation()
  if WowCyborg_INCOMBAT == false then
    --return SetSpellRequest(nil);
  end

  if UnitCanAttack("player", "target") == false then
    return SetSpellRequest(nil);
  end

  local castingInfo = UnitCastingInfo("player");
  if castingInfo == "Demonbolt" then
    WowCyborg_CURRENTATTACK = "-";
    return SetSpellRequest(stopCast);
  end
  
  local actionName = GetHekiliQueue().Primary[1].actionName;
  local quaking = FindDebuff("player", "Quake");
  if quaking then
    if actionName == "shadow_bolt" or actionName == "hand_of_guldan" then
      return SetSpellRequest(nil);
    end
  end

  if actionName == "doom" then
    local doomDebuff = FindDebuff("target", "Doom");
    if doomDebuff ~= nil then
      actionName = GetHekiliQueue().Primary[2].actionName;
    end
  end
  
  WowCyborg_CURRENTATTACK = actionName;
  local button = buttons[actionName];
  
  if button ~= nil then
    return SetSpellRequest(button);
  end

  return SetSpellRequest(nil);
end

print("Demo 2 lock rotation loaded");