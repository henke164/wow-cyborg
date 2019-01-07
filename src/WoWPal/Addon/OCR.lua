frameYPos = 0;
frameWidth = 10;
frameHeight = 10;

function GetColorFromNumber(number)
  if number == 0 then
    return 0, 0, 0;
  end
  if number == 1 then
    return 0, 0, 0.5;
  end
  if number == 2 then
    return 0, 0, 1;
  end
  if number == 3 then
    return 0, 0.5, 0;
  end
  if number == 4 then
    return 0, 1, 0;
  end
  if number == 5 then
    return 0.5, 0, 0;
  end
  if number == 6 then
    return 1, 0, 0;
  end
  if number == 7 then
    return 0, 0.5, 1;
  end
  if number == 8 then
    return 0, 1, 1;
  end
  if number == 9 then
    return 0.5, 0, 1;
  end
  return 1, 1, 1;
end

function CreateMapDataFrame(numberIndex)
  local frame, texture = CreateDefaultFrame(
    numberIndex * frameWidth,
    frameYPos,
    frameWidth,
    frameHeight
  );

  frame:SetScript("OnUpdate", function(self, event, ...)
    map = C_Map.GetBestMapForUnit("player");
    number = tonumber(strsub(map, numberIndex + 1, numberIndex + 1));
    r, g, b = GetColorFromNumber(number);
    texture:SetColorTexture(r, g, b);
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
    map = C_Map.GetBestMapForUnit("player");
    px = C_Map.GetPlayerMapPosition(map, "player"):GetXY();
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
    map = C_Map.GetBestMapForUnit("player");
    _, py = C_Map.GetPlayerMapPosition(map, "player"):GetXY();
    fullYString = tostring(py);
    number = tonumber(strsub(fullYString, decimalIndex + 3, decimalIndex + 3));
    r, g, b = GetColorFromNumber(number);
    texture:SetColorTexture(r, g, b);
  end)
end

function CreateRotationDataFrame(numberIndex)
  local frame, texture = CreateDefaultFrame(
    numberIndex * frameWidth,
    frameYPos - (frameHeight * 3),
    frameWidth,
    frameHeight
  );

  frame:SetScript("OnUpdate", function(self, event, ...)
    facing = GetPlayerFacing();
    fullFacingString = tostring(facing * 1000);
    number = tonumber(strsub(fullFacingString, numberIndex + 1, numberIndex + 1));
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

CreateRotationDataFrame(0);
CreateRotationDataFrame(1);
CreateRotationDataFrame(2);
CreateRotationDataFrame(3);
