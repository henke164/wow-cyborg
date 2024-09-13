--[[
  Button    Spell
]]--
local buttons = {}
buttons["unstable_affliction"] = "1";
buttons["wither"] = "3";
buttons["agony"] = "2";
buttons["corruption"] = "3";
buttons["malefic_rapture"] = "4";
buttons["siphon_life"] = "5";
buttons["vile_taint"] = "6";
buttons["phantom_singularity"] = "6";
buttons["haunt"] = "7";
buttons["implosion"] = "8";
buttons["blood_fury"] = "F+1";
buttons["demonic_strength"] = "9";
buttons["seed_of_corruption"] = "0";  
buttons["drain_soul"] = "F+7";
buttons["shadow_bolt"] = "F+7";
buttons["summon_darkglare"] = "F+8";
buttons["malevolence"] = "F+3";
stopCast = "F+8";

WowCyborg_PAUSE_KEYS = {
  "LSHIFT",
  "F2",
  "F3",
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
  return RenderSingleTargetRotation(true);
end

function RenderSingleTargetRotation(aoe)
  if WowCyborg_INCOMBAT == false then
    --return SetSpellRequest(nil);
  end

  if UnitCanAttack("player", "target") == false then
    return SetSpellRequest(nil);
  end

  local speed = GetUnitSpeed("player");
  local actionName = GetHekiliQueue().Primary[1].actionName;

  if aoe then
    Hekili.DB.profile.toggles.mode.value = "aoe";
  else
    Hekili.DB.profile.toggles.mode.value = "single";
  end

  local quaking = FindDebuff("player", "Quake");
  if quaking then
    if actionName == "unstable_affliction" or actionName == "malefic_rapture" then
      --return SetSpellRequest(nil);
    end
  end

  if speed > 0 then
    local corruptionDebuff = FindDebuff("target", "Wither");
    local agonyDebuff, agonyTl, agonyStacks = FindDebuff("target", "Agony");
    if agonyDebuff == nil or agonyTl < 8 then
      if IsCastableAtEnemyTarget("Agony", 0) then
        WowCyborg_CURRENTATTACK = "Agony";
        return SetSpellRequest(buttons["agony"]);
      end
    end
    
    if corruptionDebuff == nil then
      if IsCastableAtEnemyTarget("Agony", 0) then
        WowCyborg_CURRENTATTACK = "Wither";
        return SetSpellRequest(buttons["wither"]);
      end
    end
    
  end

  if actionName == "drain_soul" and UnitChannelInfo("player") ~= nil then
    return SetSpellRequest(nil);
  end

  WowCyborg_CURRENTATTACK = actionName;
  local button = buttons[actionName];
  
  if button ~= nil then
    return SetSpellRequest(button);
  end

  return SetSpellRequest(nil);
end

print("Affli lock rotation loaded");