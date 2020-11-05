local barbed_shot = "2"
local kill_command = "3"
local bestial_wrath = "8"
local cobra_shot = "1"
local aspect_of_the_wild = "SHIFT+2"
local multishot = "7"
local blood_fury = "SHIFT+3"

local function cds()
  if (not (true)) then
    return
  end

  -- ancestral call
  if (GetCooldown("bestial wrath")>30) then
    if IsCastableAtEnemyTarget("ancestral call", 0) then
      WowCyborg_CURRENTATTACK = "ancestral call";
      return SetSpellRequest(ancestral_call);
    end
  end
  
  -- fireblood
  if (GetCooldown("bestial wrath")>30) then
    if IsCastableAtEnemyTarget("fireblood", 0) then
      WowCyborg_CURRENTATTACK = "fireblood";
      return SetSpellRequest(fireblood);
    end
  end
  
  -- berserking
  if (FindBuff("player", "aspect of the wild") ~= nil and (30>GetCooldownDuration("berserking")+GetBuffTimeLeft("player", "berserking") or (GetHealthPercentage("target")<35 or  not TalentEnabled("killer instinct"))) or 30<13) then
    if IsCastableAtEnemyTarget("berserking", 0) then
      WowCyborg_CURRENTATTACK = "berserking";
      return SetSpellRequest(berserking);
    end
  end
  
  -- blood fury
  if (FindBuff("player", "aspect of the wild") ~= nil and (30>GetCooldownDuration("blood fury")+GetBuffTimeLeft("player", "blood fury") or (GetHealthPercentage("target")<35 or  not TalentEnabled("killer instinct"))) or 30<16) then
    if IsCastableAtEnemyTarget("blood fury", 0) then
      WowCyborg_CURRENTATTACK = "blood fury";
      return SetSpellRequest(blood_fury);
    end
  end
  
  -- lights judgment
  if (FindBuff("pet", "frenzy") ~= nil and GetBuffTimeLeft("pet", "frenzy")>GetGCDMax() or  not FindBuff("pet", "frenzy") ~= nil) then
    if IsCastableAtEnemyTarget("lights judgment", 0) then
      WowCyborg_CURRENTATTACK = "lights judgment";
      return SetSpellRequest(lights_judgment);
    end
  end
  
  -- potion
  if (FindBuff("player", "bestial wrath") ~= nil and FindBuff("player", "aspect of the wild") ~= nil and GetHealthPercentage("target")<35 or ((false or false) and 30<61 or 30<26)) then
    if IsCastableAtEnemyTarget("potion", 0) then
      WowCyborg_CURRENTATTACK = "potion";
      return SetSpellRequest(potion);
    end
  end
  
  -- worldvein resonance
  if ((false or GetCooldown("aspect of the wild")<GetCurrentSpellGCD("worldvein resonance") or 30<20) or  not true) then
    if IsCastableAtEnemyTarget("worldvein resonance", 0) then
      WowCyborg_CURRENTATTACK = "worldvein resonance";
      return SetSpellRequest(worldvein_resonance);
    end
  end
  
  -- guardian of azeroth
  if (GetCooldown("aspect of the wild")<10 or 30>GetCooldown("guardian of azeroth")+GetBuffTimeLeft("player", "guardian of azeroth") or 30<30) then
    if IsCastableAtEnemyTarget("guardian of azeroth", 0) then
      WowCyborg_CURRENTATTACK = "guardian of azeroth";
      return SetSpellRequest(guardian_of_azeroth);
    end
  end
  
  -- ripple in space
  if (true) then
    if IsCastableAtEnemyTarget("ripple in space", 0) then
      WowCyborg_CURRENTATTACK = "ripple in space";
      return SetSpellRequest(ripple_in_space);
    end
  end
  
  -- memory of lucid dreams
  if (true) then
    if IsCastableAtEnemyTarget("memory of lucid dreams", 0) then
      WowCyborg_CURRENTATTACK = "memory of lucid dreams";
      return SetSpellRequest(memory_of_lucid_dreams);
    end
  end
  
  -- reaping flames
  if (GetHealthPercentage("target")>80 or GetHealthPercentage("target")<=20 or 30>30) then
    if IsCastableAtEnemyTarget("reaping flames", 0) then
      WowCyborg_CURRENTATTACK = "reaping flames";
      return SetSpellRequest(reaping_flames);
    end
  end
  
end

local function st()
  -- barbed shot
  if (FindBuff("pet", "frenzy") ~= nil and GetBuffTimeLeft("pet", "frenzy")<GetCurrentSpellGCD("barbed shot") or GetCooldown("bestial wrath") and (GetFullRechargeTime("barbed shot")<GetCurrentSpellGCD("barbed shot") or true and GetCooldown("aspect of the wild")<GetCurrentSpellGCD("barbed shot"))) then
    if IsCastableAtEnemyTarget("barbed shot", 0) then
      WowCyborg_CURRENTATTACK = "barbed shot";
      return SetSpellRequest(barbed_shot);
    end
  end
  
  -- concentrated flame
  if (UnitPower("player")+GetPowerRegen()*GetCurrentSpellGCD("concentrated flame")<UnitPowerMax("player") and FindBuff("player", "bestial wrath") == nil and ( not GetDebuffTimeLeft("target", "concentrated flame burn") and  not false) or GetFullRechargeTime("concentrated flame")<GetCurrentSpellGCD("concentrated flame") or 30<5) then
    if IsCastableAtEnemyTarget("concentrated flame", 0) then
      WowCyborg_CURRENTATTACK = "concentrated flame";
      return SetSpellRequest(concentrated_flame);
    end
  end
  
  -- aspect of the wild
  if (FindBuff("player", "aspect of the wild") == nil and (GetSpellCharges("barbed shot")<1 or  not true)) then
    if IsCastableAtEnemyTarget("aspect of the wild", 0) then
      WowCyborg_CURRENTATTACK = "aspect of the wild";
      return SetSpellRequest(aspect_of_the_wild);
    end
  end
  
  -- stampede
  if (FindBuff("player", "aspect of the wild") ~= nil and FindBuff("player", "bestial wrath") ~= nil or 30<15) then
    if IsCastableAtEnemyTarget("stampede", 0) then
      WowCyborg_CURRENTATTACK = "stampede";
      return SetSpellRequest(stampede);
    end
  end
  
  -- a murder of crows
  if (true) then
    if IsCastableAtEnemyTarget("a murder of crows", 0) then
      WowCyborg_CURRENTATTACK = "a murder of crows";
      return SetSpellRequest(a_murder_of_crows);
    end
  end
  
  -- focused azerite beam
  if (FindBuff("player", "bestial wrath") == nil or 30<5) then
    if IsCastableAtEnemyTarget("focused azerite beam", 0) then
      WowCyborg_CURRENTATTACK = "focused azerite beam";
      return SetSpellRequest(focused_azerite_beam);
    end
  end
  
  -- the unbound force
  if (FindBuff("player", "reckless force") ~= nil or GetBuffStacks("reckless force counter")<10 or 30<5) then
    if IsCastableAtEnemyTarget("the unbound force", 0) then
      WowCyborg_CURRENTATTACK = "the unbound force";
      return SetSpellRequest(the_unbound_force);
    end
  end
  
  -- bestial wrath
  if (TalentEnabled("one with the pack") and GetBuffTimeLeft("player", "bestial wrath")<GetCurrentSpellGCD("bestial wrath") or FindBuff("player", "bestial wrath") == nil and GetCooldown("aspect of the wild")>15 or 30<15+GetCurrentSpellGCD("bestial wrath")) then
    if IsCastableAtEnemyTarget("bestial wrath", 0) then
      WowCyborg_CURRENTATTACK = "bestial wrath";
      return SetSpellRequest(bestial_wrath);
    end
  end
  
  -- barbed shot
  if (1>1 and GetBuffTimeLeft("player", "dance of death")<GetCurrentSpellGCD("barbed shot")) then
    if IsCastableAtEnemyTarget("barbed shot", 0) then
      WowCyborg_CURRENTATTACK = "barbed shot";
      return SetSpellRequest(barbed_shot);
    end
  end
  
  -- blood of the enemy
  if (GetBuffTimeLeft("player", "aspect of the wild")>10+GetCurrentSpellGCD("blood of the enemy") or 30<10+GetCurrentSpellGCD("blood of the enemy")) then
    if IsCastableAtEnemyTarget("blood of the enemy", 0) then
      WowCyborg_CURRENTATTACK = "blood of the enemy";
      return SetSpellRequest(blood_of_the_enemy);
    end
  end
  
  -- kill command
  if (true) then
    if IsCastableAtEnemyTarget("kill command", 0) then
      WowCyborg_CURRENTATTACK = "kill command";
      return SetSpellRequest(kill_command);
    end
  end
  
  -- bag of tricks
  if (FindBuff("player", "bestial wrath") == nil or 30<5) then
    if IsCastableAtEnemyTarget("bag of tricks", 0) then
      WowCyborg_CURRENTATTACK = "bag of tricks";
      return SetSpellRequest(bag_of_tricks);
    end
  end
  
  -- chimaera shot
  if (true) then
    if IsCastableAtEnemyTarget("chimaera shot", 0) then
      WowCyborg_CURRENTATTACK = "chimaera shot";
      return SetSpellRequest(chimaera_shot);
    end
  end
  
  -- dire beast
  if (true) then
    if IsCastableAtEnemyTarget("dire beast", 0) then
      WowCyborg_CURRENTATTACK = "dire beast";
      return SetSpellRequest(dire_beast);
    end
  end
  
  -- barbed shot
  if (TalentEnabled("one with the pack") and GetSpellCharges("barbed shot")>1.5 or GetSpellCharges("barbed shot")>1.8 or GetCooldown("aspect of the wild")<GetBuffTimeLeft("player", "frenzy")-GetCurrentSpellGCD("barbed shot") and true or 30<9) then
    if IsCastableAtEnemyTarget("barbed shot", 0) then
      WowCyborg_CURRENTATTACK = "barbed shot";
      return SetSpellRequest(barbed_shot);
    end
  end
  
  -- purifying blast
  if (FindBuff("player", "bestial wrath") == nil or 30<8) then
    if IsCastableAtEnemyTarget("purifying blast", 0) then
      WowCyborg_CURRENTATTACK = "purifying blast";
      return SetSpellRequest(purifying_blast);
    end
  end
  
  -- barrage
  if (true) then
    if IsCastableAtEnemyTarget("barrage", 0) then
      WowCyborg_CURRENTATTACK = "barrage";
      return SetSpellRequest(barrage);
    end
  end
  
  -- cobra shot
  if ((UnitPower("player")-GetCurrentCost("cobra shot")+GetPowerRegen()*(GetCooldown("kill command")-1)>GetCurrentCost("kill command") or GetCooldown("kill command")>1+GetCurrentSpellGCD("cobra shot") and GetCooldown("bestial wrath")>GetTimeToMax() or FindBuff("player", "memory of lucid dreams") ~= nil) and GetCooldown("kill command")>1 or 30<3) then
    if IsCastableAtEnemyTarget("cobra shot", 0) then
      WowCyborg_CURRENTATTACK = "cobra shot";
      return SetSpellRequest(cobra_shot);
    end
  end
  
  -- spitting cobra
  if (true) then
    if IsCastableAtEnemyTarget("spitting cobra", 0) then
      WowCyborg_CURRENTATTACK = "spitting cobra";
      return SetSpellRequest(spitting_cobra);
    end
  end
  
  -- barbed shot
  if (GetBuffTimeLeft("player", "frenzy")-GetCurrentSpellGCD("barbed shot")>GetFullRechargeTime("barbed shot")) then
    if IsCastableAtEnemyTarget("barbed shot", 0) then
      WowCyborg_CURRENTATTACK = "barbed shot";
      return SetSpellRequest(barbed_shot);
    end
  end
  
end

local function cleave()
  -- barbed shot
  if (GetDebuffTimeLeft("target", "barbed shot")) then
    if IsCastableAtEnemyTarget("barbed shot", 0) then
      WowCyborg_CURRENTATTACK = "barbed shot";
      return SetSpellRequest(barbed_shot);
    end
  end
  
  -- multi-shot
  if (GetGCDMax()-GetBuffTimeLeft("pet", "beast cleave")>0.25) then
    if IsCastableAtEnemyTarget("multi-shot", 0) then
      WowCyborg_CURRENTATTACK = "multi-shot";
      return SetSpellRequest(multishot);
    end
  end
  
  -- barbed shot
  if (GetDebuffTimeLeft("target", "barbed shot")) then
    if IsCastableAtEnemyTarget("barbed shot", 0) then
      WowCyborg_CURRENTATTACK = "barbed shot";
      return SetSpellRequest(barbed_shot);
    end
  end
  
  -- aspect of the wild
  if (true) then
    if IsCastableAtEnemyTarget("aspect of the wild", 0) then
      WowCyborg_CURRENTATTACK = "aspect of the wild";
      return SetSpellRequest(aspect_of_the_wild);
    end
  end
  
  -- stampede
  if (FindBuff("player", "aspect of the wild") ~= nil and FindBuff("player", "bestial wrath") ~= nil or 30<15) then
    if IsCastableAtEnemyTarget("stampede", 0) then
      WowCyborg_CURRENTATTACK = "stampede";
      return SetSpellRequest(stampede);
    end
  end
  
  -- bestial wrath
  if (GetCooldown("aspect of the wild")>20 or TalentEnabled("one with the pack") or 30<15) then
    if IsCastableAtEnemyTarget("bestial wrath", 0) then
      WowCyborg_CURRENTATTACK = "bestial wrath";
      return SetSpellRequest(bestial_wrath);
    end
  end
  
  -- chimaera shot
  if (true) then
    if IsCastableAtEnemyTarget("chimaera shot", 0) then
      WowCyborg_CURRENTATTACK = "chimaera shot";
      return SetSpellRequest(chimaera_shot);
    end
  end
  
  -- a murder of crows
  if (true) then
    if IsCastableAtEnemyTarget("a murder of crows", 0) then
      WowCyborg_CURRENTATTACK = "a murder of crows";
      return SetSpellRequest(a_murder_of_crows);
    end
  end
  
  -- barrage
  if (true) then
    if IsCastableAtEnemyTarget("barrage", 0) then
      WowCyborg_CURRENTATTACK = "barrage";
      return SetSpellRequest(barrage);
    end
  end
  
  -- kill command
  if (GetActiveEnemies()<4 or  not true) then
    if IsCastableAtEnemyTarget("kill command", 0) then
      WowCyborg_CURRENTATTACK = "kill command";
      return SetSpellRequest(kill_command);
    end
  end
  
  -- dire beast
  if (true) then
    if IsCastableAtEnemyTarget("dire beast", 0) then
      WowCyborg_CURRENTATTACK = "dire beast";
      return SetSpellRequest(dire_beast);
    end
  end
  
  -- barbed shot
  if (GetDebuffTimeLeft("target", "barbed shot")) then
    if IsCastableAtEnemyTarget("barbed shot", 0) then
      WowCyborg_CURRENTATTACK = "barbed shot";
      return SetSpellRequest(barbed_shot);
    end
  end
  
  -- focused azerite beam
  if (true) then
    if IsCastableAtEnemyTarget("focused azerite beam", 0) then
      WowCyborg_CURRENTATTACK = "focused azerite beam";
      return SetSpellRequest(focused_azerite_beam);
    end
  end
  
  -- purifying blast
  if (true) then
    if IsCastableAtEnemyTarget("purifying blast", 0) then
      WowCyborg_CURRENTATTACK = "purifying blast";
      return SetSpellRequest(purifying_blast);
    end
  end
  
  -- concentrated flame
  if (true) then
    if IsCastableAtEnemyTarget("concentrated flame", 0) then
      WowCyborg_CURRENTATTACK = "concentrated flame";
      return SetSpellRequest(concentrated_flame);
    end
  end
  
  -- blood of the enemy
  if (true) then
    if IsCastableAtEnemyTarget("blood of the enemy", 0) then
      WowCyborg_CURRENTATTACK = "blood of the enemy";
      return SetSpellRequest(blood_of_the_enemy);
    end
  end
  
  -- the unbound force
  if (FindBuff("player", "reckless force") ~= nil or GetBuffStacks("reckless force counter")<10) then
    if IsCastableAtEnemyTarget("the unbound force", 0) then
      WowCyborg_CURRENTATTACK = "the unbound force";
      return SetSpellRequest(the_unbound_force);
    end
  end
  
  -- multi-shot
  if (true and GetActiveEnemies()>2) then
    if IsCastableAtEnemyTarget("multi-shot", 0) then
      WowCyborg_CURRENTATTACK = "multi-shot";
      return SetSpellRequest(multishot);
    end
  end
  
  -- cobra shot
  if (GetCooldown("kill command")>GetTimeToMax() and (GetActiveEnemies()<3 or  not true)) then
    if IsCastableAtEnemyTarget("cobra shot", 0) then
      WowCyborg_CURRENTATTACK = "cobra shot";
      return SetSpellRequest(cobra_shot);
    end
  end
  
  -- spitting cobra
  if (true) then
    if IsCastableAtEnemyTarget("spitting cobra", 0) then
      WowCyborg_CURRENTATTACK = "spitting cobra";
      return SetSpellRequest(spitting_cobra);
    end
  end
  
end

function RenderSingleTargetRotation()
  if cds() then
    return
  end

  if st() then
    return
  end
  
  WowCyborg_CURRENTATTACK = "-"
  return SetSpellRequest(nil)
 end
 
 function RenderMultiTargetRotation()
  if cds() then
    return
  end

  if cleave() then
    return
  end
  
  WowCyborg_CURRENTATTACK = "-"
  return SetSpellRequest(nil)
 end
