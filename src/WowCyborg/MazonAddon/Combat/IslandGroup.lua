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

-------------------------------------- WARRIOR --------------------------------------------
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

-------------------------------------- WARLOCK --------------------------------------------
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

  local petHp = GetHealthPercentage("pet");
  if tostring(petHp) == "-nan(ind)" then
    if IsCastable("Fel domination", 0) then
      WowCyborg_CURRENTATTACK = "Fel domination";
      return SetSpellRequest(8);
    end
    
    if IsCastable("Summon Imp", 0) then
      WowCyborg_CURRENTATTACK = "Summon Imp";
      return SetSpellRequest(0);
    end
  end

  if (UnitCanAttack("player", "target")) then
    local nearbyEnemies = GetNearbyEnemyCount();
    local dcBuff = FindBuff("player", "Demonic Calling");
    local shards = UnitPower("player", 7)
    if shards >= 2 then
      WowCyborg_CURRENTATTACK = "Hand of Gul'dan";
      return SetSpellRequest("4");
    end

    if nearbyEnemies > 3 then
      if IsCastable("Summon Demonic Tyrant", 0) then
        WowCyborg_CURRENTATTACK = "Summon Demonic Tyrant";
        return SetSpellRequest("2");
      end
    end
    
    local dcoBuff = FindBuff("player", "Demonic Core")
    if dcoBuff ~= nil then 
      WowCyborg_CURRENTATTACK = "Demonic";
      return SetSpellRequest("5");
    end

    if dcBuff ~= nil and shards >= 1 and IsCastable("Call Dreadstalkers", 0) then
      WowCyborg_CURRENTATTACK = "Demonic Calling";
      return SetSpellRequest("3");
    end

    WowCyborg_CURRENTATTACK = "Shadow Bolt"
    return SetSpellRequest("1")
  end
  
  WowCyborg_CURRENTATTACK = "-"
  return SetSpellRequest(nil)
end

-------------------------------------- MAGE --------------------------------------------
function RenderMageRotation()
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

  local castingSpell = UnitCastingInfo("player");
  local combustionCd = GetSpellCooldown("Combustion", "spell");
  local combustionBuff, combustionBuffTTL = FindBuff("player", "Combustion");

  if combustionCd == 0 and IsCastable("Rune of Power", 0) and FindBuff("player", "Rune of Power") == nil then
    WowCyborg_CURRENTATTACK = "Rune of Power";
    return SetSpellRequest("1");
  end

  if (FindBuff("player", "Arcane Intellect") == nil) then
    WowCyborg_CURRENTATTACK = "Arcane Intellect";
    return SetSpellRequest("2");
  end

  if IsCastable("Combustion", 0) then
    WowCyborg_CURRENTATTACK = "Combustion";
    return SetSpellRequest("3");
  end

  local ropCharges = GetSpellCharges("Rune of Power");
  if IsMoving() == false and ropCharges == 2 and FindBuff("player", "Rune of Power") == nil then
    WowCyborg_CURRENTATTACK = "Rune of Power";
    return SetSpellRequest("1");
  end

  if FindBuff("player", "Hot Streak!") ~= nil then
    if IsCastableAtEnemyTarget("Pyroblast", 0) then
      WowCyborg_CURRENTATTACK = "Pyroblast";
      return SetSpellRequest("4");
    end
  end

  if combustionBuff and combustionBuffTTL < 1 and IsCastable("Dragon's Breath", 0) and CheckInteractDistance("target", 5) then
    WowCyborg_CURRENTATTACK = "Dragon's Breath";
    return SetSpellRequest("5");
  end
  
  if FindBuff("player", "Heating Up") ~= nil and IsCastableAtEnemyTarget("Fire Blast", 0) then
    WowCyborg_CURRENTATTACK = "Fire Blast";
    return SetSpellRequest("6");
  end

  local enemyHP = GetHealthPercentage("target");
  if enemyHP < 30 then
    if IsCastableAtEnemyTarget("Scorch", 0) then
      WowCyborg_CURRENTATTACK = "Scorch";
      return SetSpellRequest("7");
    end
  end 
  
  if IsCastableAtEnemyTarget("Fireball", 0) then
    WowCyborg_CURRENTATTACK = "Fireball";
    return SetSpellRequest("8");
  end

  WowCyborg_CURRENTATTACK = "-";
  return SetSpellRequest(nil);
end

-------------------------------------- HUNTER --------------------------------------------
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

  if IsCastableAtEnemyTarget("Kill Command", 30) then
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

-------------------------------------- Paladin VENDOR --------------------------------------------

function RenderPaladinRotation()
  local vendorResult = HandleVendoring()
  if vendorResult == true then
    return;
  end

  local target = UnitName("target")
  local targetHp = GetHealthPercentage("target")
  if target == nil or UnitCanAttack("player", "target") == false or targetHp < 2 then
    WowCyborg_CURRENTATTACK = "Target"
    return SetSpellRequest(targetMacro)
  end

  local holyPower = UnitPower("player", 9);
  local poweredUp = holyPower > 2;

  local divine = FindBuff("player", "Divine Purpose")
  if poweredUp == false then
    poweredUp = divine ~= nil;
  end

  local concetration = FindBuff("player", "Consecration");
  if concetration == nil and IsCastableAtEnemyTarget("Consecration", 0) then
    WowCyborg_CURRENTATTACK = "Consecration";
    return SetSpellRequest(6);
  end

  local nearbyEnemies = GetNearbyEnemyCount();

  if nearbyEnemies > 4 and IsCastable("Avenging Wrath", 0) then
    WowCyborg_CURRENTATTACK = "Avenging Wrath";
    return SetSpellRequest("F+4");
  end

  if IsCastableAtEnemyTarget("Avenger's Shield", 0) then
    WowCyborg_CURRENTATTACK = "Avenger's Shield";
    return SetSpellRequest(2);
  end

  if IsCastableAtEnemyTarget("Hammer of Wrath", 0) then
    WowCyborg_CURRENTATTACK = "Hammer of Wrath";
    return SetSpellRequest(5);
  end

  if IsCastableAtEnemyTarget("Blessed Hammer", 0) then
    WowCyborg_CURRENTATTACK = "Blessed Hammer";
    return SetSpellRequest(3);
  end

  if IsCastableAtEnemyTarget("Shield of the Righteous", 0) and poweredUp then
    WowCyborg_CURRENTATTACK = "Shield of the Righteous";
    return SetSpellRequest(4);
  end

  if IsCastableAtEnemyTarget("Judgment", 0) then
    WowCyborg_CURRENTATTACK = "Judgment";
    return SetSpellRequest(1);
  end
  
  if IsCastableAtEnemyTarget("Divine Toll", 0) then
    WowCyborg_CURRENTATTACK = "Divine Toll";
    return SetSpellRequest(7);
  end

  WowCyborg_CURRENTATTACK = "-";
  return SetSpellRequest(nil);
end

-------------------------------------- DK VENDOR --------------------------------------------
function RenderDKRotation()
  local vendorResult = HandleVendoring()
  if vendorResult == true then
    return;
  end

  if IsCastableAtEnemyTarget("Death Strike", 45) then
    WowCyborg_CURRENTATTACK = "Death Strike"
    return SetSpellRequest("7")
  end

  local target = UnitName("target")
  if target == nil or IsSpellInRange("Death Grip", "target") == 0 then
    WowCyborg_CURRENTATTACK = "Target"
    return SetSpellRequest(targetMacro)
  end

  if CheckInteractDistance("target", 3) and IsCastable("Dark Transformation", 0) then
    WowCyborg_CURRENTATTACK = "Dark Transformation"
    return SetSpellRequest("2")
  end
  
  if CheckInteractDistance("target", 3) and IsCastable("Army of the Dead", 0) then
    WowCyborg_CURRENTATTACK = "Army of the Dead"
    return SetSpellRequest("3")
  end

  if IsCastableAtEnemyTarget("Death Grip", 0) then
    WowCyborg_CURRENTATTACK = "Death Grip"
    return SetSpellRequest("6")
  end

  local debuff = FindDebuff("target", "Virulent Plague");
  if IsCastableAtEnemyTarget("Outbreak", 0) and debuff == nil then
    WowCyborg_CURRENTATTACK = "Outbreak"
    return SetSpellRequest("4")
  end
  
  if IsCastableAtEnemyTarget("Clawing Shadows", 0) then
    WowCyborg_CURRENTATTACK = "Clawing Shadows"
    return SetSpellRequest("5")
  end


  if IsCastableAtEnemyTarget("Heart Strike", 0) == false then
    WowCyborg_CURRENTATTACK = "Target"
    return SetSpellRequest(targetMacro)
  end

  WowCyborg_CURRENTATTACK = "-"
  return SetSpellRequest(nil)
end

-------------------------------------- Boomkin --------------------------------------------
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
  local speed = GetUnitSpeed("player");

  if eclipse >= 50 then
    WowCyborg_CURRENTATTACK = "Starfall"
    return SetSpellRequest("6")
  end

  local solar = FindBuff("player", "Eclipse (Solar)");
  if solar ~= nil then
    if speed > 0 then
      if IsCastableAtEnemyTarget("Sunfire", 0) then
        WowCyborg_CURRENTATTACK = "Sunfire";
        return SetSpellRequest(sunfire);
      end
    end

    if IsCastableAtEnemyTarget("Wrath", 0) then
      WowCyborg_CURRENTATTACK = "Wrath";
      return SetSpellRequest(wrath);
    end
  end
  
  local lunar = FindBuff("player", "Eclipse (Lunar)");
  if lunar ~= nil then
    if speed > 0 then
      if IsCastableAtEnemyTarget("Moonfire", 0) then
        WowCyborg_CURRENTATTACK = "Moonfire";
        return SetSpellRequest(moonfire);
      end
    end

    if IsCastableAtEnemyTarget("Starfire", 0) then
      WowCyborg_CURRENTATTACK = "Starfire";
      return SetSpellRequest(starfire);
    end
  end

  WowCyborg_CURRENTATTACK = "Solar wrath";
  return SetSpellRequest("4")
end

function RenderMultiTargetRotation()
  return RenderSingleTargetRotation()
end

function RenderSingleTargetRotation()
  if pressSendMailButton then
    WowCyborg_CURRENTATTACK = "Pressing Send!"
    return SetSpellRequest(sendMailMacro)
  end

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

  if className == "Mage" then
    return RenderDKRotation()--RenderMageRotation()
  end
  
  if className == "Paladin" then
    return RenderPaladinRotation()
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