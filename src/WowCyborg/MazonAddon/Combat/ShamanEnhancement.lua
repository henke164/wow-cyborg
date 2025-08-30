--[[  ]]--
local buttons = {}
buttons["stormstrike"] = "1";
buttons["lava_lash"] = "2";
buttons["crash_lightning"] = "3";
buttons["lightning_bolt"] = "4";
buttons["fire_nova"] = "5";
buttons["flame_shock"] = "R";
buttons["frost_shock"] = "F";
buttons["feral_spirit"] = "6";
buttons["elemental_blast"] = "7";
buttons["ice_strike"] = "8";
buttons["chain_lightning"] = "9";
buttons["primordial_wave"] = "D";
buttons["doom_winds"] = "A";


WowCyborg_PAUSE_KEYS = {
  "SHIFT"
  "§",
  "1",
  "2",
  "3",
  "4",
  "R",
  "F",
  "NUMPAD1",
  "NUMPAD2",
  "NUMPAD3",
  "NUMPAD4",
  "NUMPAD5",
  "NUMPAD6",
  "NUMPAD7",
  "NUMPAD8",
  "NUMPAD9"
}

function IsMelee()
  return IsSpellInRange("Lava Lash", "target") == 1;
end

-- Burst
function RenderMultiTargetRotation()
  return RenderSingleTargetRotation(true);
end

-- Single
function RenderSingleTargetRotation(burst)
  Hekili.DB.profile.toggles.cooldowns.value = burst == true;
  
  local hp = GetHealthPercentage("player");
  if hp < 60 then
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
        actionName == "ascendance" 
      ) and IsMelee() then
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