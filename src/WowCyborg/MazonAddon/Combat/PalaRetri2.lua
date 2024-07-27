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
  return RenderSingleTargetRotation(true);
end

function RenderSingleTargetRotation()
  if UnitChannelInfo("player") then
    WowCyborg_CURRENTATTACK = "-";
    return SetSpellRequest(nil);
  end

  local targetHp = GetHealthPercentage("target");
  local holyPower = UnitPower("player", 9);
  local nearbyEnemies = GetNearbyEnemyCount(853); --Hammer of Justice
  local echoesOfWrath = FindBuff("player", "Echoes of Wrath");
  local empyreanLegacy = FindBuff("player", "Empyrean Legacy");
  local useHol = false;

  local holActive = C_Spell.GetOverrideSpell(387174) == 427453;
  if (holActive) then
    useHol = true;
  end

  if IsCastableAtEnemyTarget("Execution Sentence", 0) then
    WowCyborg_CURRENTATTACK = "Execution Sentence";
    return SetSpellRequest(buttons["execution_sentence"]);
  end

  if holyPower == 5 or echoesOfWrath ~= nil then
    if useHol then
      if IsCastableAtEnemyTarget("Templar's Verdict", 0) then
        --return SetSpellRequest(buttons["wake_of_ashes"]);
      end
    end

    if nearbyEnemies > 2 then
      if empyreanLegacy then
        if IsCastableAtEnemyTarget("Templar's Verdict", 0) then
          WowCyborg_CURRENTATTACK = "Templar's Verdict";
          return SetSpellRequest(buttons["templars_verdict"]);
        end
      else
        if IsCastableAtEnemyTarget("Divine Storm", 0) then
          WowCyborg_CURRENTATTACK = "Divine Storm";
          return SetSpellRequest(buttons["divine_storm"]);
        end
      end
    else
      if IsCastableAtEnemyTarget("Templar's Verdict", 0) then
        WowCyborg_CURRENTATTACK = "Templar's Verdict";
        return SetSpellRequest(buttons["templars_verdict"]);
      end
    end
  end

  if holyPower <= 2 and nearbyEnemies > 0 then
    if IsCastableAtEnemyTarget("Wake of Ashes", 0) then
      WowCyborg_CURRENTATTACK = "Wake of Ashes";
      return SetSpellRequest(buttons["wake_of_ashes"]);
    end
  end

  if IsCastableAtEnemyTarget("Judgment", 0) then
    WowCyborg_CURRENTATTACK = "Judgment";
    return SetSpellRequest(buttons["judgment"]);
  end
  
  if targetHp >= 20 or holyPower <= 3 then
    if IsCastableAtEnemyTarget("Hammer of Wrath", 0) then
      WowCyborg_CURRENTATTACK = "Hammer of Wrath";
      return SetSpellRequest(buttons["hammer_of_wrath"]);
    end
  end

  if IsCastableAtEnemyTarget("Blade of Justice", 0) then
    WowCyborg_CURRENTATTACK = "Blade of Justice";
    return SetSpellRequest(buttons["blade_of_justice"]);
  end

  if useHol == false then
    if nearbyEnemies > 2 then
      if holyPower >= 3 then
        if empyreanLegacy then
          if IsCastableAtEnemyTarget("Templar's Verdict", 0) then
            WowCyborg_CURRENTATTACK = "Templar's Verdict";
            return SetSpellRequest(buttons["templars_verdict"]);
          end
        else
          if IsCastableAtEnemyTarget("Divine Storm", 0) then
            WowCyborg_CURRENTATTACK = "Divine Storm";
            return SetSpellRequest(buttons["divine_storm"]);
          end
        end
      end
    else
      if holyPower == 4 then
        if IsCastableAtEnemyTarget("Templar's Verdict", 0) then
          WowCyborg_CURRENTATTACK = "Templar's Verdict";
          return SetSpellRequest(buttons["templars_verdict"]);
        end
      end
    end
  end

  WowCyborg_CURRENTATTACK = "";
  return SetSpellRequest(nil);
end

print("Retri pala rotation loaded");