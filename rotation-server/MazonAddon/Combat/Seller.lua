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

local sendingMail = false;
local pressSendMailButton = false;
local clickedAt = 0;
local switchCounter = 0;
local lastRepair = 0;
local mountCounter = 0;
local repairVendorName = "Drix Blackwrench";
local mailerNpcName = "Katy Stampwhistle";
local targetRepair = "F+5";
local targetMailer = "F+6";
local sendMailMacro = "F+7";

local interact = "F+9";
local targetMacro = "F+8";

local isSending = false;

function RenderMultiTargetRotation()
  SetSpellRequest(nil);
end

function RenderSingleTargetRotation()
  if (isSending) then
    return HandleVendoring();
  end

  SetSpellRequest(nil);
end

function HandleVendoring()
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
  return false;
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

  lastRepair = GetTime();
  print("Done")
end

print("Island rotation loaded")

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
    C_GossipInfo.SelectOption(1);
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
  SendMailNameEditBox:SetText("Mazonbank")
  SendMailSubjectEditBox:SetText("payout")

  local money = floor(GetMoney() / 10000);
  SendMailMoneyGold:SetText(money);
  
  local c,i,n,v=0;
  local count = 0;
  for b=0,4 do
    for s=1,GetContainerNumSlots(b) do 
      if count > 11 then
        break;
      end

      i={GetContainerItemInfo(b,s)}
      n=i[7]
      if n then
        v={GetItemInfo(n)}
        quality = v[3];
        ilvl = v[4];
        if ilvl ~= nil and quality ~= nil then
          if (C_Item.IsBound(ItemLocation:CreateFromBagAndSlot(b, s)) == false) then
            q=i[2]
            c=c+v[11]*q;
            UseContainerItem(b,s)
            count = count + 1
          end
        end;
      end;
    end;
  end;

  C_Timer.After(3, function()
    print("Sending mail...");
    SendMailNameEditBox:ClearFocus();
    pressSendMailButton = false;
    WowCyborg_DISABLED = false;
  end)
end

function CreateMailListenerFrame()
  local frame = CreateFrame("Frame");
  frame:RegisterEvent("CHAT_MSG_SAY");
  frame:SetScript("OnEvent", function(self, event, ...)
    command = ...;
    if string.find(command, ".", 1, true) then
      sendingMail = true;  
      C_Timer.After(5, function()
        print("Sending mail...");
        WowCyborg_DISABLED = true;
        SendLootToBank()
      end)    
    end
    
    if string.find(command, "k", 1, true) then
      print("Resuming...");
      pressSendMailButton = false;
      sendingMail = false;
      lastCheckSum = 0;
      lastCheckTime = 0;
      MailFrame:Hide()
    end
  end)
end

CreateMailListenerFrame()