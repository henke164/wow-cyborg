--[[
  Button    Spell
]]--
local buttons = {}
buttons["summon_demonic_tyrant"] = "1";
buttons["grimoire_felguard"] = "2";
buttons["call_dreadstalkers"] = "3";
buttons["shadow_bolt"] = "4";
buttons["demonbolt"] = "5";
buttons["hand_of_guldan"] = "6";
buttons["power_siphon"] = "7";
buttons["implosion"] = "8";
buttons["blood_fury"] = "F+1";
buttons["demonic_strength"] = "9";
buttons["soul_strike"] = "0";
buttons["doom"] = "F+6";
local stopCast = "F+7";

WowCyborg_PAUSE_KEYS = {
  "LSHIFT",
  "NUMPAD1",
  "NUMPAD2",
  "NUMPAD3",
  "NUMPAD4",
  "NUMPAD5",
  "NUMPAD7",
  "F4",
  "F",
  "§"
}

function RenderMultiTargetRotation()
  if WowCyborg_INCOMBAT == false then
    return SetSpellRequest(nil);
  end

  local quaking = FindDebuff("player", "Quake");
  if quaking then
    return SetSpellRequest(nil);
  end

  local actionName = Hekili.GetQueue().Cooldowns[1].actionName;
  
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
    return SetSpellRequest(nil);
  end

  local quaking = FindDebuff("player", "Quake");
  if quaking then
    return SetSpellRequest(nil);
  end

  local actionName = Hekili.GetQueue().Primary[1].actionName;

  if actionName == "doom" then
    local doomDebuff = FindDebuff("target", "Doom");
    if doomDebuff ~= nil then
      actionName = Hekili.GetQueue().Primary[2].actionName;
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