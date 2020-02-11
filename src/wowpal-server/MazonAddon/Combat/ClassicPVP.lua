--[[
  Button    Spell
  1         targetPVE
]]--

local wait = "SHIFT+3";
local targetPVE = "1";
local leaveBg = "SHIFT+1";
local speak = "SHIFT+0";
local joinQueue = "SHIFT+9";

local startedLeaveBgAt = 0;
local pvpWindowOpen = false;

-- Multi target
function RenderMultiTargetRotation()
  return RenderSingleTargetRotation();
end

-- Single target
function RenderSingleTargetRotation()
  if IsOutside() then
    if IsDeserter() then
      WowCyborg_CURRENTATTACK = "Deserter";
      return SetSpellRequest(wait);
    end

    local targetName = UnitName("target");
<<<<<<< HEAD
    if targetName ~= "Taim Ragetotem" and targetName ~= "Kartra Bloodsnarl" then
      WowCyborg_CURRENTATTACK = "Target Taim Ragetotem";
=======
    if targetName ~= "Taim Ragetotem" and targetName ~= "Grizzle Halfmane" and targetName ~= "Kartra Bloodsnarl" then
      WowCyborg_CURRENTATTACK = "Target Karstra";
>>>>>>> b7b6ecd464949b37c4a941f4bb784c6febfb99d8
      return SetSpellRequest(targetPVE);
    else
      WowCyborg_CURRENTATTACK = "Speak";
      return SetSpellRequest(speak);
    end
  end

  if QueueReady() then
    WowCyborg_CURRENTATTACK = "Join queue";
    return SetSpellRequest(joinQueue);
  end

  if BGActive() then
    if startedLeaveBgAt > GetTime() - 0.5 then
      WowCyborg_CURRENTATTACK = "Leaving BG...";
      return SetSpellRequest(leaveBg);
    end

    WowCyborg_CURRENTATTACK = "Do some BG shit";
    return SetSpellRequest(nil);
  end

  WowCyborg_CURRENTATTACK = "Wait";
  return SetSpellRequest(wait);
end

function IsOutside()
  local status = GetBattlefieldStatus(1);
  return status == "none";
end

function QueueReady()
  local status = GetBattlefieldStatus(1);
  return status == "confirm";
end

function BGActive()
  local status = GetBattlefieldStatus(1);
  return status == "active";
end

function IsDeserter()
  local deserter = FindDebuff("player", "Deserter");
  return deserter == "Deserter";
end

function CreateBgFrame()
  local frame = CreateFrame("Frame")
  frame:RegisterEvent("ITEM_PUSH")

  frame:SetScript("OnEvent", function(arg1, arg2, ...)
    print("ITEM_PUSH");

    print(arg1);
    print(arg2);
    print(...);
    startedLeaveBgAt = GetTime();
  end)
end

CreateBgFrame();

print("Classic PVP loaded!");