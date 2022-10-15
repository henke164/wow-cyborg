function PrintScript(type, description)
  local zone = GetZoneText();
  local target = UnitName("target");
  local x, y = C_Map.GetPlayerMapPosition(C_Map.GetBestMapForUnit("player"), "player"):GetXY();
  local str = "table.insert(steps, CreateStep(" ..
    math.ceil(x * 10000) / 100 ..
    ", " ..
    math.ceil(y * 10000) / 100 ..
  ", \"" .. zone .. "\", ";

  if target == nil then
    str = str .. "nil"
  else
    str = str .. "\"".. target .. "\""
  end

  str = str .. ", \"" .. description .. "\", \"" .. type .. "\"));";

  WowCyborg_Paste = WowCyborg_Paste .. "\r\n" .. str;
  KethoEditBox_Show(WowCyborg_Paste);
end

-- Edit box
function KethoEditBox_Show(text)
  if not KethoEditBox then
      local f = CreateFrame("Frame", "KethoEditBox", UIParent, "DialogBoxFrame")
      f:SetPoint("CENTER")
      f:SetSize(600, 500)
      
      f:SetBackdrop({
          bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
          edgeFile = "Interface\\PVPFrame\\UI-Character-PVP-Highlight", -- this one is neat
          edgeSize = 16,
          insets = { left = 8, right = 6, top = 8, bottom = 8 },
      })
      f:SetBackdropBorderColor(0, .44, .87, 0.5) -- darkblue
      
      -- Movable
      f:SetMovable(true)
      f:SetClampedToScreen(true)
      f:SetScript("OnMouseDown", function(self, button)
          if button == "LeftButton" then
              self:StartMoving()
          end
      end)
      f:SetScript("OnMouseUp", f.StopMovingOrSizing)
      
      -- ScrollFrame
      local sf = CreateFrame("ScrollFrame", "KethoEditBoxScrollFrame", KethoEditBox, "UIPanelScrollFrameTemplate")
      sf:SetPoint("LEFT", 16, 0)
      sf:SetPoint("RIGHT", -32, 0)
      sf:SetPoint("TOP", 0, -16)
      sf:SetPoint("BOTTOM", KethoEditBoxButton, "TOP", 0, 0)
      
      -- EditBox
      local eb = CreateFrame("EditBox", "KethoEditBoxEditBox", KethoEditBoxScrollFrame)
      eb:SetSize(sf:GetSize())
      eb:SetMultiLine(true)
      eb:SetAutoFocus(false) -- dont automatically focus
      eb:SetFontObject("ChatFontNormal")
      sf:SetScrollChild(eb)
      
      -- Resizable
      f:SetResizable(true)
      
      local rb = CreateFrame("Button", "KethoEditBoxResizeButton", KethoEditBox)
      rb:SetPoint("BOTTOMRIGHT", -6, 7)
      rb:SetSize(16, 16)
      
      rb:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
      rb:SetHighlightTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight")
      rb:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Down")
      
      rb:SetScript("OnMouseDown", function(self, button)
          if button == "LeftButton" then
              f:StartSizing("BOTTOMRIGHT")
              self:GetHighlightTexture():Hide() -- more noticeable
          end
      end)

      rb:SetScript("OnMouseUp", function(self, button)
          f:StopMovingOrSizing()
          self:GetHighlightTexture():Show()
          eb:SetWidth(sf:GetWidth())
      end)
      f:Show()

      local c1 = CreateButton("Accept Quest", KethoEditBox, 100);
      c1:SetPoint("RIGHT", KethoEditBox, "BOTTOMRIGHT", -10, 0);
      c1:SetScript("OnClick", function(self, event)
        PrintScript("QUEST_ACCEPTED", "Accept quest");
      end)
      
      local c2 = CreateButton("Turn in Quest", KethoEditBox, 100);
      c2:SetPoint("RIGHT", KethoEditBox, "BOTTOMRIGHT", -110, 0);
      c2:SetScript("OnClick", function(self, event)
        PrintScript("QUEST_TURNED_IN", "Turn in quest");
      end)
      
      local c3 = CreateButton("Act", KethoEditBox, 75);
      c3:SetPoint("RIGHT", KethoEditBox, "BOTTOMRIGHT", -210, 0);
      c3:SetScript("OnClick", function(self, event)
        local target = UnitName("target");
        if target == nil then
          PrintScript("QUEST_WATCH_UPDATE", "Click");
        else
          local enemy = UnitCanAttack("player", "target") == true;
          if enemy then
            PrintScript("QUEST_WATCH_UPDATE", "Kill");
          else 
            PrintScript("QUEST_WATCH_UPDATE", "Talk");
          end
        end
      end)
      
      local c4 = CreateButton("CLEAR", KethoEditBox, 110);
      c4:SetPoint("RIGHT", KethoEditBox, "BOTTOMLEFT", 100, 0);
      c4:SetScript("OnClick", function(self, event)
        WowCyborg_Paste = "";
        KethoEditBox_Show("");
      end)
  end
  
  if text then
      KethoEditBoxEditBox:SetText(text)
  end
  KethoEditBox:Show()
end

--KethoEditBox_Show();