--[[
NAME: Shaman Enhancement
ICON: spell_shaman_improvedstormstrike
]]--
local buttons = {}
buttons["stormstrike"] = "F+5";
buttons["flame_shock"] = "9";
buttons["lava_lash"] = "F+7";
buttons["lightning_bolt"] = "F+8";
buttons["crash_lightning"] = "5";
buttons["chain_lightning"] = "6";
buttons["frost_shock"] = "7";
buttons["primordial_wave"] = "0";
buttons["tempest"] = "F+8";

buttons["doom_winds"] = "F+2";
buttons["fire_nova"] = "8";
buttons["elemental_blast"] = "F+9";

WowCyborg_PAUSE_KEYS = {
}

function IsMelee()
  return IsSpellInRange("Lava Lash", "target") == 1;
end

-- Multi target
function RenderMultiTargetRotation()
  return RenderSingleTargetRotation(true);
end

-- Single
function RenderSingleTargetRotation(burst)
  Hekili.DB.profile.toggles.cooldowns.value = burst == true;
  local nearbyEnemies = GetNearbyEnemyCount("Flame Shock");
  if nearbyEnemies > 0 then
    Hekili.DB.profile.specs[ 263 ].abilities.primordial_wave.targetMin = math.floor(nearbyEnemies / 2);
  end

  local hp = GetHealthPercentage("player");
  if hp < 10 then
    local maelstrom, maelstromTimeLeft, maelstromStacks = FindBuff("player", "Maelstrom Weapon");
    if maelstrom ~= nil and maelstromStacks >= 5 then
      WowCyborg_CURRENTATTACK = "Self heal";
      return SetSpellRequest(buttons["healing_surge"]);
    end
  end

  if WowCyborg_INCOMBAT == false then
    WowCyborg_CURRENTATTACK = "";
    return SetSpellRequest(nil);
  end

  local proc = C_Spell.GetOverrideSpell(470411) == 470057;
  if proc and IsCastableAtEnemyTarget("Flame Shock", 0) then
    WowCyborg_CURRENTATTACK = "Flame Shock";
    return SetSpellRequest(buttons["flame_shock"]);
  end
  if UnitCanAttack("player", "target") == false then
    WowCyborg_CURRENTATTACK = "";
    return SetSpellRequest(nil);
  end

  for attackIndex = 1,5 do
    local actionName = GetHekiliQueue().Primary[attackIndex].actionName;
    if actionName == "windstrike" then
      actionName = "stormstrike";
    end
    
    if actionName == "tempest" then
      actionName = "lightning_bolt";
    end

    local button = buttons[actionName];
    if button ~= nil then
      local replaced = string.gsub(actionName, "_", " ");

      if (
        actionName == "crash_lightning" or
        actionName == "ascendance" or
        actionName == "sundering" 
      ) and IsMelee() then
        WowCyborg_CURRENTATTACK = replaced;
        return SetSpellRequest(button);
      end

      if (
        actionName == "doom_winds" or
        actionName == "fire_nova" or
        actionName == "blood_fury" 
      ) then
        WowCyborg_CURRENTATTACK = replaced;
        return SetSpellRequest(button);
      end

      if (IsCastableAtEnemyTarget(replaced, 0)) then
        WowCyborg_CURRENTATTACK = replaced;
        return SetSpellRequest(button);
      end
    end
  end

  WowCyborg_CURRENTATTACK = "";
  return SetSpellRequest(nil);
end

print("Enhancement shaman rotation loaded");
