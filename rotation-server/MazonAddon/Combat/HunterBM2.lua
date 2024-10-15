--[[
  Button    Spell
  1         Barbed shot
  2         Kill command
  3         Chimaera shot
  4         Murder of crows
  5         Beastial wrath
  6         Aspect of wild
  7         Cobra shot
  8         Multi shot
]]--

local barbed_shot = "1";
local kill_command = "2";
local bestial_wrath = "3";
local cobra_shot = "4";
local aspect_of_the_wild = "5";
local multishot = "6";
local focused_azerite_beam = "7";
local concentrated_flame = "8";

function GetCurrentGlobalCooldown()
  return 1.5 - (1.5 * (UnitSpellHaste("player") / 100))
end 

function RenderMultiTargetRotation()  
      
    -- barbed shot
    if (GetDebuffTimeLeft("target", "barbed shot")) then
      if IsCastableAtEnemyTarget("barbed shot", 0) then
        WowCyborg_CURRENTATTACK = "barbed shot";
        return SetSpellRequest(barbed_shot);
      end
    end
  
    -- multi-shot
    if (GetCurrentGlobalCooldown()-GetBuffTimeLeft("pet", "beast cleave")>0.25) then
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
  
    WowCyborg_CURRENTATTACK = "-";
    return SetSpellRequest(nil);
end

function RenderSingleTargetRotation(aoe)
  
    -- barbed shot
    if (FindBuff("pet", "frenzy") ~= nil and GetBuffTimeLeft("pet", "frenzy")<GetCurrentGlobalCooldown() or GetCooldown("bestial wrath") and (GetFullRechargeTime("barbed shot")<GetCurrentGlobalCooldown() or true and GetCooldown("aspect of the wild")<GetCurrentGlobalCooldown())) then
      if IsCastableAtEnemyTarget("barbed shot", 0) then
        WowCyborg_CURRENTATTACK = "barbed shot";
        return SetSpellRequest(barbed_shot);
      end
    end
  
    -- concentrated flame
    if (UnitPower("player")+GetPowerRegen()*GetCurrentGlobalCooldown()<UnitPowerMax("player") and FindBuff("player", "bestial wrath") == nil and ( not GetDebuffTimeLeft("target", "concentrated flame burn") and  not false) or GetFullRechargeTime("concentrated flame")<GetCurrentGlobalCooldown() or 30<5) then
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
    if (TalentEnabled("one with the pack") and GetBuffTimeLeft("player", "bestial wrath")<GetCurrentGlobalCooldown() or FindBuff("player", "bestial wrath") == nil and GetCooldown("aspect of the wild")>15 or 30<15+GetCurrentGlobalCooldown()) then
      if IsCastableAtEnemyTarget("bestial wrath", 0) then
        WowCyborg_CURRENTATTACK = "bestial wrath";
        return SetSpellRequest(bestial_wrath);
      end
    end
  
    -- barbed shot
    if (1>1 and GetBuffTimeLeft("player", "dance of death")<GetCurrentGlobalCooldown()) then
      if IsCastableAtEnemyTarget("barbed shot", 0) then
        WowCyborg_CURRENTATTACK = "barbed shot";
        return SetSpellRequest(barbed_shot);
      end
    end
  
    -- blood of the enemy
    if (GetBuffTimeLeft("player", "aspect of the wild")>10+GetCurrentGlobalCooldown() or 30<10+GetCurrentGlobalCooldown()) then
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
    if (TalentEnabled("one with the pack") and GetSpellCharges("barbed shot")>GetCurrentGlobalCooldown() or GetSpellCharges("barbed shot")>1.8 or GetCooldown("aspect of the wild")<GetBuffTimeLeft("player", "frenzy")-GetCurrentGlobalCooldown() and true or 30<9) then
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
    if ((UnitPower("player")-GetCurrentCost("cobra shot")+GetPowerRegen()*(GetCooldown("kill command")-1)>GetCurrentCost("kill command") or GetCooldown("kill command")>1+GetCurrentGlobalCooldown() and GetCooldown("bestial wrath")>GetTimeToMax() or FindBuff("player", "memory of lucid dreams") ~= nil) and GetCooldown("kill command")>1 or 30<3) then
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
    if (GetBuffTimeLeft("player", "frenzy")-GetCurrentGlobalCooldown()>GetFullRechargeTime("barbed shot")) then
      if IsCastableAtEnemyTarget("barbed shot", 0) then
        WowCyborg_CURRENTATTACK = "barbed shot";
        return SetSpellRequest(barbed_shot);
      end
    end
  
  WowCyborg_CURRENTATTACK = "-";
  return SetSpellRequest(nil);
end

print("Beastmastery hunter 3 rotation loaded");