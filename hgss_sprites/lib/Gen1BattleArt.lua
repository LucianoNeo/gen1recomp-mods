-- Keep the Gen1/Battle Art trainer bridge outside the entry chunk.  The
-- g1recomp mod sandbox limits one entry function to 200 locals.
return function(mod, isGen2, selectedTrainerImage)
  local Bridge = {}

  function Bridge.reapply(battle)
    if isGen2() or not battle or not battle.showEnemyTrainer then return end
    local trainer = battle.trainer
    local id = battle.oppClass
      or (trainer and (trainer.id or trainer.name or trainer.class))
    local image = selectedTrainerImage(id, battle.partyIndex)
    if image then
      battle.trainerPic = image
      battle.__hgssTrainerArtImage = image
    end
  end

  function Bridge.install()
    if isGen2() or type(mod.find) ~= "function" then return end
    local okFind, provider = pcall(function()
      return mod:find("BATTLE_ART_VOXEL_FORK")
    end)
    local lib = okFind and provider and provider.exports
      and provider.exports.lib
    if not (lib and type(lib.require) == "function") then return end
    local okBattleArt, BattleArt = pcall(lib.require, "BattleArt")
    if not (okBattleArt and type(BattleArt) == "table"
            and type(BattleArt.applyTrainers) == "function") then
      return
    end
    if BattleArt.__hgssGen1TrainerBridge then return end
    local oldApplyTrainers = BattleArt.applyTrainers
    BattleArt.applyTrainers = function(battle, ...)
      local result = oldApplyTrainers(battle, ...)
      Bridge.reapply(battle)
      return result
    end
    BattleArt.__hgssGen1TrainerBridge = true
  end

  return Bridge
end
