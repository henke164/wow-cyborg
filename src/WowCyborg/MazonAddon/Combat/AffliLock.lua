--[[
  Button    Spell
]]--
local buttons = {}
buttons["unstable_affliction"] = "1";
buttons["agony"] = "2";
buttons["corruption"] = "3";
buttons["malefic_rapture"] = "4";
buttons["siphon_life"] = "5";
buttons["vile_taint"] = "6";
buttons["haunt"] = "7";
buttons["implosion"] = "8";
buttons["blood_fury"] = "F+1";
buttons["demonic_strength"] = "9";
buttons["seed_of_corruption"] = "0";  
buttons["drain_soul"] = "F+7";
buttons["summon_darkglare"] = "F+8";
stopCast = "F+8";

WowCyborg_PAUSE_KEYS = {
  "LSHIFT",
  "F2",
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

function RenderSingleTargetRotation(burst)
  if WowCyborg_INCOMBAT == false then
    --return SetSpellRequest(nil);
  end

  if UnitCanAttack("player", "target") == false then
    return SetSpellRequest(nil);
  end

  local speed = GetUnitSpeed("player");
  local cooldown = GetHekiliQueue().Cooldowns[1];

  if burst and cooldown.wait ~= nil and cooldown.wait == 0 and cooldown.actionName ~= "soul_rot" then
    actionName = cooldown.actionName;
  else
    actionName = GetHekiliQueue().Primary[1].actionName;
  end

  local quaking = FindDebuff("player", "Quake");
  if quaking then
    if actionName == "unstable_affliction" or actionName == "malefic_rapture" then
      --return SetSpellRequest(nil);
    end
  end

  if speed > 0 then
    local corruptionDebuff = FindDebuff("target", "Corruption");
    local agonyDebuff, agonyTl, agonyStacks = FindDebuff("target", "Agony");
    if agonyDebuff == nil or agonyTl < 8 then
      if IsCastableAtEnemyTarget("Agony", 0) then
        WowCyborg_CURRENTATTACK = "Agony";
        return SetSpellRequest(buttons["agony"]);
      end
    end
    
    if corruptionDebuff == nil then
      if IsCastableAtEnemyTarget("Corruption", 0) then
        WowCyborg_CURRENTATTACK = "Corruption";
        return SetSpellRequest(buttons["corruption"]);
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