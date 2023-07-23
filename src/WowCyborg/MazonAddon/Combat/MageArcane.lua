--[[
  Button    Spell
]]--
local buttons = {}
buttons["arcane_blast"] = "1";
buttons["arcane_missiles"] = "2";
buttons["touch_of_the_magi"] = "3";
buttons["arcane_barrage"] = "4";
buttons["arcane_orb"] = "5";
buttons["nether_tempest"] = "6";
buttons["ice_floes"] = "7";
buttons["scorch"] = "8";
buttons["rune_of_power"] = "9";
buttons["cancel_buff"] = "0";
buttons["shifting_power"] = "F+1";
buttons["evocation"] = "F+2";

WowCyborg_PAUSE_KEYS = {
  "R",
  "F",
  "§"
}

function RenderMultiTargetRotation()  
  if WowCyborg_INCOMBAT == false then
    return SetSpellRequest(nil);
  end

  return RenderRotation(true);
end

function RenderSingleTargetRotation(holdBurst)
  if WowCyborg_INCOMBAT == false then
    return SetSpellRequest(nil);
  end

  return RenderRotation();
end


function RenderRotation()
  if UnitChannelInfo("player") ~= nil then
    return SetSpellRequest(nil);
  end

  local speed = GetUnitSpeed("player");

  local actionName = Hekili.GetQueue().Primary[1].actionName;
  if actionName == "rune_of_power" and speed > 0 then
    actionName = Hekili.GetQueue().Primary[2].actionName
  end

  if holdBurst and (actionName == "combustion" or actionName == "shifting_power") then
    actionName = Hekili.GetQueue().Primary[2].actionName
  end

  WowCyborg_CURRENTATTACK = actionName;

  button = buttons[actionName];


  if actionName == "fireball" or actionName == "pyroblast" then
    if speed > 0 then
      if FindBuff("player", "Ice Floes") == nil then
        if IsCastable("Ice Floes", 0) then
          return SetSpellRequest("7");
        else
          return SetSpellRequest("8");
        end
      end
    end
  end

  if button ~= nil then
    return SetSpellRequest(button);
  end
  
  return SetSpellRequest(nil);
end

print("Mage rotation loaded");