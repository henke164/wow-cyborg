local function RenderMultiTargetRotation()
  return SetSpellRequest();
end

local function RenderSingleTargetRotation()
  return SetSpellRequest();
end

function CreateRotationFrame()
  print('--Wow Cyborg--');
  print('No rotation is selected.');
  print('To list available rotations, type "rotation list".');
  local frame, texture = CreateDefaultFrame(frameSize * 2, frameSize, frameSize, frameSize);

  frame:SetScript("OnUpdate", function(self, event, ...)
    if WowCyborg_AOE_Rotation == true then
      RenderMultiTargetRotation(texture);
    end
    if WowCyborg_AOE_Rotation == false then
      RenderSingleTargetRotation(texture);
    end
  end)

  RenderFontFrame();
end