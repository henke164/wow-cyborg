function SellItems(color)
  print("Selling items");
  for b = 0, 6 do
    for s = 1, C_Container.GetContainerNumSlots(b) do 
      local item = C_Container.GetContainerItemLink(b, s);
      if item and string.find(item, color) then
        print("Selling b:" .. b .. "s:" .. s);
        C_Container.UseContainerItem(b,s);
      end
    end
  end
end

function SellGrayItems()
  SellItems("cFF9D9D9D");
end

function SellGreenItems()
  SellItems("cFF1EFF00");
end

function CreateDefaultFrame(x, y, width, height)
  local frame = CreateFrame("Frame");
  frame:ClearAllPoints();
  frame:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", x, y);
  frame:SetWidth(width);
  frame:SetHeight(height);
  frame:SetMovable(true)
  frame:EnableMouse(true)
  frame:RegisterForDrag("LeftButton")
  frame:SetScript("OnDragStart", frame.StartMoving)
  frame:SetScript("OnDragStop", frame.StopMovingOrSizing)

  local bottom = frame:CreateTexture("WhiteTexture", "ARTWORK");
  bottom:SetWidth(250);
  bottom:SetHeight(30);
  bottom:SetColorTexture(0, 0, 0, 1);
  bottom:SetPoint("BOTTOM", frame, "BOTTOM", 0, 0);

  local texture = frame:CreateTexture("WhiteTexture", "ARTWORK");
  texture:SetWidth(width);
  texture:SetHeight(height);
  texture:ClearAllPoints();
  texture:SetColorTexture(0, 0, 0, 0.8);
  texture:SetAllPoints(frame);
  return frame, texture;
end

function CreateButton(text, parent, width)
	local button = CreateFrame("Button", nil, parent)
	button:SetWidth(25)
	button:SetHeight(25)
	
  if width then
    button:SetWidth(width)
  end
  
	button:SetText(text)
	button:SetNormalFontObject("GameFontNormal")
	
	local ntex = button:CreateTexture()
	ntex:SetTexture("Interface/Buttons/UI-Panel-Button-Up")
	ntex:SetTexCoord(0, 0.625, 0, 0.6875)
	ntex:SetAllPoints()	
	button:SetNormalTexture(ntex)
	
	local htex = button:CreateTexture()
	htex:SetTexture("Interface/Buttons/UI-Panel-Button-Highlight")
	htex:SetTexCoord(0, 0.625, 0, 0.6875)
	htex:SetAllPoints()
	button:SetHighlightTexture(htex)
	
	local ptex = button:CreateTexture()
	ptex:SetTexture("Interface/Buttons/UI-Panel-Button-Down")
	ptex:SetTexCoord(0, 0.625, 0, 0.6875)
	ptex:SetAllPoints()
	button:SetPushedTexture(ptex)
  return button;
end