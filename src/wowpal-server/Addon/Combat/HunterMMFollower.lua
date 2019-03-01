--[[
  Button    Spell
  CTRL+1    Macro for following focus "/follow focus"
  CTRL+2    Macro for assisting focus "/assist focus"
  1         Double Tap
  2         Aimed Shot
  3         Rapid Fire
  4         Arcane Shot
  5         Steady Shot
  6         Multi Shot
]]--
local isFollowing = false;
local stoppedFollowAt = 0;
local doubleTap = "1";
local aimedShot = "2";
local rapidFire = "3";
local arcaneShot = "4";
local steadyShot = "5";
local multiShot = "6";
local follow = "CTRL+1";
local assist = "CTRL+2";
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

function RenderMultiTargetRotation(texture)
  if IsFollowing() then
    WowCyborg_CURRENTATTACK = "Following...";
    return false;
  end

  if UnitChannelInfo("player") == "Rapid Fire" then
    return SetSpellRequest(nil);
  end

  if FindBuff("player", "Trick Shots") == nil then
    if IsCastableAtEnemyTarget("Multi-Shot", 15) then
      return SetSpellRequest(multiShot);
    end
  end

  if IsCastableAtEnemyTarget("Rapid Fire", 0) then
    if IsCastableAtEnemyTarget("Double Tap", 0) then
      return SetSpellRequest(doubleTap);
    end
    return SetSpellRequest(rapidFire);
  end

  if FindBuff("player", "Precise Shots") == "Precise Shots" then
    if IsCastableAtEnemyTarget("Multi-Shot", 15) then
      return SetSpellRequest(multiShot);
    end
  end

  if IsCastableAtEnemyTarget("Aimed Shot", 30) then
    if IsMoving() == false then
      return SetSpellRequest(aimedShot);
    end
  end

  if IsCastableAtEnemyTarget("Multi-Shot", 45) then
    return SetSpellRequest(multiShot);
  end
  
  if IsCastableAtEnemyTarget("Steady Shot", 0) then
    return SetSpellRequest(steadyShot);
  end

  return IdleOrAssist();
end

function RenderSingleTargetRotation(texture)
  if IsFollowing() then
    WowCyborg_CURRENTATTACK = "Following...";
    return false;
  end

  if UnitChannelInfo("player") == "Rapid Fire" then
    return SetSpellRequest(nil);
  end

  if IsCastableAtEnemyTarget("Double Tap", 0) then
    return SetSpellRequest(doubleTap);
  end
  
  if IsCastableAtEnemyTarget("Aimed Shot", 30) then
    asCharges = GetSpellCharges("Aimed Shot");
    if asCharges == 2 then
      if IsMoving() == false then
        return SetSpellRequest(aimedShot);
      end
    end
  end
  
  if IsCastableAtEnemyTarget("Rapid Fire", 0) then
    return SetSpellRequest(rapidFire);
  end

  if FindBuff("player", "Precise Shots") == "Precise Shots" then
    if IsCastableAtEnemyTarget("Arcane Shot", 15) then
      return SetSpellRequest(arcaneShot);
    end
  end

  if IsCastableAtEnemyTarget("Aimed Shot", 30) then
    if IsMoving() == false then
      return SetSpellRequest(aimedShot);
    end
  end

  if IsCastableAtEnemyTarget("Arcane Shot", 45) then
    return SetSpellRequest(arcaneShot);
  end

  if IsCastableAtEnemyTarget("Steady Shot", 0) then
    return SetSpellRequest(steadyShot);
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
    if string.find(command, "waves", 1, true) then
      print("Fall back");
      SetSpellRequest(back);
      isFollowing = false;
      stoppedFollowAt = GetTime();
    end
  end)
end

print("Marksman hunter follower rotation loaded");
CreateEmoteListenerFrame();