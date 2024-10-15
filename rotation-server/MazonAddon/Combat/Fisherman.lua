--[[
  Button    Spell
  1         Barbed shot
  2         Kill command
  3         Chimaera shot
  4         Murder of crows
  5         Beastial wrath
  6         Aspect of wild
  7         Cobra shot
  8         Multi shot
]]--
local lastSell = 0;
local mountCounter = 0;
local repairVendorName = "Drix Blackwrench";
local mailerNpcName = "Katy Stampwhistle";
local targetRepair = "F+5";
local targetMailer = "F+6";
local sendMailMacro = "F+7";

local interact = "F+9";
local targetMacro = "F+8";

function HandleVendoring()
  if lastSell + 100 < GetTime() then
    local name = GetUnitName("target")
    if name ~= repairVendorName then
      WowCyborg_CURRENTATTACK = "Target repair";
      SetSpellRequest(targetRepair);
      return true;
    end

    if CanMerchantRepair() == false then
      WowCyborg_CURRENTATTACK = "Interact";
      SetSpellRequest(interact);
      return true;
    end

    SellJunk()
    WowCyborg_CURRENTATTACK = "Sell";
    SetSpellRequest(nil);
  end

  return false;
end

function RenderMultiTargetRotation()
  return RenderSingleTargetRotation()
end

function RenderSingleTargetRotation()
  local vendorResult = HandleVendoring();
  if vendorResult == true then
    return;
  end

  WowCyborg_CURRENTATTACK = "-"
  return SetSpellRequest(nil)
end

function SellJunk()
  local c,i,n,v=0;
  for b=0,4 do 
    for s=1,GetContainerNumSlots(b) do 
      i={GetContainerItemInfo(b,s)}
      n=i[7]
      if n then 
        v={GetItemInfo(n)}
        q=i[2]
        c=c+v[11]*q;
        UseContainerItem(b,s)
        print(n,q)
      end;
    end;
  end;
  
  RepairAllItems(false);

  lastSell = GetTime();
  print("Done")
end

print("Fisherman rotation loaded")

local lastCheckTime = 0;
local lastCheckSum = 0;

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
