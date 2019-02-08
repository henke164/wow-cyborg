local function RenderMultiTargetRotation(texture)
  return SetSpellRequest(texture, nil);
end

local function RenderSingleTargetRotation(texture)
  return SetSpellRequest(texture, nil);
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