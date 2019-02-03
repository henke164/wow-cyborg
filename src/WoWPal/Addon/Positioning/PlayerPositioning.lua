frameYPos = frameSize * 5

function CreateMapDataFrame(numberIndex)
    local frame, texture = CreateDefaultFrame(
      numberIndex * frameSize,
      frameYPos,
      frameSize,
      frameSize
    );
  
    frame:SetScript("OnUpdate", function(self, event, ...)
      local map = C_Map.GetBestMapForUnit("player");
      if map == nil then
        return;
      end

      local number = tonumber(strsub(map, numberIndex + 1, numberIndex + 1));
      local r, g, b = GetColorFromNumber(number);
      texture:SetColorTexture(r, g, b);
    end)
  end
  
  function CreateXDataFrame(decimalIndex)
    local frame, texture = CreateDefaultFrame(
      decimalIndex * frameSize,
      frameYPos - frameSize,
      frameSize,
      frameSize
    );
  
    frame:SetScript("OnUpdate", function(self, event, ...)
      local map = C_Map.GetBestMapForUnit("player");
      if map == nil then
        return;
      end
      
      local mapPos = C_Map.GetPlayerMapPosition(map, "player");
      if mapPos == nil then
        return;
      end
      px = mapPos:GetXY();

      local fullXString = tostring(px);
      local number = tonumber(strsub(fullXString, decimalIndex + 3, decimalIndex + 3));
      local r, g, b = GetColorFromNumber(number);
      texture:SetColorTexture(r, g, b);
    end)
  end
  
  function CreateYDataFrame(decimalIndex)
    local frame, texture = CreateDefaultFrame(
      decimalIndex * frameSize,
      frameYPos - (frameSize * 2), 
      frameSize, 
      frameSize
    );
  
    frame:SetScript("OnUpdate", function(self, event, ...)
      local map = C_Map.GetBestMapForUnit("player");
      if map == nil then
        return;
      end
      local mapPos = C_Map.GetPlayerMapPosition(map, "player");
      if mapPos == nil then
        return;
      end
      _, py = mapPos:GetXY();

      local fullYString = tostring(py);
      local number = tonumber(strsub(fullYString, decimalIndex + 3, decimalIndex + 3));
      local r, g, b = GetColorFromNumber(number);
      texture:SetColorTexture(r, g, b);
    end)
  end
  
  function CreateRotationDataFrame(numberIndex)
    local frame, texture = CreateDefaultFrame(
      numberIndex * frameSize,
      frameYPos - (frameSize * 3),
      frameSize,
      frameSize
    );
  
    frame:SetScript("OnUpdate", function(self, event, ...)
      local facing = GetPlayerFacing();
      if facing == nil then
        return;
      end

      local fullFacingString = tostring(facing * 1000);
      local number = tonumber(strsub(fullFacingString, numberIndex + 1, numberIndex + 1));
      local r, g, b = GetColorFromNumber(number);
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