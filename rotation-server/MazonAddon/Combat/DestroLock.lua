--[[
  Button    Spell
]]--

local immolate = "1";
local chaosBolt = "2";
local exhaust = "3";
local conflagrate = "4";
local incinerate = "5";
local soulRot = "6";
local havoc = "7";

local interruptArena1 = "CTRL+1";
local interruptArena2 = "CTRL+2";
local interruptArena3 = "CTRL+3";

local bolting = false;

WowCyborg_PAUSE_KEYS = {
  "F",
  "F1",
  "F2",
  "F3",
  "NUMPAD2",
  "NUMPAD3",
  "LSHIFT",
  "NUMPAD8",
  "NUMPAD5"
}

function RenderMultiTargetRotation()
  local exhaustDebuff, exhaustTl = FindDebuff("target", "Curse of Exhaustion");
  local bof = FindBuff("target", "Blessing of Freedom");

  if (exhaustDebuff == nil or exhaustTl < 4) and bof == nil then
    if IsCastableAtEnemyTarget("Curse of Exhaustion", 0) then
      WowCyborg_CURRENTATTACK = "Curse of Exhaustion";
      return SetSpellRequest(exhaust);
    end
  end

  return RenderSingleTargetRotation();
end

function RenderSingleTargetRotation()
  local speed = GetUnitSpeed("player");
  
  if UnitChannelInfo("arena1") == "Convoke the Spirits" then
    WowCyborg_CURRENTATTACK = "Interrupt 1";
    return SetSpellRequest(interruptArena1);
  end
  
  if UnitChannelInfo("arena2") == "Convoke the Spirits" then
    WowCyborg_CURRENTATTACK = "Interrupt 2";
    return SetSpellRequest(interruptArena2);
  end

  if UnitChannelInfo("arena3") == "Convoke the Spirits" then
    WowCyborg_CURRENTATTACK = "Interrupt 3";
    return SetSpellRequest(interruptArena3);
  end

  local backdraft, backdraftTl, backdraftStacks = FindBuff("player", "Backdraft");
  if backdraft == nil or backdraftStacks < 2 then
    if IsCastableAtEnemyTarget("Conflagrate", 0) then
      WowCyborg_CURRENTATTACK = "Conflagrate";
      return SetSpellRequest(conflagrate);
    end
  end

  local immolateDebuff = FindDebuff("target", "Immolate"); 
  if immolateDebuff == nil then
    local castingInfo = UnitCastingInfo("player");
    if IsCastableAtEnemyTarget("Immolate", 0) and castingInfo ~= "Immolate" then
      WowCyborg_CURRENTATTACK = "Immolate";
      return SetSpellRequest(immolate);
    end
  end

  local shards = UnitPower("player", 7)
  if shards >= 4 then
    bolting = true  
  end
  
  if shards < 2 and bolting == true then
    bolting = false;
  end

  if bolting == true and speed == 0 then
    if IsCastableAtEnemyTarget("Chaos Bolt", 0) then
      WowCyborg_CURRENTATTACK = "Chaos Bolt";
      return SetSpellRequest(chaosBolt);
    end
  end

  local darkSoulBuff = FindBuff("player", "Dark Soul: Instability");
  local darkSoulCd = GetSpellCooldown("Dark Soul: Instability", "spell");
  if darkSoulBuff ~= nil or darkSoulCd > 60 then
    if IsCastableAtEnemyFocus("Havoc", 1000) then
      WowCyborg_CURRENTATTACK = "Havoc";
      return SetSpellRequest(havoc);
    end

    if speed == 0 then
      if IsCastableAtEnemyTarget("Soul Rot", 250) then
        WowCyborg_CURRENTATTACK = "Soul Rot";
        return SetSpellRequest(soulRot);
      end
    end
  end

  if speed == 0 and IsCastableAtEnemyTarget("Incinerate", 0) then
    WowCyborg_CURRENTATTACK = "Incinerate";
    return SetSpellRequest(incinerate);
  end

  if IsCastableAtEnemyTarget("Conflagrate", 0) then
    WowCyborg_CURRENTATTACK = "Conflagrate";
    return SetSpellRequest(conflagrate);
  end

  WowCyborg_CURRENTATTACK = "-";
  return SetSpellRequest(nil);
end

print("Destro lock rotation loaded");