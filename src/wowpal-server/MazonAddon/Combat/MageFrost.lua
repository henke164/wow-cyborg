--[[
]]--

local icyVeins = 1;
local iceLance = 2;
local flurry = 3;
local frozenOrb = 4;
local cometStorm = 5;
local ebonbolt = 6;
local glacialSpike = 7;
local blizzard = 8;
local frostbolt = 9;
local toggle = false;

-- Multi target
function RenderMultiTargetRotation()
  return RenderSingleTargetRotation(true);
end

-- Single target
function RenderSingleTargetRotation(aoe)
  local quaking = FindDebuff("player", "Quake");
  if quaking ~= nil then
    WowCyborg_CURRENTATTACK = "Quake!";
    return SetSpellRequest(nil);
  end

  local castingSpell = UnitCastingInfo("player");

  if castingSpell == "Focusing Azerite Beam" then
    WowCyborg_CURRENTATTACK = "Shooting azerite";
    return SetSpellRequest(nil);
  end

  if IsCastableAtEnemyTarget("Frostbolt", 0) and IsCastable("Icy Veins", 0) then
    WowCyborg_CURRENTATTACK = "Icy Veins";
    return SetSpellRequest(icyVeins);
  end

  if aoe ~= nil then
    if IsCastableAtEnemyTarget("Blizzard", 0) then
      WowCyborg_CURRENTATTACK = "Blizzard";
      return SetSpellRequest(blizzard);
    end
  end

  local bfBuff = FindBuff("player", "Brain Freeze");
  if bfBuff ~= nil then
    local iciclesBuff, iciclesCount = FindBuff("player", "Icicles");

    if iciclesBuff and aoe == nil then
      if iciclesCount < 4 then
        if IsCastableAtEnemyTarget("Ebonbolt", 0) and toggle == false then
          WowCyborg_CURRENTATTACK = "Ebonbolt";
          return SetSpellRequest(ebonbolt);
        end
        if IsCastableAtEnemyTarget("Frostbolt", 0) then
          WowCyborg_CURRENTATTACK = "Frostbolt";
          return SetSpellRequest(frostbolt);
        end
      end
      if iciclesCount > 3 then
        if IsCastableAtEnemyTarget("Glacial Spike", 0) then
          toggle = true;
          WowCyborg_CURRENTATTACK = "Glacial Spike";
          return SetSpellRequest(glacialSpike);
        end
      end
    end

    toggle = false;
    WowCyborg_CURRENTATTACK = "Flurry";
    return SetSpellRequest(flurry);
  end

  if IsCastableAtEnemyTarget("Frozen Orb", 0) then
    WowCyborg_CURRENTATTACK = "Frozen Orb";
    return SetSpellRequest(frozenOrb);
  end

  local fofBuff = FindBuff("player", "Fingers of Frost");
  if (fofBuff ~= nil or IsMoving()) and IsCastableAtEnemyTarget("Ice Lance", 0) and WowCyborg_INCOMBAT then
    WowCyborg_CURRENTATTACK = "Ice Lance";
    return SetSpellRequest(iceLance);
  end

  if IsCastableAtEnemyTarget("Comet Storm", 0) then
    WowCyborg_CURRENTATTACK = "Comet Storm";
    return SetSpellRequest(cometStorm);
  end

  if (iciclesBuff == nil or iciclesCount < 4) and IsCastableAtEnemyTarget("Ebonbolt", 0) then
    WowCyborg_CURRENTATTACK = "Ebonbolt";
    return SetSpellRequest(ebonbolt);
  end

  if bfBuff ~= nil and IsCastableAtEnemyTarget("Glacial Spike", 0) then
    WowCyborg_CURRENTATTACK = "Glacial Spike";
    return SetSpellRequest(glacialSpike);
  end

  if IsCastableAtEnemyTarget("Frostbolt", 0) then
    WowCyborg_CURRENTATTACK = "Frostbolt";
    return SetSpellRequest(frostbolt);
  end

  WowCyborg_CURRENTATTACK = "-";
  return SetSpellRequest(nil);
end

print("Frost mage rotation loaded");