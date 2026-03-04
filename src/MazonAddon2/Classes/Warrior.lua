if UnitClassBase("player") ~= "WARRIOR" then
  return
end

WowCyborg_MeleeDetectionSpell = "Pummel"
WowCyborg_NearbyEnemyDetectionSpell = "Intimidating Shout"
WowCyborg_PAUSE_KEYS = {
  "NUMPAD1",
  "NUMPAD5",
  "NUMPAD7",
  "NUMPAD8",
  "NUMPAD9",
  "X",
  "F",
  "§",
}

local ignorePainSpellId = 190456

local trackedSpells = {
  [ignorePainSpellId] = { duration = 11, slot = nil }, -- Ignore Pain
}

local function FindSpellSlots()
  for spellId, data in pairs(trackedSpells) do
    TrackSpell(spellId, data.duration)
    for slot = 1, 12 do
      local actionType, id = GetActionInfo(slot)
      if actionType == "spell" then
        local cleanId = tonumber(tostring(id))
        if cleanId == spellId then
          data.slot = slot
          break
        end
      end
    end
  end
end

local initFrame = CreateFrame("Frame")
initFrame:RegisterEvent("PLAYER_LOGIN")
initFrame:RegisterEvent("ACTIONBAR_SLOT_CHANGED")
initFrame:SetScript("OnEvent", function()
  FindSpellSlots()
end)

WowCyborg_ClassRotation = function()
  if WowCyborg_INCOMBAT == false then
    return false;
  end

  if ShouldRefreshBuff(ignorePainSpellId, 6) then
    local ignorePain = trackedSpells[ignorePainSpellId]
    if ignorePain.slot and IsSpellUsable(ignorePainSpellId) then
      SetSpellRequest(ignorePain.slot);
      WowCyborg_CURRENTATTACK = "Ignore Pain";
      return true;
    end
  end

  return false;
end
