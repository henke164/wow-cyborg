WowCyborg_ActiveBuffs = {}
WowCyborg_TrackedSpells = {}

WowCyborg_ActiveTimers = {}

function TrackSpell(spellId, duration)
  WowCyborg_TrackedSpells[spellId] = duration
end

local function ExtractSpellId(secretValue)
  local str = tostring(secretValue)
  local i = 0
  for part in str:gmatch("[^-]+") do
    i = i + 1
    if i == 6 then
      return tonumber(part)
    end
  end
  return nil
end

local function ScanBuffs()
  for spellId, _ in pairs(WowCyborg_TrackedSpells) do
    local found = false
    for i = 1, 40 do
      local auraData = C_UnitAuras.GetAuraDataByIndex("player", i, "HELPFUL")
      if not auraData then break end
      local auraSpellId = tonumber(tostring(auraData.spellId))
      if auraSpellId == spellId then
        found = true
        break
      end
    end
    if not found then
      WowCyborg_ActiveBuffs[spellId] = nil
      WowCyborg_ActiveTimers[spellId] = nil
    end
  end
end

local function CheckTimers()
  local now = GetTime()
  for spellId, expiry in pairs(WowCyborg_ActiveTimers) do
    if now >= expiry then
      WowCyborg_ActiveBuffs[spellId] = nil
      WowCyborg_ActiveTimers[spellId] = nil
    end
  end
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_LOGIN")
frame:RegisterEvent("PLAYER_REGEN_ENABLED")
frame:RegisterUnitEvent("UNIT_SPELLCAST_SUCCEEDED", "player")
frame:RegisterUnitEvent("UNIT_SPELLCAST_FAILED", "player")

frame:SetScript("OnEvent", function(_, event, _, data)
  if event == "PLAYER_LOGIN" or event == "PLAYER_REGEN_ENABLED" then
    ScanBuffs()
    return
  end

  if event == "UNIT_SPELLCAST_SUCCEEDED" then
    local extracted = ExtractSpellId(data)
    if extracted and WowCyborg_TrackedSpells[extracted] then
      local duration = WowCyborg_TrackedSpells[extracted]
      WowCyborg_ActiveBuffs[extracted] = true
      WowCyborg_ActiveTimers[extracted] = GetTime() + duration
    end
  end
end)

frame:SetScript("OnUpdate", function(_, elapsed)
  CheckTimers()
end)
