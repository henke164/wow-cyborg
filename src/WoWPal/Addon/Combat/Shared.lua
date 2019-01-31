function SetSpellRequest(texture, spellNumber)
  r, g, b = GetColorFromNumber(spellNumber);
  texture:SetColorTexture(r, g, b);
end

function FindBuff(target, buffName)
  for i=1,40 do
    local name, _, _, _, _, etime = UnitBuff("pet", i);
    if name == buffName then
      time = GetTime();
      return name, etime - time;
    end
  end
end

function IsCastable(spellName, requiredEnergy)
    local spell, _, _, _, endTime = UnitCastingInfo("player");
  
    energy = UnitPower("player");
    cd = GetSpellCooldown(spellName, "spell");
  
    if cd == 0 then
      if energy > requiredEnergy then
        return true;
      end
    end
    return false;
  end
  
  function IsCastableAtEnemyTarget(spellName, requiredEnergy)
    if CheckInteractDistance("target", 4) == false then
      return false;
    end
  
    if UnitCanAttack("player","target") == false then
      return false;
    end
  
    if TargetIsAlive() == false then
      return false;
    end;
    
    return IsCastable(spellName, requiredEnergy);
  end
  
  function IsLowHealth()
    maxHp = UnitHealthMax("player");
    hp = UnitHealth("player");
    perc = (hp / maxHp) * 100;
    return perc < 80;
  end
  
  function TargetIsAlive()
    hp = UnitHealth("target");
    return hp > 0;
  end
  