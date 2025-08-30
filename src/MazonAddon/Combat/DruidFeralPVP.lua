
--[[
NAME: Druid Feral (PVP)
ICON: talentspec_druid_feral_cat
]]--
local buttons = {}
buttons["rake"] = "1";
buttons["brutal_slash"] = "2";
buttons["primal_wrath"] = "3";
buttons["ferocious_bite"] = "4";
buttons["tigers_fury"] = "5";
buttons["maim"] = "6";
buttons["shred"] = "7";
buttons["feral_frenzy"] = "8";
buttons["rip"] = "9";

buttons["lunar_inspiration"] = "F+5";
buttons["adaptive_swarm"] = "F+6";
buttons["regrowth"] = "F+7";
buttons["renewal"] = "F+9";

WowCyborg_PAUSE_KEYS = {
  "§",
  "X",
  "R",
  "NUMPAD5",
  "NUMPAD7"
}

function RenderMultiTargetRotation()
  return RenderSingleTargetRotation(true);
end

function RenderSingleTargetRotation(stun)
  if UnitChannelInfo("player") or UnitCastingInfo("player") then
    WowCyborg_CURRENTATTACK = "-";
    return SetSpellRequest(nil);
  end

  if UnitCanAttack("player", "target") == false then
    return SetSpellRequest(nil);
  end
  
  local actionName = GetHekiliQueue().Primary[1].actionName;
  local health = GetHealthPercentage("player");

  if health < 60 then
    if IsCastable("Renewal", 0) then
      WowCyborg_CURRENTATTACK = "Renewal";
      return SetSpellRequest(buttons["renewal"]);
    end
  end

  if stun == true then
    local bashed = FindDebuff("target", "Mighty Bash");
    if bashed == nil then
      local combopoints = UnitPower("player", 4)
      if combopoints == 5 then
        if IsCastableAtEnemyTarget("Maim", 0) then
          WowCyborg_CURRENTATTACK = "Maim";
          return SetSpellRequest(buttons["maim"]);
        end
      end
    end
  end

  if actionName == nil then
    WowCyborg_CURRENTATTACK = "-";
    return SetSpellRequest(nil);
  end
  
  local button = buttons[actionName];
  local replaced = string.gsub(actionName, "_", " ");
  WowCyborg_CURRENTATTACK = replaced;

  if button ~= nil then
    return SetSpellRequest(button);
  end

  return SetSpellRequest(nil);
end

print("Druid Feral (PVP) rotation loaded");
            