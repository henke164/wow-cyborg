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
local targetMacro = "SHIFT+4";

local barbedShot = "1";
local killCommand = "2";
local mendPet = "3";
local beastialWrath = "5";
local aspectOfWild = "6";
local cobraShot = "7";
local multiShot = "8";

local immolate = "1";
local chaosBolt = "2";

function HandleVendoring()
  if InCombatLockdown() then
    return false
  end
  
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

local function GetBsCooldown()
  local bsCharges = GetSpellCharges("Barbed Shot");
  if bsCharges > 0 then
    return 0;
  end

  local bsStart, bsDuration = GetSpellCooldown("Barbed Shot");
  local bsCdLeft = bsStart + bsDuration - GetTime();
  return bsCdLeft;
end

-- Oggy
function RenderWarriorRotation()
  local bs = FindBuff("player", "Battle Shout");
  if bs == nil then
    WowCyborg_CURRENTATTACK = "Battle shout";
    return SetSpellRequest("8");
  end

  local vrBuff = FindBuff("player", "Victorious")
  if IsCastableAtEnemyTarget("Victory Rush", 0) and vrBuff ~= nil then
    WowCyborg_CURRENTATTACK = "Victory Rush";
    return SetSpellRequest("7");
  end

  if IsCastableAtEnemyTarget("Shield Slam", 0) then
    WowCyborg_CURRENTATTACK = "Shield Slam";
    return SetSpellRequest("1");
  end

  local revBuff = FindBuff("player", "Revenge!");
  if (revBuff == "Revenge!") then
    if IsCastableAtEnemyTarget("Revenge", 0) then
      WowCyborg_CURRENTATTACK = "Revenge";
      return SetSpellRequest("3");
    end
  end

  if IsCastable("Thunder Clap", 0) then
    WowCyborg_CURRENTATTACK = "Thunder Clap";
    return SetSpellRequest("2");
  end
  
  WowCyborg_CURRENTATTACK = "-"
  return SetSpellRequest(nil)
end

-- Klong
function RenderWarlockRotation()
  local target = UnitName("target")
  local targetHp = GetHealthPercentage("target")
  if target == nil or UnitCanAttack("player", "target") == false or targetHp < 2 then
    WowCyborg_CURRENTATTACK = "Target"
    return SetSpellRequest(targetMacro)
  end

  if target ~= nil and targetHp < 80 then
    switchCounter = switchCounter + 1;
    if switchCounter > 100 and switchCounter < 130 then
      WowCyborg_CURRENTATTACK = "Target"
      return SetSpellRequest(targetMacro)
    end

    if switchCounter > 500 then
      switchCounter = 0;
    end
  end

  if (UnitCanAttack("player", "target")) then
    local dcBuff = FindBuff("player", "Demonic Calling");
    local shards = UnitPower("player", 7)
    if shards >= 2 then
      WowCyborg_CURRENTATTACK = "Hand of Gul'dan";
      return SetSpellRequest("4");
    end
  
    local dcoBuff = FindBuff("player", "Demonic Core")
    if dcoBuff ~= nil then 
      WowCyborg_CURRENTATTACK = "Demonic";
      return SetSpellRequest("5");
    end

    if dcBuff ~= nil and IsCastable("Call Dreadstalkers", 0) then
      WowCyborg_CURRENTATTACK = "Demonic Calling";
      return SetSpellRequest("3");
    end

    WowCyborg_CURRENTATTACK = "Shadow Bolt"
    return SetSpellRequest("1")
  end
  
  WowCyborg_CURRENTATTACK = "-"
  return SetSpellRequest(nil)
end

-- MAZOON
function RenderHunterRotation()
  local target = UnitName("target")
  local targetHp = GetHealthPercentage("target")
  if target == nil or UnitCanAttack("player", "target") == false or targetHp < 2 then
    WowCyborg_CURRENTATTACK = "Target"
    return SetSpellRequest(targetMacro)
  end

  if target ~= nil and targetHp < 80 then
    switchCounter = switchCounter + 1;
    if switchCounter > 100 and switchCounter < 130 then
      WowCyborg_CURRENTATTACK = "Target"
      return SetSpellRequest(targetMacro)
    end

    if switchCounter > 500 then
      switchCounter = 0;
    end
  end

  local hp = GetHealthPercentage("player")
  if hp < 60 and IsCastable("Exhilaration", 0) then
    WowCyborg_CURRENTATTACK = "Heal"
    return SetSpellRequest("SHIFT+2")
  end

  local petHp = GetHealthPercentage("pet");
  if tostring(petHp) ~= "-nan(ind)" and petHp > 1 and petHp < 90 then
    if IsCastable("Mend pet", 0) then
      WowCyborg_CURRENTATTACK = "Mend pet";
      return SetSpellRequest(mendPet);
    end
  end

  if IsCastableAtEnemyTarget("Barbed Shot", 0) == false then
    local petBuff, petBuffTime = FindBuff("pet", "Frenzy");
    if petBuff == "Frenzy" and petBuffTime <= 3 then
      local bsCdLeft = GetBsCooldown();
      if bsCdLeft <= 3 then
        WowCyborg_CURRENTATTACK = "-";
        return SetSpellRequest(nil);
      end
    end
  end

  if IsCastableAtEnemyTarget("Barbed Shot", 0) then
    local petBuff, petBuffTime = FindBuff("pet", "Frenzy");
    if petBuff == "Frenzy" then
      if petBuffTime <= 2 then
        WowCyborg_CURRENTATTACK = "Barbed Shot";
        return SetSpellRequest(barbedShot);
      end
    end

    local bbCharges = GetSpellCharges("Barbed Shot");
    if bbCharges == 2 then
      WowCyborg_CURRENTATTACK = "Barbed Shot";
      return SetSpellRequest(barbedShot);
    end
  end

  local bcBuff, bcTimeLeft = FindBuff("player", "Beast Cleave");
  if bcBuff == nil or bcTimeLeft < 2 then
    if IsCastableAtEnemyTarget("Multi-Shot", 40) then
      WowCyborg_CURRENTATTACK = "Multi-Shot";
      return SetSpellRequest(multiShot);
    end
  end

  if CheckInteractDistance("target", 5) and IsCastableAtEnemyTarget("Kill Command", 30) then
    WowCyborg_CURRENTATTACK = "Kill Command";
    return SetSpellRequest(killCommand);
  end
    
  if IsCastableAtEnemyTarget("Aspect of the Wild", 0) then
    local bwBuff = FindBuff("player", "Bestial Wrath");
    local bwCd = GetSpellCooldown("Bestial Wrath", "spell");
    if bwCd == 0 or bwCd > 20 or not bwBuff == nil then
      WowCyborg_CURRENTATTACK = "Aspect of the Wild";
      return SetSpellRequest(aspectOfWild);
    end
  end

  if IsCastableAtEnemyTarget("Bestial Wrath", 0) then
    local aotwCd = GetSpellCooldown("Aspect of the Wild", "spell");
    local aotwBuff = FindBuff("player", "Aspect of the Wild");
    if aotwCd == 0 or aotwCd > 20 or not aotwBuff == nil then
      WowCyborg_CURRENTATTACK = "Bestial Wrath";
      return SetSpellRequest(beastialWrath);
    end
  end

  local bcBuff, bcTimeLeft = FindBuff("player", "Beast Cleave");
  if bcBuff == nil or bcTimeLeft < 2 then
    if IsCastableAtEnemyTarget("Multi-Shot", 40) then
      WowCyborg_CURRENTATTACK = "Multi-Shot";
      return SetSpellRequest(multiShot);
    end
  end

  if IsCastableAtEnemyTarget("Chimaera Shot", 0) then
    WowCyborg_CURRENTATTACK = "Chimaera Shot";
    return SetSpellRequest(chimaeraShot);
  end

  local energy = UnitPower("player");
  if IsCastableAtEnemyTarget("Cobra Shot", 0) and energy > 90 then
    WowCyborg_CURRENTATTACK = "Cobra Shot";
    return SetSpellRequest(cobraShot);
  end
  
  WowCyborg_CURRENTATTACK = "-";
  return SetSpellRequest(nil);
end

-- TheRing
function RenderDKRotation()
  if IsMounted() == false then
    mountCounter = mountCounter + 1;
    if mountCounter > 100 and mountCounter < 110 then
      WowCyborg_CURRENTATTACK = "Mount"
      return SetSpellRequest(createRepair)      
    end
    if mountCounter > 200 then
      mountCounter = 0;
    end
  end
  
  local vendorResult = HandleVendoring()
  if vendorResult == true then
    return;
  end

  WowCyborg_CURRENTATTACK = "-"
  return SetSpellRequest(nil)
end

-- Bommbom
function RenderBoomkinRotation()  
  local target = UnitName("target")
  local targetHp = GetHealthPercentage("target")
  if target == nil or UnitCanAttack("player", "target") == false or targetHp < 2 then
    WowCyborg_CURRENTATTACK = "Target"
    return SetSpellRequest(targetMacro)
  end

  if target ~= nil and targetHp < 80 then
    switchCounter = switchCounter + 1;
    if switchCounter > 100 and switchCounter < 130 then
      WowCyborg_CURRENTATTACK = "Target"
      return SetSpellRequest(targetMacro)
    end

    if switchCounter > 500 then
      switchCounter = 0;
    end
  end

  local eclipse = UnitPower("player", 8);

  if eclipse >= 40 then
    WowCyborg_CURRENTATTACK = "Starsurge"
    return SetSpellRequest("5")
  end

  local sfDebuff = FindDebuff("target", "Sunfire");
  if sfDebuff == nil then
    WowCyborg_CURRENTATTACK = "Sunfire"
    return SetSpellRequest("2")
  end

  local sfDebuff = FindDebuff("target", "Moonfire");
  if sfDebuff == nil then
    WowCyborg_CURRENTATTACK = "Moonfire"
    return SetSpellRequest("1")
  end

  WowCyborg_CURRENTATTACK = "Solar wrath " .. solarEmpowerment
  return SetSpellRequest("4")
end

function RenderMultiTargetRotation()
  return RenderSingleTargetRotation()
end

function RenderSingleTargetRotation()
  if sendingMail then
    return HandleMailing()
  end

  if clickedAt + 2 > GetTime() then
    WowCyborg_CURRENTATTACK = "Looting..."
    return SetSpellRequest(nil)
  end

  className = UnitClass("player")

  if className == "Death Knight" then
    return RenderDKRotation()
  end

  local vendorResult = HandleVendoring()
  if vendorResult == true then
    return;
  end
  
  if className == "Hunter" then
    return RenderHunterRotation()
  end
  
  if className == "Warlock" then
    return RenderWarlockRotation()
  end
  
  if className == "Warrior" then
    return RenderWarriorRotation()
  end
  
  if className == "Druid" then
    return RenderBoomkinRotation()
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
      if n and string.find(n,"Deep Sea Satin") == nil and (string.find(n,"Map") or string.find(n,"9d9d9d") or string.find(n,"1eff00")) then 
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
      if n and (string.find(n,"Tidespray Linen") ~= nil or string.find(n,"Deep Sea Satin") ~= nil) then 
        v={GetItemInfo(n)}
        q=i[2]
        c=c+v[11]*q;
        UseContainerItem(b,s)
        print(n,q)
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
  end)
end

CreateMailListenerFrame()