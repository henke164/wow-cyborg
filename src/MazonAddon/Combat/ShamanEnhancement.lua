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
  return RenderSingleTargetRotation();
end

-- Single target
function RenderSingleTargetRotation()  
  if WowCyborg_INCOMBAT == false then
    WowCyborg_CURRENTATTACK = "-";
    return SetSpellRequest(nil);
  end

  if UnitCanAttack("player", "target") == false then
    WowCyborg_CURRENTATTACK = "-";
    return SetSpellRequest(nil);
  end

  local proc = C_Spell.GetOverrideSpell(470411) == 470057;
  if proc and IsCastableAtEnemyTarget("Flame Shock", 0) then
    WowCyborg_CURRENTATTACK = "Flame Shock";
    return SetSpellRequest(buttons["flame_shock"]);
  end

  local actionName = GetHekiliQueue().Primary[1].actionName;
  local button = buttons[actionName];
  WowCyborg_CURRENTATTACK = actionName;
  if button ~= nil then
    WowCyborg_CURRENTATTACK = actionName;
    return SetSpellRequest(button);
  end
  
  WowCyborg_CURRENTATTACK = "-";
  return SetSpellRequest(nil);
end

print("Enhancement shaman rotation loaded");