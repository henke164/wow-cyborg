--[[
  Button    Spell
  CTRL+1    Macro for following focus "/follow focus"
  CTRL+2    Macro for assisting focus "/assist focus"
  1         Totem Mastery
  2         Flame Shock
  3         Earthquake (Not used)
  4         Stormkeeper
  5         Earth Shock
  6         Lava Burst
  7         Chain Lightning
  8         Lightning Bolt
  9         Frost Shock
]]--

local isFollowing = false;
local stoppedFollowAt = 0;
local totemMastery = "1";
local flameShock = "2";
local earthQuake = "3";
local stormKeeper = "4";
local earthShock = "5";
local lavaBurst = "6";
local chainLightning = "7";
local lightningBolt = "8";
local frostShock = "9";
local follow = "CTRL+1";
local assist = "CTRL+2";
local mount = "CTRL+3";
local back = "CTRL+9";

function IsFollowing()
  if isFollowing then
    return true;
  end

  if stoppedFollowAt == 0 then
    return true;
  end

  if GetTime() <= stoppedFollowAt + 1 then
    return true;
  end

  return false;
end

-- Movement
function RenderTargetRotationInMovement()
  local lsBuff = FindBuff("player", "Lava Surge");
  local fsDot, fsDotTimeLeft = FindDebuff("target", "Flame Shock");

  if lsBuff == "Lava Surge" then
    if IsCastableAtEnemyTarget("Lava Burst", 0) then
      WowCyborg_CURRENTATTACK = "Lava Burst";
      return SetSpellRequest(lavaBurst);
    end
  end

  if fsDot == nil or fsDotTimeLeft <= 6.5 then
    if IsCastableAtEnemyTarget("Flame Shock", 0) then
      WowCyborg_CURRENTATTACK = "Flame Shock";
      return SetSpellRequest(flameShock);
    end
  end

  if IsCastableAtEnemyTarget("Earth Shock", 60) then
    WowCyborg_CURRENTATTACK = "Earth Shock";
    return SetSpellRequest(earthShock);
  end
  
  if IsCastableAtEnemyTarget("Frost Shock", 0) then
    WowCyborg_CURRENTATTACK = "Frost Shock";
    return SetSpellRequest(frostShock);
  end

  WowCyborg_CURRENTATTACK = "-";
  return SetSpellRequest(nil);
end

-- Multi target
function RenderMultiTargetRotation()
  if IsFollowing() then
    WowCyborg_CURRENTATTACK = "Following...";
    return false;
  end
  
  if UnitChannelInfo("player") == "Lightning Lasso" then
    return SetSpellRequest(nil);
  end

  if IsMoving() == true then
    return RenderTargetRotationInMovement();
  end

  local fsDot, fsDotTimeLeft = FindDebuff("target", "Flame Shock");
  local moeBuff = FindBuff("player", "Master of the Elements");

  if IsCastableAtEnemyTarget("Lightning Bolt", 0) then
    local totemBuff = FindBuff("player", "Storm Totem");
    if totemBuff == nil then 
      return SetSpellRequest(totemMastery);
    end
      
    if IsCastableAtEnemyTarget("Flame Shock", 0) then
      if fsDot == nil then
        WowCyborg_CURRENTATTACK = "Flame Shock";
        return SetSpellRequest(flameShock);
      end
    end
    
    if IsCastableAtEnemyTarget("Stormkeeper", 0) then
      WowCyborg_CURRENTATTACK = "Stormkeeper";
      return SetSpellRequest(stormKeeper);
    end
  end
  
  local maelstrom = UnitPower("player");

  if IsCastableAtEnemyTarget("Lava Burst", 0) then
    WowCyborg_CURRENTATTACK = "Lava Burst";
    return SetSpellRequest(lavaBurst);
  end

  if fsDot == "Flame Shock" and fsDotTimeLeft <= 7 then
    WowCyborg_CURRENTATTACK = "Flame Shock";
    return SetSpellRequest(flameShock);
  end
  
  if IsCastableAtEnemyTarget("Chain Lightning", 0) then
    WowCyborg_CURRENTATTACK = "Chain Lightning";
    return SetSpellRequest(chainLightning);
  end

  return IdleOrAssist();
end

-- Single target
function RenderSingleTargetRotation()
  if IsFollowing() then
    WowCyborg_CURRENTATTACK = "Following...";
    return false;
  end

  if UnitChannelInfo("player") == "Lightning Lasso" then
    return SetSpellRequest(nil);
  end

  if IsMoving() == true then
    return RenderTargetRotationInMovement();
  end

  local fsDot, fsDotTimeLeft = FindDebuff("target", "Flame Shock");
  local moeBuff = FindBuff("player", "Master of the Elements");

  if IsCastableAtEnemyTarget("Lightning Bolt", 0) then
    local totemBuff = FindBuff("player", "Storm Totem");
    if totemBuff == nil then 
      return SetSpellRequest(totemMastery);
    end
      
    if IsCastableAtEnemyTarget("Flame Shock", 0) then
      if fsDot == nil then
        WowCyborg_CURRENTATTACK = "Flame Shock";
        return SetSpellRequest(flameShock);
      end
    end

    if IsCastableAtEnemyTarget("Stormkeeper", 0) then
      WowCyborg_CURRENTATTACK = "Stormkeeper";
      return SetSpellRequest(stormKeeper);
    end
  end
  
  local maelstrom = UnitPower("player");

  if IsCastableAtEnemyTarget("Earth Shock", 60) and 
    moeBuff == "Master of the Elements" then
    WowCyborg_CURRENTATTACK = "Earth Shock";
    return SetSpellRequest(earthShock);
  end

  if IsCastableAtEnemyTarget("Lava Burst", 0) then
    WowCyborg_CURRENTATTACK = "Lava Burst";
    return SetSpellRequest(lavaBurst);
  end

  if fsDot == "Flame Shock" and fsDotTimeLeft <= 7 then
    WowCyborg_CURRENTATTACK = "Flame Shock";
    return SetSpellRequest(flameShock);
  end
  
  if maelstrom >= 60 then
    if IsCastableAtEnemyTarget("Earth Shock", 60) then
      WowCyborg_CURRENTATTACK = "Earth Shock";
      return SetSpellRequest(earthShock);
    end
  end

  if IsCastableAtEnemyTarget("Lightning Bolt", 0) then
    WowCyborg_CURRENTATTACK = "Lightning Bolt";
    return SetSpellRequest(lightningBolt);
  end

  return IdleOrAssist();
end

function IdleOrAssist()
  WowCyborg_CURRENTATTACK = "-";
  if not WowCyborg_HasFocus then
    return SetSpellRequest(nil);
  elseif UnitGUID("focustarget") == nil then
    return SetSpellRequest(nil);
  elseif UnitGUID("focustarget") == UnitGUID("target") then
    return SetSpellRequest(nil);
  end

  WowCyborg_CURRENTATTACK = "Assist focus";
  return SetSpellRequest(assist);
end

function CreateEmoteListenerFrame()
  local frame = CreateFrame("Frame");
  frame:RegisterEvent("CHAT_MSG_TEXT_EMOTE");
  frame:SetScript("OnEvent", function(self, event, ...)
    command = ...;
    if string.find(command, "follow", 1, true) then
      print("Following");
      SetSpellRequest(follow);
      isFollowing = true;
      stoppedFollowAt = 0;
    end
    if string.find(command, "wait", 1, true) then
      print("Waiting");
      SetSpellRequest(assist);
      isFollowing = false;
      stoppedFollowAt = GetTime();
    end
    if string.find(command, "fart", 1, true) then
      print("Mounting");
      SetSpellRequest(mount);
      isFollowing = false;
      startedFollowAt = 0;
      stoppedFollowAt = GetTime();
    end
    if string.find(command, "waves", 1, true) then
      print("Fall back");
      SetSpellRequest(back);
      isFollowing = false;
      stoppedFollowAt = GetTime();
    end
  end)
end

print("Elemental shaman follower rotation loaded");
CreateEmoteListenerFrame();