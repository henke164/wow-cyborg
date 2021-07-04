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

local pauser = false;
local paused = false;
local sendingMail = false;
local clickedAt = 0;
local switchCounter = 0;
local lastRepair = 0;
local mountCounter = 0;
local repairVendorName = "Drix Blackwrench";
local mailerNpcName = "Katy Stampwhistle";
local createRepair = "SHIFT+6";
local createRepairAt = 0;
local targetRepair = "SHIFT+5";
local targetMailer = "SHIFT+7";
local interact = "CTRL+0";
local targetMacro = "9";
local sayCounter = 0;

function ScanArea()
  local numResult = C_FriendList.GetNumWhoResults()
  
  for index=1,numResult do 
    local name = C_FriendList.GetWhoInfo(index).fullName;
    
    -- whitelist
    if name ~= "Muu" and name ~= "Dekån" then
		  return name .. " is nearby";
	  end
  end
  return nil
end

function HandleVendoring()
  if lastRepair + 100 < GetTime() then
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

-------------------------------------- Boomkin --------------------------------------------
function RenderBoomkinRotation()  
  WowCyborg_CURRENTATTACK = "Pew";
  return SetSpellRequest("1")
end

function RenderMultiTargetRotation()
  return RenderSingleTargetRotation()
end

function RenderSingleTargetRotation()
  local scanResult = ScanArea();
  if scanResult ~= nil then
    if pauser == false then
	  sayCounter = 0;
      pauser = true;
    end
    
	if sayCounter < 100 then
	  sayCounter = sayCounter + 1;
	  return SetSpellRequest("3");
	end
	  
    WowCyborg_CURRENTATTACK = scanResult;
	return SetSpellRequest("2")
  end

  if pauser then
    pauser = false;
	sayCounter = 0;
  end

	if sayCounter < 50 then 
	  sayCounter = sayCounter + 1;
	  return SetSpellRequest("4");
	end

  if paused then
    WowCyborg_CURRENTATTACK = "Paused";
    return SetSpellRequest(nil);
  end
    
  if sendingMail then
    return HandleMailing()
  end

  if clickedAt + 2 > GetTime() then
    WowCyborg_CURRENTATTACK = "Looting..."
    return SetSpellRequest(nil)
  end

  className = UnitClass("player")

  local vendorResult = HandleVendoring()
  if vendorResult == true then
    return;
  end

  if className == "Druid" then
    return RenderBoomkinRotation()
  end
  
  
  WowCyborg_CURRENTATTACK = "-";
  return SetSpellRequest("2")
end

function SellJunk()
  local c,i,n,v=0;
  for b=0,4 do 
    for s=1,GetContainerNumSlots(b) do 
      i={GetContainerItemInfo(b,s)}
      n=i[7]
      if n and (string.find(n,"ffffffff") or string.find(n,"9d9d9d") or string.find(n,"1eff00")) and (C_Item.IsBound(ItemLocation:CreateFromBagAndSlot(b, s)) == false) then 
        v={GetItemInfo(n)}
        q=i[2]
        c=c+v[11]*q;
        UseContainerItem(b,s)
        print(n,q)
      end;
    end;
  end;
  
  RepairAllItems(false);

  lastRepair = GetTime();
  print("Done")
end

print("Skinner rotation loaded")

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

function HandleMailing()
  local name = GetUnitName("target")
  if name ~= mailerNpcName then
    WowCyborg_CURRENTATTACK = "Target mail";
    SetSpellRequest(targetMailer);
    return true;
  end

  if GossipFrame:IsVisible() == true then
    SelectGossipOption(1);
    return true;
  end
  
  if MailFrame:IsVisible() == true then
    WowCyborg_CURRENTATTACK = "Mail";
    return true;
  end

  if GossipFrame:IsVisible() == false then
    WowCyborg_CURRENTATTACK = "Interact";
    SetSpellRequest(interact);
    return true;
  end

end

function SendLootToBank() 
  MailFrameTab_OnClick(MailFrame,2) 
  SendMailNameEditBox:SetText("Mazbank")
  SendMailSubjectEditBox:SetText("payout")

  local money = GetMoney()
  if (money > 100000) then
    SetSendMailMoney(money - 100000)
  end
  
  local c,i,n,v=0;
  for b=0,4 do 
    for s=1,GetContainerNumSlots(b) do 
      i={GetContainerItemInfo(b,s)}
      n=i[7]
      if n then
        v={GetItemInfo(n)}
        if (C_Item.IsBound(ItemLocation:CreateFromBagAndSlot(b, s)) == false) then
          q=i[2]
          c=c+v[11]*q;
          UseContainerItem(b,s)
          print(n,q)
        end
      end;
    end;
  end;

  SendMailFrame_SendMail()
end

function CreateMailListenerFrame()
  local frame = CreateFrame("Frame");
  frame:RegisterEvent("CHAT_MSG_SAY");
  frame:SetScript("OnEvent", function(self, event, ...)
    command = ...;
    if string.find(command, "mailtime", 1, true) then
      print("Mail")
      sendingMail = true;      
    end

    if string.find(command, "pay", 1, true) then
      WowCyborg_DISABLED = true;
      SendLootToBank()
    end

    if string.find(command, "ok", 1, true) then
      WowCyborg_DISABLED = false;
      sendingMail = false;
      lastCheckSum = 0;
      lastCheckTime = 0;
      MailFrame:Hide()
    end

    if string.find(command, "reload", 1, true) then
      ReloadUI();
    end
    
    if string.find(command, "brb", 1, true) then
      paused = true;
    end
    
    if string.find(command, "back", 1, true) then
      paused = false;
    end
  end)
end

CreateMailListenerFrame()
