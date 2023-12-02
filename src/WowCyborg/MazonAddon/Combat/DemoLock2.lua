--[[
  Button    Spell
]]--
local buttons = {}
buttons["power_siphon"] = "1";
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
buttons["soulburn"] = "F+8";

stopCast = "F+8";
local wildImpsUpUntil = {};

WowCyborg_PAUSE_KEYS = {
  "LSHIFT",
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
demonicTyrantUpUntil = 0;

function GetWildImpCount()
  local imps = 0;
  for k,v in pairs(wildImpsUpUntil) do 
    local wildImpUptime = v - GetTime();
    if (wildImpUptime > 0) then
      imps = imps + 1;
    else
      wildImpsUpUntil[k] = nil;
    end
  end
  return imps;
end

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

  if Hekili.DB.profile.toggles.cooldowns.value == true then
    Hekili:FireToggle("cooldowns");
    Hekili:Query("UI").Minimap:RefreshDataText();
  end

  if UnitCanAttack("player", "target") == false then
    return SetSpellRequest(nil);
  end

  local actionName = GetHekiliQueue().Primary[1].actionName;

  local imps = GetWildImpCount();

  local netherPortalCd = GetSpellCD("Nether Portal");
  local felguardCd = GetSpellCD("Grimoire: Felguard");
  local dcBuff = FindBuff("player", "Demonic Core");

  if burst and felguardCd < 5 then
    if netherPortalCd <= 0 and imps > 4 and actionName == "hand_of_guldan" then
      actionName = GetHekiliQueue().Primary[2].actionName;
    end

    if netherPortalCd <= 1.5 then
      if shards < 5 then
        local dbCd = GetSpellCD("Demonbolt");
        if dbCd < 4 and shards < 4 then
          if dcBuff then
            actionName = "demonbolt";
            WowCyborg_CURRENTATTACK = actionName;
            return SetSpellRequest(buttons[actionName]);
          end
        end

        actionName = "shadow_bolt";
        WowCyborg_CURRENTATTACK = actionName;
        return SetSpellRequest(buttons[actionName]);
      end

      if shards == 5 then
        actionName = "nether_portal";
        WowCyborg_CURRENTATTACK = actionName;
        return SetSpellRequest(buttons[actionName]);
      end
    end

    if netherPortalCd > 170 then
      local sbBuff = FindBuff("player", "Soulburn");
      if sbBuff == nil then
        if IsCastable("Soulburn", 0) and shards > 0 then
          actionName = "soulburn";
          WowCyborg_CURRENTATTACK = actionName;
          return SetSpellRequest(buttons[actionName]);
        end
      end
    end
  end

  if netherPortalCd > 60 and (shards >= 3 or dcBuff ~= nil or GetSpellCD("Power Siphon") < 3) then
    if IsCastable("Grimoire: Felguard", 0) and shards > 0 then
      actionName = "grimoire_felguard";
    end 
  end

  if felguardCd > 40 and IsCastable("Summon Vilefiend", 0) and shards > 0 then
    actionName = "summon_vilefiend";
  end

  local felguardUptimeRemaining = felguardUpUntil - GetTime();
  if felguardUptimeRemaining > 0 then
    if (felguardUptimeRemaining < 7 or imps > 10) and IsCastable("Summon Demonic Tyrant", 0) then
      actionName = "summon_demonic_tyrant";
    end
  end

  if demonicTyrantUpUntil > 0 then    
    if GetSpellCD("Blood Fury") < 1.5 then
      actionName = "blood_fury";
    end

    if IsCastable("Demonic Strength", 0) then
      actionName = "demonic_strength";
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

      if destName == "Wild Imp" then
        wildImpsUpUntil[destGUID] = GetTime() + 10;
      end

      if destName == "Felguard" then
        felguardUpUntil = GetTime() + 17;
      end
            
      if destName == "Demonic Tyrant" then
        demonicTyrantUpUntil = GetTime() + 15;
        felguardUpUntil = felguardUpUntil + 15;

        for k,v in pairs(wildImpsUpUntil) do 
          local wildImpUptime = v - GetTime();
          if (wildImpUptime > 0) then
            wildImpsUpUntil[k] = wildImpsUpUntil[k] + 15;
          else
            wildImpsUpUntil[k] = nil;
          end
        end
      end
    end
  end)
end

CreateSummonFrame();

print("Demo 2 lock rotation loaded");