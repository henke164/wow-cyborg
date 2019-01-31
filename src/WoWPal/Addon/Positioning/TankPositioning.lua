frameYPos = -50;
frameWidth = 10;
frameHeight = 10;
tankIndex = -1;

function CreateMapDataFrame(numberIndex)
  local frame, texture = CreateDefaultFrame(
    numberIndex * frameWidth,
    frameYPos,
    frameWidth,
    frameHeight
  );

  frame:SetScript("OnUpdate", function(self, event, ...)
    if tankIndex == -1 then
      members = GetNumGroupMembers();
      if members == 0 then
        return;
      end

      for i = 1, members, 1
      do
        role = UnitGroupRolesAssigned("party" .. i);
        if role == "TANK" then
          tankIndex = i;
          break;
        end
      end
    else
      map = C_Map.GetBestMapForUnit("party" .. tankIndex);
      number = tonumber(strsub(map, numberIndex + 1, numberIndex + 1));
      r, g, b = GetColorFromNumber(number);
      texture:SetColorTexture(r, g, b);
    end
  end)
end

function CreateXDataFrame(decimalIndex)
  local frame, texture = CreateDefaultFrame(
    decimalIndex * frameWidth,
    frameYPos - frameHeight,
    frameWidth,
    frameHeight
  );

  frame:SetScript("OnUpdate", function(self, event, ...)
    if tankIndex == -1 then
      return
    end
    map = C_Map.GetBestMapForUnit("party" .. tankIndex);
    px = C_Map.GetPlayerMapPosition(map, "party" .. tankIndex):GetXY();
    fullXString = tostring(px);
    number = tonumber(strsub(fullXString, decimalIndex + 3, decimalIndex + 3));
    r, g, b = GetColorFromNumber(number);
    texture:SetColorTexture(r, g, b);
  end)
end

function CreateYDataFrame(decimalIndex)
  local frame, texture = CreateDefaultFrame(
    decimalIndex * frameWidth,
    frameYPos - (frameHeight * 2), 
    frameWidth, 
    frameHeight
  );

  frame:SetScript("OnUpdate", function(self, event, ...)
    if tankIndex == -1 then
      return
    end
    map = C_Map.GetBestMapForUnit("party" .. tankIndex);
    _, py = C_Map.GetPlayerMapPosition(map, "party" .. tankIndex):GetXY();
    fullYString = tostring(py);
    number = tonumber(strsub(fullYString, decimalIndex + 3, decimalIndex + 3));
    r, g, b = GetColorFromNumber(number);
    texture:SetColorTexture(r, g, b);
  end)
end
  
CreateMapDataFrame(0);
CreateMapDataFrame(1);
CreateMapDataFrame(2);
CreateMapDataFrame(3);

CreateXDataFrame(0);
CreateXDataFrame(1);
CreateXDataFrame(2);
CreateXDataFrame(3);

CreateYDataFrame(0);
CreateYDataFrame(1);
CreateYDataFrame(2);
CreateYDataFrame(3);