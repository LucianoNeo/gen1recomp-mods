-- Gen 2 trainer/person registry and map-scoped identity redirects.
-- The Crystal map tables reuse several broad sprite ids, so these redirects
-- stay isolated from the Gen 1 registry and only change resolved NPCs.
--
-- This table is the result of an audit of every Crystal
-- `OBJECTTYPE_TRAINER` row (333 objects across all maps).  Crystal reuses a
-- small set of object sprite slots for different trainer classes; keeping
-- the correction keyed by map/object index preserves the ROM's scripts,
-- palettes and movement while preventing one class from leaking into
-- another on the HGSS Gen-2 path.
local GEN2_TRAINER_REDIRECTS = {
  CELADON_GYM = { [3] = "SPRITE_PICNICKER", },
  ECRUTEAK_GYM = {
    [4] = "SPRITE_MEDIUM", [5] = "SPRITE_MEDIUM",
  },
  FAST_SHIP_B1F = {
    [4] = "SPRITE_PICNICKER", [5] = "SPRITE_JUGGLER",
    [11] = "SPRITE_SCHOOLBOY", [12] = "SPRITE_SCHOOLBOY",
  },
  FAST_SHIP_CABINS_NNW_NNE_NE = {
    [3] = "SPRITE_POKEMANIAC", [4] = "SPRITE_HIKER",
    [7] = "SPRITE_BURGLAR",
  },
  FAST_SHIP_CABINS_SE_SSE_CAPTAINS_CABIN = {
    [8] = "SPRITE_PSYCHIC",
  },
  FAST_SHIP_CABINS_SW_SSW_NW = {
    [1] = "SPRITE_FIREBREATHER", [4] = "SPRITE_GUITARIST",
  },
  GOLDENROD_UNDERGROUND = {
    [3] = "SPRITE_POKEMANIAC", [4] = "SPRITE_POKEMANIAC",
  },
  GOLDENROD_UNDERGROUND_SWITCH_ROOM_ENTRANCES = {
    [1] = "SPRITE_BURGLAR", [2] = "SPRITE_BURGLAR",
  },
  ILEX_FOREST = { [8] = "SPRITE_BUG_CATCHER", },
  MAHOGANY_GYM = {
    [2] = "SPRITE_SKIER", [3] = "SPRITE_BOARDER",
    [4] = "SPRITE_SKIER", [5] = "SPRITE_BOARDER",
    [6] = "SPRITE_BOARDER",
  },
  MOUNT_MORTAR_1F_INSIDE = { [7] = "SPRITE_POKEMANIAC", },
  NATIONAL_PARK = { [8] = "SPRITE_SCHOOLBOY", },
  OLIVINE_LIGHTHOUSE_3F = { [3] = "SPRITE_BIRD_KEEPER", },
  OLIVINE_LIGHTHOUSE_5F = { [2] = "SPRITE_BIRD_KEEPER", },
  PEWTER_GYM = { [2] = "SPRITE_CAMPER", },
  RADIO_TOWER_4F = { [5] = "SPRITE_EXECUTIVE_M", },
  RADIO_TOWER_5F = { [3] = "SPRITE_EXECUTIVE_F", },
  ROUTE_1 = { [1] = "SPRITE_SCHOOLBOY", },
  ROUTE_10_SOUTH = { [1] = "SPRITE_HIKER", },
  ROUTE_11 = {
    [3] = "SPRITE_PSYCHIC", [4] = "SPRITE_PSYCHIC",
  },
  ROUTE_13 = {
    [1] = "SPRITE_BIRD_KEEPER", [2] = "SPRITE_BIRD_KEEPER",
    [4] = "SPRITE_HIKER",
  },
  ROUTE_14 = { [2] = "SPRITE_BIRD_KEEPER", },
  ROUTE_15 = {
    [1] = "SPRITE_SCHOOLBOY", [2] = "SPRITE_SCHOOLBOY",
    [3] = "SPRITE_SCHOOLBOY", [4] = "SPRITE_SCHOOLBOY",
  },
  ROUTE_18 = {
    [1] = "SPRITE_BIRD_KEEPER", [2] = "SPRITE_BIRD_KEEPER",
  },
  ROUTE_25 = {
    [3] = "SPRITE_SCHOOLBOY", [5] = "SPRITE_SCHOOLBOY",
    [7] = "SPRITE_CAMPER",
  },
  ROUTE_26 = { [5] = "SPRITE_PSYCHIC", },
  ROUTE_27 = {
    [5] = "SPRITE_PSYCHIC", [6] = "SPRITE_BIRD_KEEPER",
  },
  ROUTE_3 = {
    [1] = "SPRITE_FIREBREATHER", [4] = "SPRITE_FIREBREATHER",
  },
  ROUTE_32 = {
    [6] = "SPRITE_CAMPER", [7] = "SPRITE_PICNICKER",
    [9] = "SPRITE_BIRD_KEEPER",
  },
  ROUTE_33 = { [1] = "SPRITE_HIKER", },
  ROUTE_34 = {
    [1] = "SPRITE_CAMPER", [4] = "SPRITE_PICNICKER",
  },
  ROUTE_35 = {
    [1] = "SPRITE_CAMPER", [2] = "SPRITE_CAMPER",
    [3] = "SPRITE_PICNICKER", [4] = "SPRITE_PICNICKER",
    [5] = "SPRITE_BIRD_KEEPER", [6] = "SPRITE_FIREBREATHER",
    [8] = "SPRITE_JUGGLER",
  },
  ROUTE_36 = {
    [1] = "SPRITE_PSYCHIC", [2] = "SPRITE_SCHOOLBOY",
  },
  ROUTE_37 = {
    [1] = "SPRITE_TWIN", [2] = "SPRITE_TWIN",
    [3] = "SPRITE_PSYCHIC",
  },
  ROUTE_38 = {
    [1] = "SPRITE_SCHOOLBOY", [3] = "SPRITE_BIRD_KEEPER",
  },
  ROUTE_39 = { [8] = "SPRITE_PSYCHIC", },
  ROUTE_4 = {
    [1] = "SPRITE_BIRD_KEEPER", [2] = "SPRITE_PICNICKER",
    [3] = "SPRITE_PICNICKER",
  },
  ROUTE_40 = {
    [1] = "SPRITE_SWIMMER_GUY", [2] = "SPRITE_SWIMMER_GUY",
  },
  ROUTE_41 = {
    [1] = "SPRITE_SWIMMER_GUY", [2] = "SPRITE_SWIMMER_GUY",
    [3] = "SPRITE_SWIMMER_GUY", [4] = "SPRITE_SWIMMER_GUY",
    [5] = "SPRITE_SWIMMER_GUY",
  },
  ROUTE_42 = {
    [2] = "SPRITE_HIKER", [3] = "SPRITE_POKEMANIAC",
  },
  ROUTE_43 = {
    [1] = "SPRITE_POKEMANIAC", [2] = "SPRITE_POKEMANIAC",
    [3] = "SPRITE_POKEMANIAC", [5] = "SPRITE_PICNICKER",
    [6] = "SPRITE_CAMPER",
  },
  ROUTE_44 = {
    [3] = "SPRITE_PSYCHIC", [4] = "SPRITE_POKEMANIAC",
    [5] = "SPRITE_BIRD_KEEPER",
  },
  ROUTE_45 = {
    [1] = "SPRITE_HIKER", [2] = "SPRITE_HIKER",
    [3] = "SPRITE_HIKER", [4] = "SPRITE_HIKER",
  },
  ROUTE_46 = {
    [1] = "SPRITE_HIKER", [2] = "SPRITE_CAMPER",
    [3] = "SPRITE_PICNICKER",
  },
  ROUTE_9 = {
    [1] = "SPRITE_CAMPER", [2] = "SPRITE_PICNICKER",
    [3] = "SPRITE_CAMPER", [4] = "SPRITE_PICNICKER",
    [5] = "SPRITE_HIKER", [6] = "SPRITE_HIKER",
  },
  RUINS_OF_ALPH_OUTSIDE = { [1] = "SPRITE_PSYCHIC", },
  SAFFRON_GYM = {
    [2] = "SPRITE_MEDIUM", [3] = "SPRITE_PSYCHIC",
    [4] = "SPRITE_MEDIUM", [5] = "SPRITE_PSYCHIC",
  },
  UNION_CAVE_1F = {
    [1] = "SPRITE_HIKER", [2] = "SPRITE_POKEMANIAC",
    [3] = "SPRITE_HIKER", [4] = "SPRITE_FIREBREATHER",
    [5] = "SPRITE_FIREBREATHER",
  },
  UNION_CAVE_B1F = {
    [1] = "SPRITE_HIKER", [2] = "SPRITE_HIKER",
    [3] = "SPRITE_POKEMANIAC", [4] = "SPRITE_POKEMANIAC",
  },
  UNION_CAVE_B2F = { [1] = "SPRITE_COOLTRAINER_M", },
  VERMILION_GYM = {
    [3] = "SPRITE_GUITARIST", [4] = "SPRITE_JUGGLER",
  },
  VIOLET_GYM = {
    [2] = "SPRITE_BIRD_KEEPER", [3] = "SPRITE_BIRD_KEEPER",
  },
}

return function(ctx)
  local patchSprite = assert(ctx and ctx.patchSprite)

  return function()
    local sprites = {
      BEAUTY = "beauty", BIKER = "biker", BLACK_BELT = "blackbelt",
      BILL = "bill", BIRD_KEEPER = "bird_keeper_gen2",
      BLAINE = "blaine_gen2", BLUE = "blue_gen2", BROCK = "brock_gen2",
      BRUNO = "bruno_gen2", BUG_CATCHER = "bug_catcher_gen2",
      BUGSY = "bugsy_gen2", CAPTAIN = "captain", CAL = "cooltrainer_m",
      BOARDER = "boarder", CAMPER = "camper",
      CHUCK = "chuck_gen2", CLAIR = "clair_gen2", CLERK = "clerk",
      COOLTRAINER_M = "cooltrainer_m", DAISY = "daisy", ELDER = "elder_gen2",
      ELM = "elm_gen2", ERIKA = "erika_gen2", FALKNER = "falkner_gen2",
      EXECUTIVE_F = "executive_f", EXECUTIVE_M = "executive_m",
      FISHING_GURU = "fishing_guru", GAMEBOY_KID = "gameboy_kid",
      FIREBREATHER = "firebreather", GUITARIST = "guitarist",
      GENTLEMAN = "gentleman", GRAMPS = "gramps", GRANNY = "granny",
      GYM_GUIDE = "gym_guide", HIKER = "hiker_gen2", JANINE = "janine_gen2",
      JUGGLER = "juggler",
      JASMINE = "jasmine_gen2", KAREN = "karen", KIMONO_GIRL = "kimono_girl",
      KOGA = "koga_gen2", KURT = "kurt_gen2", KURT_OUTSIDE = "kurt_gen2",
      LANCE = "lance", LASS = "lass_gen2", LINK_RECEPTIONIST = "link_receptionist",
      MISTY = "misty_gen2", MEDIUM = "medium", MORTY = "morty_gen2",
      NURSE = "nurse",
      OAK = "oak_gen2", OFFICER = "officer",
      OLD_LINK_RECEPTIONIST = "link_receptionist", UNUSED_GUY = "gramps",
      PHARMACIST = "pharmacist_gen2", POKEFAN_M = "pokefan_m",
      PICNICKER = "picnicker", POKEMANIAC = "pokemaniac",
      PRYCE = "pryce_gen2", RECEPTIONIST = "receptionist_gen2",
      RED = "red", REDS_MOM = "mom_johto", ROCKER = "rocker",
      ROCKET = "rocket_gen2", ROCKET_GIRL = "rocket_girl_gen2",
      SABRINA = "sabrina_gen2", SAGE = "sage", SAILOR = "sailor",
      SCHOOLBOY = "school_kid", SKIER = "skier",
      SUPER_NERD = "super_nerd_gen2", SURGE = "surge_gen2",
      PSYCHIC = "psychic",
      SWIMMER_GIRL = "swimmer_girl", SWIMMER_GUY = "swimmer_guy",
      TWIN = "twin", WHITNEY = "whitney_gen2", WILL = "will",
      YOUNGSTER = "youngster", STANDING_YOUNGSTER = "youngster",
    }
    for shortId, file in pairs(sprites) do
      patchSprite(shortId, file, { hgssGen2ScaleMultiplier = 1.0 })
    end

    local okWorld, World = pcall(require, "src.world.gen2.World")
    if not okWorld or type(World) ~= "table"
        or type(World.pooledNpc) ~= "function"
        or World.__hgssContextNpcSprites then
      return
    end

    patchSprite("BURGLAR", "burglar_gen2",
      { hgssGen2ScaleMultiplier = 1.0 })
    patchSprite("BATTLE_TOWER_RECEPTIONIST",
      "battle_tower_receptionist_gen2",
      { hgssGen2ScaleMultiplier = 1.0 })

    local originalPooledNpc = World.pooledNpc
    World.pooledNpc = function(self, mapId, obj)
      local index = type(obj) == "table" and tonumber(obj.index) or nil
      local byMap = GEN2_TRAINER_REDIRECTS[tostring(mapId)]
      local replacement = byMap and index and byMap[index]
      -- These are not trainer rows, but the Battle Tower receptionist and
      -- Trainer House Cal use the same pooled path. Keep their existing
      -- identity-specific redirects alongside the audited trainer table.
      if not replacement then
        if mapId == "TRAINER_HOUSE_B1F" and index == 2 then
          replacement = "SPRITE_CAL"
        elseif (mapId == "BATTLE_TOWER_1F" and index == 1)
            or (mapId == "BATTLE_TOWER_BATTLE_ROOM" and index == 2)
            or (mapId == "BATTLE_TOWER_ELEVATOR" and index == 1)
            or (mapId == "BATTLE_TOWER_HALLWAY" and index == 1) then
          replacement = "SPRITE_BATTLE_TOWER_RECEPTIONIST"
        end
      end
      if not replacement then
        return originalPooledNpc(self, mapId, obj)
      end

      local originalSprite = obj.sprite
      obj.sprite = replacement
      local ok, npc = pcall(originalPooledNpc, self, mapId, obj)
      obj.sprite = originalSprite
      if not ok then error(npc, 0) end
      return npc
    end
    World.__hgssContextNpcSprites = true
  end
end
