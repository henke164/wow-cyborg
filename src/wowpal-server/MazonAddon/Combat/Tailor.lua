--257099
local craft = "SHIFT+6";

function RenderMultiTargetRotation()
  WowCyborg_CURRENTATTACK = "-";
  return SetSpellRequest(nil);
end

function SellPants()
  
  for x = 0,10 do
    local c,i,n,v=0;
    for b=0,4 do 
      for s=1,GetContainerNumSlots(b) do 
        i={GetContainerItemInfo(b,s)} 
        n=i[7]
        if n and string.find(n,"Tidespray Linen Pants") ~= nil then
          v={GetItemInfo(n)}
          q=i[2]
          c=c+v[11]*q;
          UseContainerItem(b,s)
        end;
      end;
    end;
  end;
end

function RenderSingleTargetRotation()
  local totalFreeSlots = 0

  for bagID = 0,4 do
    freeSlots = GetContainerNumFreeSlots(bagID)
    totalFreeSlots = totalFreeSlots + freeSlots
  end

  if CanMerchantRepair() and totalFreeSlots < 3 then
    SellPants()
  end

  local nylonThreads = GetItemCount("Nylon Thread")
  if CanMerchantRepair() and nylonThreads < 200 then
    BuyMerchantItem(3, 200)
  end

  if (TradeSkillFrame:IsVisible() == true) then
    WowCyborg_CURRENTATTACK = "Craft";
    return SetSpellRequest(craft);
  end

  WowCyborg_CURRENTATTACK = "-";
  return SetSpellRequest(nil);
end

print("Tailor rotation loaded");