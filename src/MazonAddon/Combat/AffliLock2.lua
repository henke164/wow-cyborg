--[[
NAME: Warlock Affliction (PVP)
ICON: spell_shadow_unstableaffliction_3
]]--
local buttons = {}
buttons["unstable_affliction"] = "1";
buttons["wither"] = "3";
buttons["agony"] = "2";
buttons["corruption"] = "3";
buttons["malefic_rapture"] = "4";
buttons["summon_glade"] = "5";
buttons["vile_taint"] = "6";
buttons["phantom_singularity"] = "6";
buttons["haunt"] = "7";
buttons["implosion"] = "8";
buttons["blood_fury"] = "F+1";
buttons["demonic_strength"] = "9";
buttons["seed_of_corruption"] = "0";  
buttons["drain_soul"] = "F+7";
buttons["shadow_bolt"] = "F+7";
buttons["summon_darkglare"] = "5";
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
  "NUMPAD9",
  "R",
  "F4",
  "F",
  "§"
}

function RenderMultiTargetRotation()
  return RenderSingleTargetRotation(true);
end

function RenderSingleTargetRotation(slow)
  local speed = GetUnitSpeed("player");
  local actionName = GetHekiliQueue().Primary[1].actionName;
  local targetHp = GetHealthPercentage("target");
  if targetHp == 0 then
    return SetSpellRequest(nil);
  end

  if UnitCanAttack("player", "target") == false then
    return SetSpellRequest(nil);
  end
  
  if actionName == "drain_soul" and UnitChannelInfo("player") ~= nil then
    return SetSpellRequest(nil);
  end

  if slow == true then
    local shards = UnitPower("player", 7);
    local slowDebuff = FindDebuff("target", "Curse of Exhaustion");
    local cow = FindDebuff("target", "Curse of Weakness");
    if slowDebuff == nil and cow == nil and shards > 0 then
    return SetSpellRequest("F+8");
    end
  end

  local bfury = FindBuff("player", "Blood Fury");
  if bfury then
    if IsCastableAtEnemyTarget("Phantom Singularity", 0) then
      WowCyborg_CURRENTATTACK = "Phantom Singularity";
      return SetSpellRequest(buttons["phantom_singularity"]);
    end
    
    if IsCastable("Summon Darkglare", 0) then
      WowCyborg_CURRENTATTACK = "Summon Darkglare";
      return SetSpellRequest(buttons["summon_darkglare"]);
    end
  end
  
  if speed > 0 then
    local nightfall = FindBuff("player", "Nightfall");
    if nightfall then
      if IsCastableAtEnemyTarget("Shadow Bolt", 0) then
        WowCyborg_CURRENTATTACK = "Shadow Bolt";
        return SetSpellRequest(buttons["shadow_bolt"]);
      end
    end

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

  WowCyborg_CURRENTATTACK = actionName;
  local button = buttons[actionName];
  
  if button ~= nil then
    return SetSpellRequest(button);
  end

  return SetSpellRequest(nil);
end

print("Affli lock pvp rotation loaded");