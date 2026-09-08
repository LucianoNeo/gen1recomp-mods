-- Gen 2 trainer/person registry and map-scoped identity redirects.
-- The Crystal map tables reuse several broad sprite ids, so these redirects
-- stay isolated from the Gen 1 registry and only change resolved NPCs.
return function(ctx)
  local patchSprite = assert(ctx and ctx.patchSprite)

  return function()
    local sprites = {
      BEAUTY = "beauty", BIKER = "biker", BLACK_BELT = "blackbelt",
      BILL = "bill", BIRD_KEEPER = "bird_keeper_gen2",
      BLAINE = "blaine_gen2", BLUE = "blue_gen2", BROCK = "brock_gen2",
      BRUNO = "bruno_gen2", BUG_CATCHER = "bug_catcher_gen2",
      BUGSY = "bugsy_gen2", CAPTAIN = "captain", CAL = "cooltrainer_m",
      CHUCK = "chuck_gen2", CLAIR = "clair_gen2", CLERK = "clerk",
      COOLTRAINER_M = "cooltrainer_m", DAISY = "daisy", ELDER = "elder_gen2",
      ELM = "elm_gen2", ERIKA = "erika_gen2", FALKNER = "falkner_gen2",
      FISHING_GURU = "fishing_guru", GAMEBOY_KID = "gameboy_kid",
      GENTLEMAN = "gentleman", GRAMPS = "gramps", GRANNY = "granny",
      GYM_GUIDE = "gym_guide", HIKER = "hiker_gen2", JANINE = "janine_gen2",
      JASMINE = "jasmine_gen2", KAREN = "karen", KIMONO_GIRL = "kimono_girl",
      KOGA = "koga_gen2", KURT = "kurt_gen2", KURT_OUTSIDE = "kurt_gen2",
      LANCE = "lance", LASS = "lass_gen2", LINK_RECEPTIONIST = "link_receptionist",
      MISTY = "misty_gen2", MORTY = "morty_gen2", NURSE = "nurse",
      OAK = "oak_gen2", OFFICER = "officer",
      OLD_LINK_RECEPTIONIST = "link_receptionist", UNUSED_GUY = "gramps",
      PHARMACIST = "pharmacist_gen2", POKEFAN_M = "pokefan_m",
      PICNICKER = "picnicker",
      PRYCE = "pryce_gen2", RECEPTIONIST = "receptionist_gen2",
      RED = "red", REDS_MOM = "mom_johto", ROCKER = "rocker",
      ROCKET = "rocket_gen2", ROCKET_GIRL = "rocket_girl_gen2",
      SABRINA = "sabrina_gen2", SAGE = "sage", SAILOR = "sailor",
      SUPER_NERD = "super_nerd_gen2", SURGE = "surge_gen2",
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
      local replacement
      if (mapId == "OLIVINE_LIGHTHOUSE_3F" and index == 3)
          or (mapId == "OLIVINE_LIGHTHOUSE_5F" and index == 2)
          or (mapId == "ROUTE_13" and (index == 1 or index == 2))
          or (mapId == "ROUTE_14" and index == 2)
          or (mapId == "ROUTE_18" and (index == 1 or index == 2))
          or (mapId == "ROUTE_27" and index == 6)
          or (mapId == "ROUTE_32" and index == 9)
          or (mapId == "ROUTE_35" and index == 5)
          or (mapId == "ROUTE_38" and index == 3)
          or (mapId == "ROUTE_4" and index == 1)
          or (mapId == "ROUTE_44" and index == 5)
          or (mapId == "VIOLET_GYM" and (index == 2 or index == 3)) then
        replacement = "SPRITE_BIRD_KEEPER"
      elseif (mapId == "FAST_SHIP_CABINS_NNW_NNE_NE" and index == 4)
          or (mapId == "ROUTE_10_SOUTH" and index == 1)
          or (mapId == "ROUTE_13" and index == 4)
          or (mapId == "ROUTE_33" and index == 1)
          or (mapId == "ROUTE_42" and index == 2)
          or (mapId == "ROUTE_45"
              and (index == 1 or index == 2 or index == 3 or index == 4))
          or (mapId == "ROUTE_46" and index == 1)
          or (mapId == "ROUTE_9" and (index == 5 or index == 6))
          or (mapId == "UNION_CAVE_1F" and (index == 1 or index == 3))
          or (mapId == "UNION_CAVE_B1F" and (index == 1 or index == 2)) then
        replacement = "SPRITE_HIKER"
      elseif mapId == "TRAINER_HOUSE_B1F" and index == 2 then
        replacement = "SPRITE_CAL"
      elseif (mapId == "FAST_SHIP_CABINS_NNW_NNE_NE" and index == 7)
          or (mapId == "GOLDENROD_UNDERGROUND_SWITCH_ROOM_ENTRANCES"
              and (index == 1 or index == 2)) then
        replacement = "SPRITE_BURGLAR"
      elseif (mapId == "BATTLE_TOWER_1F" and index == 1)
          or (mapId == "BATTLE_TOWER_BATTLE_ROOM" and index == 2)
          or (mapId == "BATTLE_TOWER_ELEVATOR" and index == 1)
          or (mapId == "BATTLE_TOWER_HALLWAY" and index == 1) then
        replacement = "SPRITE_BATTLE_TOWER_RECEPTIONIST"
      -- Crystal gives Todd, Samuel and Ian the same native Youngster object
      -- id, and uses Lass for Gina.  That is correct for the two Youngsters,
      -- but it loses Todd's Camper and Gina's Picnicker identities once HGSS
      -- overworlds are active.  Keep this redirect local to Route 34 so
      -- Gen 1 and all unrelated Gen 2 maps retain their normal assignments.
      elseif mapId == "ROUTE_34" and index == 1 then
        replacement = "SPRITE_CAMPER"
      elseif mapId == "ROUTE_34" and index == 4 then
        replacement = "SPRITE_PICNICKER"
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
