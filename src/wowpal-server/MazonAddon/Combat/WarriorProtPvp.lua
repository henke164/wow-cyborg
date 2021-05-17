--[[
  Button    Spell
  Shift+1   Avatar
  Shift+2   Demoralizing Shout
  Shift+3   Shield Wall
  Shift+4   Last Stand
  Ctrl+1    Rallying Cry
  1         Shield Slam
  2         Thunder Clap
  3         Revenge
  4         Devastate
  5         Shield Block
  6         Ignore Pain
  7         Victory Rush
]]--

local equipShield = "1";
local equip2H = "2";
local shieldSlam = "3";
local condemn = "4";
local thunderClap = "5";
local avatar = "6";
local dragonRoar = "7";
local devastate = "8";

function RenderMultiTargetRotation()
  return RenderSingleTargetRotation();
end

function RenderSingleTargetRotation()
  local targetHp = GetHealthPercentage("target");

  if targetHp < 80 and targetHp > 20 then
    if GetItemInfo(GetInventoryItemID("player", 17) or 0) == nil then
      WowCyborg_CURRENTATTACK = "Equip Shield";
      return SetSpellRequest(equipShield);
    end
  end

  if InMeleeRange() == false then
    WowCyborg_CURRENTATTACK = "-";
    return SetSpellRequest(nil);
  end

  if IsCastableAtEnemyTarget("Condemn", 100) then
    if GetItemInfo(GetInventoryItemID("player", 17) or 0) ~= nil then
      WowCyborg_CURRENTATTACK = "Equip 2hand";
      return SetSpellRequest(equip2H);
    end
  end

  if GetItemInfo(GetInventoryItemID("player", 17) or 0) == nil then
    if IsCastableAtEnemyTarget("Avatar", 0) then
      WowCyborg_CURRENTATTACK = "Avatar";
      return SetSpellRequest(avatar);
    end
  
    local rage = UnitPower("player");
    if rage < 80 and IsCastableAtEnemyTarget("Dragon Roar", 0) then
      WowCyborg_CURRENTATTACK = "Dragon Roar";
      return SetSpellRequest(dragonRoar);
    end
      
    if IsCastableAtEnemyTarget("Condemn", 20) then
      WowCyborg_CURRENTATTACK = "Condemn";
      return SetSpellRequest(condemn);
    end

    WowCyborg_CURRENTATTACK = "Equip Shield";
    return SetSpellRequest(equipShield);
  end

  if IsCastableAtEnemyTarget("Shield Slam", 0) then
    WowCyborg_CURRENTATTACK = "Shield Slam";
    return SetSpellRequest(shieldSlam);
  end

  if IsCastableAtEnemyTarget("Thunder Clap", 0) then
    WowCyborg_CURRENTATTACK = "Thunder Clap";
    return SetSpellRequest(thunderClap);
  end

  if IsCastableAtEnemyTarget("Devastate", 0) then
    WowCyborg_CURRENTATTACK = "Devastate";
    return SetSpellRequest(devastate);
  end

  WowCyborg_CURRENTATTACK = "-";
  return SetSpellRequest(nil);
end

function InMeleeRange()
  return IsSpellInRange("Shield Slam", "target") == 1;
end

print("Protection PVP warrior rotation loaded");