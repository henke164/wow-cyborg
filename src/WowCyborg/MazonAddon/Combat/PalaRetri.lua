--[[
  Button    Spell
]]--
local buttons = {}
buttons["wake_of_ashes"] = "1";
buttons["radiant_decree"] = "1";
buttons["blade_of_justice"] = "2";
buttons["judgment"] = "3";
buttons["hammer_of_wrath"] = "4";
buttons["crusader_strike"] = "5";
buttons["templar_strike"] = "5";
buttons["templar_slash"] = "5";
buttons["templars_verdict"] = "6";
buttons["final_verdict"] = "6";
buttons["divine_storm"] = "7";
buttons["consecration"] = "9";
buttons["execution_sentence"] = "9";
buttons["exorcism"] = "8";
buttons["seraphim"] = "0";
buttons["divine_toll"] = "8";
buttons["shield_of_vengeance"] = "F+1";
buttons["crusade"] = "F+2";
buttons["divine_toll"] = "8";

WowCyborg_PAUSE_KEYS = {
  "F1",
  "F2",
  "F3",
  "F4",
  "F5",
  "F7",
  "NUMPAD1",
  "NUMPAD2",
  "NUMPAD3",
  "NUMPAD5",
  "NUMPAD8",
  "NUMPAD9",
  "F",
  "R",
  "LSHIFT",
  "ESCAPE"
}

function IsMelee()
  return IsSpellInRange("Rebuke", "target") == 1;
end

function InAttackRange()
  return IsSpellInRange("Blade of Justice", "target") == 1;
end

function RenderMultiTargetRotation()
  local targetName = UnitName("target");
  if targetName == "Incorporeal Being" then
    WowCyborg_CURRENTATTACK = "Turn Evil";
    return SetSpellRequest(9);
  end

  local actionName = GetHekiliQueue().Cooldowns[1].actionName;
  local button = buttons[actionName];
  if button ~= nil then
    local replaced = string.gsub(actionName, "_", " ");
    if (IsCastable(replaced, 0)) then
      WowCyborg_CURRENTATTACK = actionName;
      return SetSpellRequest(button);
    end
  end

  return RenderSingleTargetRotation(true);
end

function RenderSingleTargetRotation()
  if UnitChannelInfo("player") then
    WowCyborg_CURRENTATTACK = "-";
    return SetSpellRequest(nil);
  end

  local targetName = UnitName("target");
  if targetName == "Incorporeal Being" then
    WowCyborg_CURRENTATTACK = "Turn Evil";
    return SetSpellRequest(9);
  end

  if UnitCanAttack("player", "target") == false then
    WowCyborg_CURRENTATTACK = "-";
    return SetSpellRequest(nil);
  end

  local actionName = GetHekiliQueue().Primary[1].actionName;

  local nearbyEnemies = GetNearbyEnemyCount();
  
  if nearbyEnemies > 3 and actionName == "templars_verdict" then
    actionName = "divine_storm";
  end
  
  if actionName == "templars_verdict" and InAttackRange() == false then
    return SetSpellRequest(nil);
  end
  
  if actionName == "wake_of_ashes" then
    if IsCastable("Avenging Wrath", 0) or IsMelee() == false then
      actionName = GetHekiliQueue().Primary[2].actionName;
      if (
        actionName == "divine_storm" or
        actionName == "templars_verdict"
      ) then
        local holyPower = UnitPower("player", 9);
        if holyPower < 4 then
          actionName = GetHekiliQueue().Primary[3].actionName;
        end
      end
    end
  end

  local button = buttons[actionName];
  WowCyborg_CURRENTATTACK = actionName;
  if button ~= nil then
    if (CanCast(actionName)) then
      WowCyborg_CURRENTATTACK = actionName;
      return SetSpellRequest(button);
    end
  end

  if IsCastableAtEnemyTarget("Templar Strike", 0) then
    WowCyborg_CURRENTATTACK = "Templar Strike";
    return SetSpellRequest("5");
  end

  WowCyborg_CURRENTATTACK = "";
  return SetSpellRequest(nil);
end

function CanCast(actionName)
  local spellName = GetSpellName(actionName);

  if (spellName == "templars verdict") then
    spellName = "templar's verdict";
  end

  if (
    actionName == "divine_storm" or
    actionName == "templars_verdict" or
    actionName == "wake_of_ashes" or
    actionName == "blade_of_justice" or
    actionName == "judgment" or
    actionName == "hammer_of_wrath" or
    actionName == "crusader_strike" or
    actionName == "consecration" or
    actionName == "crusade" or
    actionName == "divine_toll"
  ) then
    if IsCastableAtEnemyTarget(spellName, 0) then
      return true;
    end
  else
    if (IsCastable(spellName, 0)) then
      return true;
    end
  end
  return false;
end

function GetSpellName(actionName)
  return string.gsub(actionName, "_", " ");
end

print("Retri pala rotation loaded");