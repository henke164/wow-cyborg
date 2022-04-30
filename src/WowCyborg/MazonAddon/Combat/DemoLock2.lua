--[[
  Button    Spell
]]--
local demonicTyrant = "1";
local felguard = "2";
local callDreadStalkers = "3";
local handOfGulDan = "4";
local demonbolt = "5";
local shadowbolt = "6";
local soulRot = "7";
local implosion = "8";
local stopCast = "F+7";

local felguardUpUntil = 0;
local dreadStalkersUpUntil = 0;
local demonicTyrantUpUntil = 0;
local wildImpsUpUntil = {};

WowCyborg_PAUSE_KEYS = {
  "LSHIFT",
  "NUMPAD2",
  "NUMPAD3",
  "NUMPAD4",
  "NUMPAD5",
  "F4",
  "F",
  "§"
}

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

function GetCurrentGlobalCooldown()
  return 1.5 - (1.5 * (UnitSpellHaste("player") / 100))
end 

function GetSpellCD(name)
  local stStart, stDuration = GetSpellCooldown(name);
  local stCdLeft = stStart + stDuration - GetTime();
  return stCdLeft;
end

function RenderTyrantSetup()
  local shards = UnitPower("player", 7);
  local tyrantCd = GetSpellCD("Summon Demonic Tyrant");
  local felguardCd = GetSpellCD("Grimoire: Felguard");
  local dcallBuff = FindBuff("player", "Demonic Calling");
  local dreadStalkersCd = GetSpellCD("Call Dreadstalkers");
  local felguardCd = GetSpellCD("Grimoire: Felguard");

  local _, __, ___, tyrantCT = GetSpellInfo("Summon Demonic Tyrant");

  if tyrantCd > 3 then
    return nil;
  end

  local felguardUptimeRemaining = felguardUpUntil - GetTime();
  local dreadStalkersUptimeRemaining = dreadStalkersUpUntil - GetTime();
  local tyrantUptimeRemaining = demonicTyrantUpUntil - GetTime();
  local felguardUp = felguardUptimeRemaining > 0;
  local dreadstalkerUp = dreadStalkersUptimeRemaining > 0;
  local tyrantUp = tyrantUptimeRemaining > 0;

  if dreadstalkerUp == false and dreadStalkersCd > 0 then
    return nil;
  end
  
  if IsCastableAtEnemyTarget("Soul Rot", 0) then
    WowCyborg_CURRENTATTACK = "Soul Rot";
    return SetSpellRequest(soulRot);
  end

  if dcallBuff ~= nil or shards > 1 then
    if IsCastableAtEnemyTarget("Call Dreadstalkers", 0) then
      WowCyborg_CURRENTATTACK = "Call Dreadstalkers";
      return SetSpellRequest(callDreadStalkers);
    end
  end
  
  if IsCastable("Grimoire: Felguard", 0) and shards > 0 then
    WowCyborg_CURRENTATTACK = "Grimoire: Felguard";
    return SetSpellRequest(felguard);
  end

  if IsCastable("Summon Demonic Tyrant", 0) then
    WowCyborg_CURRENTATTACK = "Summon Demonic Tyrant";
    return SetSpellRequest(demonicTyrant);
  end
  
  WowCyborg_CURRENTATTACK = "-";
  return SetSpellRequest(nil);
end

function RenderMultiTargetRotation()
  return RenderSingleTargetRotation(true);
end

function RenderSingleTargetRotation(burst)
  local imps = GetWildImpCount();
  local felguardUptimeRemaining = felguardUpUntil - GetTime();
  local dreadStalkersUptimeRemaining = dreadStalkersUpUntil - GetTime();
  local tyrantUptimeRemaining = demonicTyrantUpUntil - GetTime();
  local felguardUp = felguardUptimeRemaining > 0;
  local dreadstalkerUp = dreadStalkersUptimeRemaining > 0;
  local tyrantUp = tyrantUptimeRemaining > 0;
  local dreadStalkersCd = GetSpellCD("Call Dreadstalkers");

  local shards = UnitPower("player", 7);
  local speed = GetUnitSpeed("player");
  local targetHp = GetHealthPercentage("target");
  local tyrantCd = GetSpellCD("Summon Demonic Tyrant");
  local shouldCastShadowbolt = true;
  
  if UnitCastingInfo("player") == "Summon Demonic Tyrant" then
    shards = 5;
  end

  if UnitCastingInfo("player") == "Hand of Gul'dan" then
    shards = shards - 3;
  end
  
  if UnitCastingInfo("player") == "Shadow Bolt" then
    shards = shards + 1;
  end

  if tyrantUptimeRemaining < 0 and tyrantUptimeRemaining > -10 and tyrantUp == false and imps > 10 then
    if IsCastableAtEnemyTarget("Implosion", 0) then
      WowCyborg_CURRENTATTACK = "Implosion";
      return SetSpellRequest(implosion);
    end
  end
  
  if speed == 0 and imps > 5 and burst and WowCyborg_INCOMBAT then
    local tyrantSetup = RenderTyrantSetup();
    if tyrantSetup ~= nil then
      return tyrantSetup;
    end
  end

  local dcBuff, dcTl, dcStacks = FindBuff("player", "Demonic Core");
  local dcallBuff = FindBuff("player", "Demonic Calling");

  if (tyrantCd > 20 or burst ~= true) and dcallBuff ~= nil and dreadStalkersCd < 1.5 then
    shouldCastShadowbolt = false;
    if IsCastableAtEnemyTarget("Call Dreadstalkers", 0) then
      WowCyborg_CURRENTATTACK = "Call Dreadstalkers";
      return SetSpellRequest(callDreadStalkers);
    end
  end

  if speed == 0 and IsCastableAtEnemyTarget("Shadow Bolt", 0) then
    if shards == 5 or (dcBuff ~= nil and shards > 3) or (tyrantCd == 0 and shards > 3) then
      shouldCastShadowbolt = false;
      if IsCastableAtEnemyTarget("Hand of Gul'dan", 0) then
        WowCyborg_CURRENTATTACK = "Hand of Gul'dan";
        return SetSpellRequest(handOfGulDan);
      end
    end

    if shards > 2 and tyrantUp then
      shouldCastShadowbolt = false;
      if IsCastableAtEnemyTarget("Hand of Gul'dan", 0) then
        WowCyborg_CURRENTATTACK = "Hand of Gul'dan";
        return SetSpellRequest(handOfGulDan);
      end
    end

    if dcBuff ~= nil and (speed == 1 or shards < 4) then
      shouldCastShadowbolt = false;
      if IsCastableAtEnemyTarget("Demonbolt", 0) then
        WowCyborg_CURRENTATTACK = "Demonbolt";
        return SetSpellRequest(demonbolt);
      end
    end

    if shouldCastShadowbolt and IsCastableAtEnemyTarget("Shadow Bolt", 0) then
      WowCyborg_CURRENTATTACK = "Shadow Bolt";
      return SetSpellRequest(shadowbolt);
    end
  else
    if dcBuff ~= nil then
      shouldCastShadowbolt = false;
      if IsCastableAtEnemyTarget("Demonbolt", 0) then
        WowCyborg_CURRENTATTACK = "Demonbolt";
        return SetSpellRequest(demonbolt);
      end
    end
  end

  WowCyborg_CURRENTATTACK = "-";
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

      if destName == "Dreadstalker" then
        dreadStalkersUpUntil = GetTime() + 12;
      end
      
      if destName == "Felguard" then
        felguardUpUntil = GetTime() + 17;
      end
      
      if destName == "Demonic Tyrant" then
        demonicTyrantUpUntil = GetTime() + 15;
        felguardUpUntil = felguardUpUntil + 15;
        dreadStalkersUpUntil = dreadStalkersUpUntil + 15;

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