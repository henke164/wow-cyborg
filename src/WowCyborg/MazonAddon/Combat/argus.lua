local target = "F+8";
local attack = "1";
local aoe = "2";
local loot = "3";
local lootedAt = 0;
local lastCheckTime = 0;
local lastCheckSum = 0;

WowCyborg_PAUSE_KEYS = {
  "3"
}

function RenderMultiTargetRotation(texture)
  return SetSpellRequest(nil);
end

function RenderSingleTargetRotation(texture)
  if UnitChannelInfo("player") then
    print("Channel");
    return SetSpellRequest(nil);
  end

  local starfallBuff = FindBuff("player", "Starfall");
  if starfallBuff == nil and IsCastable("Starfall", 50) then
    WowCyborg_CURRENTATTACK = "Aoe";
    return SetSpellRequest(aoe);
  end

  local dot2, dot2Tl = FindDebuff("target", "Sunfire");
  if (dot2 == nil or dot2Tl < 4) and IsCastableAtEnemyTarget("Sunfire", 0) then
    WowCyborg_CURRENTATTACK = "Attack";
    return SetSpellRequest(attack);
  end

  if (GetTime() - lootedAt > 60) then
    WowCyborg_CURRENTATTACK = "Loot";
    return SetSpellRequest(loot);
  end
  
  WowCyborg_CURRENTATTACK = "-";
  return SetSpellRequest(target);
end

function CreateLootFrame()
  local frame = CreateFrame("Frame");
  frame:RegisterEvent("LOOT_OPENED");
  frame:SetScript("OnEvent", function(self, event, ...)
    print("Looted!");
    lootedAt = GetTime();
  end);
end

function CreateCenterFrame(x, y, width, height)
  local frame = CreateFrame("Frame");
  frame:ClearAllPoints();
  frame:SetPoint("CENTER", UIParent, "CENTER", x, y);
  frame:SetWidth(width);
  frame:SetHeight(height);
  local texture = frame:CreateTexture("WhiteTexture", "ARTWORK");
  texture:SetWidth(width);
  texture:SetHeight(height);
  texture:ClearAllPoints();
  texture:SetAllPoints(frame);
  return frame, texture;
end

function CreateGoldFrame()
  local frame, texture = CreateCenterFrame(0, 200, 200, 100)
  local fs = frame:CreateFontString()
  fs:SetFont("Fonts\\FRIZQT__.TTF", 34, "OUTLINE, MONOCHROME")
  fs:SetPoint("CENTER",0,20)
  
  local fs2 = frame:CreateFontString()
  fs2:SetFont("Fonts\\FRIZQT__.TTF", 18, "OUTLINE, MONOCHROME")
  fs2:SetPoint("CENTER",0,-20)

  frame:SetScript("OnUpdate", function(self, event, ...)
    local gold = GetMoney() / 100 / 100

    fs:SetText('|cffffffff' .. math.ceil(gold) .. '|r')
    fs2:SetText('|cffffffff' .. math.ceil(math.ceil(GetTime() - lastCheckTime) / 60) .. ": " .. math.ceil(gold - lastCheckSum) .. '|r')

    if lastCheckTime * 60 * 60 < GetTime() then
      lastCheckTime = GetTime()
      lastCheckSum = gold
    end
  end)
end

CreateGoldFrame();
CreateLootFrame();

print("Argus rotation loaded");