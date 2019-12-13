--[[
  Button    Spell
  1         targetPVE
]]--

local doInBGStuff = "9";
local targetPVE = "1";
local speak = "SHIFT+0";
local joinQueue = "SHIFT+9";

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
      return SetSpellRequest(nil);
    end

    local targetName = UnitName("target");
    if targetName ~= "Kartra Bloodsnarl" then
      WowCyborg_CURRENTATTACK = "Target Karstra";
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
    WowCyborg_CURRENTATTACK = "Do some BG shit";
    return SetSpellRequest(doInBGStuff);
  end

  WowCyborg_CURRENTATTACK = "-";
  return SetSpellRequest(nil);
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
  frame:RegisterEvent("BATTLEFIELDS_SHOW")

  frame:SetScript("OnEvent", function()
    print("BATTLEFIELDS_SHOW");
  end)
end

CreateBgFrame();

print("Classic PVP loaded!");