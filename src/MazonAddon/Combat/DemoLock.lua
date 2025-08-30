--[[
NAME: Warlock Demonology
ICON: ability_warlock_impoweredimp
]]--
local buttons = {}
buttons["power_siphon"] = "1";
buttons["infernal_bolt"] = "4";
buttons["ruination"] = "6";
buttons["demonbolt"] = "2";
buttons["call_dreadstalkers"] = "3";
buttons["shadow_bolt"] = "4";
buttons["grimoire_felguard"] = "5";
buttons["hand_of_guldan"] = "6";
buttons["summon_demonic_tyrant"] = "7";
buttons["implosion"] = "8";
buttons["blood_fury"] = "F+1";
buttons["demonic_strength"] = "9";
buttons["soul_strike"] = "0";
buttons["summon_vilefiend"] = "0";
buttons["doom"] = "F+6";
buttons["nether_portal"] = "F+7";
stopCast = "F+8";

WowCyborg_PAUSE_KEYS = {
  "F2",
  "LSHIFT",
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

felguardUpUntil = 0;

function GetSpellCD(name)
  local stStart, stDuration = GetSpellCooldown(name);
  if stStart == nil then
    return 60;
  end

  local stCdLeft = stStart + stDuration - GetTime();
  return stCdLeft;
end

function RenderMultiTargetRotation()
  return RenderSingleTargetRotation(true);
end

function RenderSingleTargetRotation(burst)
  local shards = UnitPower("player", 7);

  if burst == nil then
    burst = false;
  end

  if WowCyborg_INCOMBAT == false then
    return SetSpellRequest(nil);
  end
  
  if Hekili.DB.profile.toggles.cooldowns.value ~= burst then
    Hekili:FireToggle("cooldowns");
    Hekili:Query("UI").Minimap:RefreshDataText();
  end

  if UnitCanAttack("player", "target") == false then
    return SetSpellRequest(nil);
  end

  local cooldown = GetHekiliQueue().Cooldowns[1];

  if cooldown.wait == nil or cooldown.wait > 0 then
    actionName = GetHekiliQueue().Primary[1].actionName;
  else
    actionName = cooldown.actionName;
  end

  local tyrantCd = GetSpellCD("Summon Demonic Tyrant");
  local portalCd = GetSpellCD("Nether Portal");

  if tyrantCd < 5 and shards > 0 and (portalCd <= 0 or portalCd > 60) then
    if IsCastable("Blood Fury", 0) then
      actionName = "blood_fury";
    elseif IsCastable("Nether Portal", 0) then
      actionName = "nether_portal";
    elseif IsCastable("Summon Vilefiend", 0) then
      actionName = "summon_vilefiend";
    elseif IsCastable("Grimoire: Felguard", 0) then
      actionName = "grimoire_felguard";
    end
  end

  local felguardUptimeRemaining = felguardUpUntil - GetTime();
  if felguardUptimeRemaining > 0 then
    if IsCastable("Blood Fury", 0) then
      actionName = "blood_fury";
    end

    if felguardUptimeRemaining < 5 and IsCastable("Summon Demonic Tyrant", 0) then
      actionName = "summon_demonic_tyrant";
    end
  end

  local quaking = FindDebuff("player", "Quake");
  if quaking then
    if actionName == "shadow_bolt" or actionName == "hand_of_guldan" then
      return SetSpellRequest(nil);
    end
  end

  WowCyborg_CURRENTATTACK = actionName;
  local button = buttons[actionName];
  
  if button ~= nil then
    return SetSpellRequest(button);
  end

  return SetSpellRequest(nil);
end

function CreateSummonFrame()
  local frame = CreateFrame("Frame");
  frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED");

  frame:SetScript("OnEvent", function(...)
    local timestamp, type, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags = CombatLogGetCurrentEventInfo();
    if type == 'SPELL_SUMMON' and sourceName == UnitName('player') then
      local spellId, spellName, spellSchool = ...
      
      if destName == "Felguard" then
        felguardUpUntil = GetTime() + 17;
      end
    end
  end)
end

CreateSummonFrame();

print("Demo 2 lock rotation loaded");