return function(ctx)
  local mod = assert(ctx and ctx.mod)
  local selectedPlayerOption = assert(ctx.selectedOption)
  local gen2PlayerSelectSynced = ctx.isAutoSelection or function() return false end

  -- Gold/Silver/Crystal do not consume Yellow's `field.playerSprites` table.
  -- Their world resolves the active player through the Gen 2 sprite ids
  -- SPRITE_CHRIS(_BIKE) and, on Crystal, SPRITE_KRIS(_BIKE).  Register the
  -- same authored six-frame sheets in that id space instead of trying to
  -- redirect a Gen 1 field record.  This is the first real Gen 2 visual
  -- slice: it is deliberately limited to player/follower-safe assets until
  -- the Gen 2 map/NPC roster has been audited separately.
  local function gen2AssetPath(file)
    -- Keep every Gen-2 overworld charset in the canonical overrides/sprites
    -- directory. A slash-qualified path is accepted for clarity at call
    -- sites, while bare names resolve to the same directory; this avoids
    -- maintaining a second compact asset tree.
    return file:find("/", 1, true)
      and (file .. ".png")
      or ("overrides/sprites/" .. file .. ".png")
  end

  local gen2SpriteGeometryCache = {}
  local function gen2SpriteGeometry(file)
    local relative = gen2AssetPath(file)
    local cached = gen2SpriteGeometryCache[relative]
    if cached then return cached end

    -- Gen-2 can use either the compact six-frame 32x192 charset or the
    -- untouched HD six-frame 256x1536 sheet used by the Gen-1 overhaul.
    -- Read dimensions only; the source texture itself is never resampled.
    local frameWidth, frameHeight, frameCount = 32, 32, 6
    local ok, data = pcall(function()
      return love.image.newImageData(mod.assets:path(relative))
    end)
    if ok and data then
      local width, height = data:getDimensions()
      if width >= 32 and height >= 6 * 32 and height % 6 == 0 then
        frameWidth = width
        frameHeight = math.floor(height / 6)
      elseif width >= 32 and height >= 3 * 32 and height % 3 == 0 then
        -- A few Gen 2 NPC sheets (Mom, for example) contain only the
        -- three standing facings. Battle Art Voxel still uses the six-frame walker
        -- contract, so advertise the real count and avoid sampling blank
        -- rows as if they were animation frames.
        frameWidth = width
        frameHeight = math.floor(height / 3)
        frameCount = 3
      elseif width >= 1 and height >= 1 then
        -- Static Gen-2 map objects (for example the starter Poké Balls in
        -- Elm's Lab) are single-frame images.  Keep the complete source
        -- canvas as one frame instead of advertising the six-frame walker
        -- contract, which would make the renderer sample outside the image.
        frameWidth = width
        frameHeight = height
        frameCount = 1
      end
      if data.release then data:release() end
    end

    -- The logical Gen-2 actor remains 32px tall.  A 256px authored frame is
    -- therefore presented at 1/8 scale, while a 32px frame stays at 1.0x.
    -- This preserves the full-quality source and keeps both sheet formats
    -- aligned to the same map footprint.
    local displayScale = 32 / frameWidth
    cached = {
      frameWidth = frameWidth,
      frameHeight = frameHeight,
      frameCount = frameCount,
      anchorX = frameWidth / 2,
      anchorY = frameHeight,
      displayScale = displayScale,
    }
    gen2SpriteGeometryCache[relative] = cached
    return cached
  end

  local function patchGen2Sprite(shortId, file, extra)
    -- Gen-2 sheets use the canonical overrides/sprites directory. Accept an
    -- explicit slash-qualified asset path for readability while retaining
    -- the same source for players and NPCs.
    local relative = gen2AssetPath(file)
    local geometry = gen2SpriteGeometry(file)
    -- Gen-2's stock renderer draws the source quad through the engine's
    -- default (linear) sampler.  That is fine for the native 16px sheets,
    -- but it softens an authored 256x1536 sheet when the draw-time transform
    -- reduces each frame to its logical map footprint.  Keep the source at
    -- full resolution and force nearest filtering on the runtime texture.
    local displayMultiplier = 1
    if type(extra) == "table" then
      displayMultiplier = tonumber(extra.hgssGen2ScaleMultiplier) or 1
    end
    local payload = {
      -- Gen 2 flat rendering reads the authored HGSS sheet directly. Do not
      -- advertise a voxel-layout proxy here: without a voxel provider that
      -- proxy is also what the ordinary renderer sees and it collapses the
      -- character into a few pixels.
      image = mod.assets:path(relative),
      hgssNativeImage = mod.assets:path(relative),
      frames = geometry.frameCount or 6,
      frameWidth = geometry.frameWidth,
      frameHeight = geometry.frameHeight,
      anchorX = geometry.anchorX,
      anchorY = geometry.anchorY,
      -- Keep the authored frame at its original logical presentation size;
      -- the optional multiplier is applied only at draw time. No source
      -- pixels are changed, and the 256px sheet remains a 256px sheet.
      hgssGen2DisplayScale = geometry.displayScale * displayMultiplier,
      hgssGen2NearestFilter = true,
      -- Battle Art Voxel uses these explicit dimensions for the physical
      -- billboard footprint. Keep the authored source dimensions above for
      -- UV/frame decoding, but constrain Gen2 actors to the native 32px
      -- character card used by the Gen2 Pokémon sprites, so a 256px HGSS
      -- sheet cannot become a giant world card while still matching mons.
      hgssVoxelWidth = 32,
      hgssVoxelHeight = 32,
      hgssBaseVoxelWidth = 32,
      hgssBaseVoxelHeight = 32,
      walker = true,
      spriteType = "WALKING_SPRITE",
      trueColor = true,
    }
    for key, value in pairs(extra or {}) do
      if key ~= "hgssGen2ScaleMultiplier" then payload[key] = value end
    end
    mod.content.sprites:patch("SPRITE_" .. shortId, payload)
  end

  local function gen2PlayerFiles(selected)
    selected = tostring(selected or "red"):lower()
    -- Gen 2 exposes one active male slot (`CHRIS`) and one female slot
    -- (`KRIS`), but PLAYER SELECT is shared by all supported games. Resolve
    -- that choice to its matching HGSS overworld pair instead of silently
    -- showing Ethan whenever Crystal is running.  The source dimensions are
    -- detected by gen2SpriteGeometry, so compact 32x192 sheets and 256x1536
    -- sheets keep their authored pixels and movement frames alike.
    local files = {
      red = { "overrides/sprites/red", "red_bike" },
      ash = { "overrides/sprites/ash", "ash_bike" },
      ethan = { "overrides/sprites/ethan", "ethan_bike" },
      lyra = { "overrides/sprites/lyra", "lyra_bike" },
      kris = { "overrides/sprites/kris", "kris_bike" },
      kris_v2 = { "overrides/sprites/kris_v2", "kris_v2_bike" },
      leaf = { "overrides/sprites/leaf", "leaf_bike" },
      brendan = { "overrides/sprites/brendan", "brendan_bike" },
    }
    local pair = files[selected] or files.red
    return pair[1], pair[2]
  end

  local function gen2SaveGender(game)
    local value = game and game.save and game.save.player
      and game.save.player.gender
    value = tostring(value or "male"):lower()
    return (value == "female" or value == "girl") and "female" or "male"
  end

  -- Keep the shared PLAYER SELECT menu useful for Gen 2 custom protagonists.
  -- The intro synchronization latch marks the automatic Ethan/Lyra choice;
  -- once the user changes the row, every value (including RED) is explicit.
  local function gen2PlayerSelection(game)
    local selected = tostring(selectedPlayerOption() or "red"):lower()
    -- An intro-synchronized Ethan/Lyra still follows the Boy/Girl answer,
    -- but that latch must never override a different concrete menu choice.
    -- Some Mod API builds persist the new option before emitting its event,
    -- so correctness cannot depend on the event clearing the latch first.
    if gen2PlayerSelectSynced() and selected ==
       (gen2SaveGender(game) == "female" and "lyra" or "ethan") then
      return selected, true
    end
    return selected, false
  end

  gen2SpriteGeometryCache.fishingSpriteId = function(selected, stage)
    selected = tostring(selected or "ethan"):lower()
    stage = math.max(0, math.min(3, math.floor(tonumber(stage) or 0)))
    return "SPRITE_HGSS_FISH_" .. selected:upper() .. "_" .. stage
  end

  gen2SpriteGeometryCache.patchFishingSprites = function()
    -- Fishing is a distinct four-pose HGSS action, not a walking frame. Keep
    -- four ordinary six-facing records so the 2D renderer and Battle Art
    -- Voxel consume the exact same active definition. The repeated walk rows
    -- are intentional: World.fishing, rather than the step clock, advances
    -- the cast animation.
    local geometry = {
      -- These action sheets include the rod and were authored on wider
      -- canvases than the walk cards.  Their logical presentation must still
      -- match the 32px Gen-2 player footprint; using the source dimensions as
      -- the voxel card made Kris/Red appear roughly three times too large.
      red = { scale = 1 / 3, anchorX = 48, anchorY = 48,
        voxelW = 32, voxelH = 27 },
      ash = { scale = 2 / 3, anchorX = 24, anchorY = 34,
        voxelW = 32, voxelH = 32 },
      -- The Kris cast poses have a smaller occupied body inside their 96x80
      -- canvas than the 256x256 walking cards.  Half-scale preserves the
      -- source aspect ratio and matches the visible walk height; scaling the
      -- full canvas to 32px made both Kris variants visibly undersized.
      kris = { scale = 1 / 2, anchorX = 48, anchorY = 48,
        voxelW = 48, voxelH = 40 },
      kris_v2 = { scale = 1 / 2, anchorX = 48, anchorY = 48,
        voxelW = 48, voxelH = 40 },
      leaf = { scale = 4 / 5, anchorX = 20, anchorY = 36,
        voxelW = 32, voxelH = 32 },
      brendan = { scale = 4 / 5, anchorX = 20, anchorY = 36,
        voxelW = 32, voxelH = 32 },
    }
    for _, selected in ipairs({
      "red", "ash", "ethan", "lyra", "kris", "kris_v2", "leaf", "brendan",
    }) do
      for stage = 0, 3 do
        local extra = { walker = false }
        local custom = geometry[selected]
        if custom then
          extra.hgssGen2DisplayScale = custom.scale
          extra.anchorX = custom.anchorX
          extra.anchorY = custom.anchorY
          extra.hgssVoxelWidth = custom.voxelW
          extra.hgssVoxelHeight = custom.voxelH
          extra.hgssBaseVoxelWidth = custom.voxelW
          extra.hgssBaseVoxelHeight = custom.voxelH
        end
        patchGen2Sprite("HGSS_FISH_" .. selected:upper() .. "_" .. stage,
          selected .. "_fish_" .. stage, extra)
      end
    end
  end

  gen2SpriteGeometryCache.patchFishingState = function()
    local okWorld, World = pcall(require, "src.world.gen2.World")
    local okPlayer, Player = pcall(require, "src.world.gen2.Player")
    if not okWorld or type(World) ~= "table"
        or type(World.beginFishing) ~= "function"
        or type(World.updateFishing) ~= "function"
        or World.__hgssPlayerFishing then
      return
    end

    local originalBeginFishing = World.beginFishing
    local originalUpdateFishing = World.updateFishing
    local function restoreFishingSprite(world)
      local player = world and world.player
      local base = world and world.__hgssFishingBaseDef
      if player then player.__hgssFishingDef = nil end
      -- The vanilla callback clears these flags at the moment the result box
      -- closes.  Keep the cleanup here as well: after that callback
      -- `World.fishing` is already nil, so the normal updateFishing seam is
      -- no longer called on subsequent frames.
      if player then
        player.fishing = nil
        player.fishingState = nil
      end
      if player and base and type(player.setSprite) == "function" then
        pcall(function() player:setSprite(base) end)
      end
      if player and world and world.__hgssFishingBaseSheet ~= nil then
        player.fishSheet = world.__hgssFishingBaseSheet
      end
      if world then
        world.__hgssFishingBaseDef = nil
        world.__hgssFishingBaseSheet = nil
        world.__hgssFishingStage = nil
        world.__hgssFishingStartTimer = nil
        world.__hgssFishingActive = nil
      end
    end
    local function applyFishingSprite(world, stage)
      local player = world and world.player
      local sprites = world and (world.sprites
        or (world.game and world.game.data
          and (world.game.data.gen2Sprites or world.game.data.sprites)))
      if not player or type(sprites) ~= "table" then return end
      local selected = gen2PlayerSelection(world.game)
      local def = sprites[gen2SpriteGeometryCache.fishingSpriteId(selected, stage)]
      if not def then return end
      if not world.__hgssFishingBaseDef then
        world.__hgssFishingBaseDef = player.spriteDef
          or (player.sprite and player.sprite.def)
        world.__hgssFishingBaseSheet = player.fishSheet
      end
      player.__hgssFishingDef = def
      world.__hgssFishingActive = true
      if world.__hgssFishingStage ~= stage
          or not player.sprite or player.sprite.def ~= def then
        pcall(function() player:setSprite(def) end)
        world.__hgssFishingStage = stage
      end
      -- Gen 2's native fishing renderer replaces the lower half of the
      -- standing 16px charset and draws a separate ROM rod tile. Our HGSS
      -- action sheets already contain the complete pose and rod, so letting
      -- that path run hides the authored frame and produces stray pixels.
      player.fishSheet = nil
      player.__hgssFishingDef = def
    end

    -- World state transitions may refresh SPRITE_CHRIS between updateFishing
    -- and the render pass. Reassert the complete HGSS fishing sheet at the
    -- final player draw seam, after those transitions but before either the
    -- flat renderer or a voxel pipeline samples the sprite.
    if okPlayer and type(Player) == "table" and type(Player.draw) == "function"
        and not Player.__hgssFishingDraw then
      local originalSetSprite = Player.setSprite
      Player.setSprite = function(self, def)
        return originalSetSprite(self, self.__hgssFishingDef or def)
      end
      local originalPlayerDraw = Player.draw
      Player.draw = function(self, ...)
        local def = self.__hgssFishingDef
        if def and (not self.sprite or self.sprite.def ~= def) then
          pcall(function() self:setSprite(def) end)
        end
        if def then self.fishSheet = nil end
        return originalPlayerDraw(self, ...)
      end
      Player.__hgssFishingDraw = true
    end

    World.beginFishing = function(self, outcome, wild)
      restoreFishingSprite(self)
      local result = originalBeginFishing(self, outcome, wild)
      local st = self.fishing
      self.__hgssFishingStartTimer = st and math.max(1,
        tonumber(st.timer) or 1)
      applyFishingSprite(self, 0)
      return result
    end
    World.updateFishing = function(self, ...)
      local hadFishing = self.fishing ~= nil
      local result = originalUpdateFishing(self, ...)
      local st = self.fishing
      if not st then
        if hadFishing or self.__hgssFishingBaseDef then
          restoreFishingSprite(self)
        end
        return result
      end
      local stage = 3
      if st.phase == "cast" then
        local total = math.max(1, tonumber(self.__hgssFishingStartTimer)
          or tonumber(st.timer) or 1)
        local elapsed = math.max(0, total - (tonumber(st.timer) or 0))
        stage = math.max(0, math.min(3,
          math.floor(elapsed * 4 / total)))
      end
      applyFishingSprite(self, stage)
      return result
    end

    -- World:stepBody only calls updateFishing while `self.fishing` is truthy.
    -- The result textbox callback clears that field before the next frame, so
    -- waiting for another updateFishing call leaves the HGSS action sheet
    -- latched on the player.  Reconcile once at the end of every logic step;
    -- this also covers a battle result and a no-bite result uniformly.
    if type(World.stepBody) == "function" and not World.__hgssFishingStepRestore then
      local originalStepBody = World.stepBody
      World.stepBody = function(self, ...)
        local result = originalStepBody(self, ...)
        if not self.fishing and (self.__hgssFishingActive
            or self.__hgssFishingBaseDef
            or (self.player and self.player.__hgssFishingDef)) then
          restoreFishingSprite(self)
        end
        return result
      end
      World.__hgssFishingStepRestore = true
    end
    World.__hgssPlayerFishing = true
  end

  local function patchGen2PlayerSprites()
    local footFile, bikeFile = gen2PlayerFiles(gen2PlayerSelection())
    -- The Gen-2 world uses the Chris ids for the active player in all three
    -- games.  Crystal also exposes Kris, which stays on the HGSS Lyra sheet
    -- for scripts/NPC code that explicitly requests the female slot.
    -- Keep the native Gen-2 footprint at 1.0x.  The shared SPRITE SIZE
    -- option is applied at draw time, including through Battle Art Voxel.
    -- Keep the active player's physical Voxel card at the native 16px cell;
    -- the 2D presentation and all Pokémon/NPC slots remain unchanged.
    local playerVoxelWidth = 32
    local playerVoxelHeight = 32
    local playerVoxelSize = {
      hgssVoxelWidth = playerVoxelWidth,
      hgssVoxelHeight = playerVoxelHeight,
      hgssBaseVoxelWidth = playerVoxelWidth,
      hgssBaseVoxelHeight = playerVoxelHeight,
    }
    patchGen2Sprite("CHRIS", footFile, {
      hgssGen2ScaleMultiplier = 1.0,
      hgssVoxelWidth = playerVoxelWidth,
      hgssVoxelHeight = playerVoxelHeight,
      hgssBaseVoxelWidth = playerVoxelWidth,
      hgssBaseVoxelHeight = playerVoxelHeight,
    })
    patchGen2Sprite("CHRIS_BIKE", bikeFile, playerVoxelSize)
    patchGen2Sprite("KRIS", "overrides/sprites/lyra",
      {
        hgssGen2ScaleMultiplier = 1.0,
        hgssVoxelWidth = playerVoxelWidth,
        hgssVoxelHeight = playerVoxelHeight,
        hgssBaseVoxelWidth = playerVoxelWidth,
        hgssBaseVoxelHeight = playerVoxelHeight,
      })
    patchGen2Sprite("KRIS_BIKE", "lyra_bike", playerVoxelSize)
    -- Gen 2's surf state uses these ids.  The Pikachu ride remains an
    -- explicit opt-in asset; the engine still decides when the state is
    -- entered, so ordinary Surf keeps its native behavior.
    patchGen2Sprite("SURFING_PIKACHU", "surfing_pikachu")
    -- Crystal's ordinary mounted state and the Friday Union Cave encounter
    -- both resolve SPRITE_SURF. Use the dedicated HGSS swimming Lapras atlas
    -- (including its waterline animation) instead of the native GSC sheet.
    patchGen2Sprite("SURF", "assets/gen2/pokemon-overworld/131-surf", {
      hgssGen2ScaleMultiplier = 1.0,
      hgssVoxelWidth = 32,
      hgssVoxelHeight = 32,
      hgssBaseVoxelWidth = 32,
      hgssBaseVoxelHeight = 32,
    })
    -- Crystal resolves the map's Fisherman-tagged object through
    -- SPRITE_FISHER. Keep that role on the dedicated Fisher charset; Fatman
    -- is a separate trainer and must never leak into the fishing spot.
    patchGen2Sprite("FISHER", "overrides/sprites/fisher",
      { hgssGen2ScaleMultiplier = 1.0 })
    -- The city woman in the Gen-2 maps is tagged SPRITE_TEACHER.  Use the
    -- supplied HGSS Silph worker female charset for that role; keep the
    -- compact six-frame sheet intact and apply the shared draw-time
    -- footprint as the other Gen-2 overworld characters.
    patchGen2Sprite("TEACHER", "overrides/sprites/silph_worker_f",
      { hgssGen2ScaleMultiplier = 1.0 })
    -- The player's mother is a native Gen-2 actor in PLAYERS_HOUSE_1F. Use
    -- the authored HGSS Mom charset while preserving the map's interaction
    -- script, time-of-day variants and movement behavior.
    patchGen2Sprite("MOM", "overrides/sprites/mom_johto",
      { hgssGen2ScaleMultiplier = 1.0 })
    -- Crystal's second actor in the player's house is the native Pokéfan
    -- female slot.  Use the HGSS Pokéfan F charset, keeping the original
    -- object id, position and interaction script intact.
    patchGen2Sprite("POKEFAN_F", "overrides/sprites/pokefan_f",
      { hgssGen2ScaleMultiplier = 1.0 })
    -- Additional Crystal town NPC roles with verified HGSS equivalents.
    -- Keep each role distinct: do not substitute Officer Jenny for the
    -- male police officer, or Blue for Silver, when those assets are absent.
    patchGen2Sprite("SCIENTIST", "scientist_gen2",
      { hgssGen2ScaleMultiplier = 1.0 })
    patchGen2Sprite("COOLTRAINER_F", "overrides/sprites/cooltrainer_f",
      { hgssGen2ScaleMultiplier = 1.0 })
    -- Crystal's rival is Silver; use the verified HGSS Silver charset.
    patchGen2Sprite("RIVAL", "overrides/sprites/silver",
      { hgssGen2ScaleMultiplier = 1.0 })
    gen2SpriteGeometryCache.patchFishingSprites()
    gen2SpriteGeometryCache.patchFishingState()
  end



  return {
    assetPath = gen2AssetPath,
    geometry = gen2SpriteGeometry,
    patchSprite = patchGen2Sprite,
    playerFiles = gen2PlayerFiles,
    saveGender = gen2SaveGender,
    selection = gen2PlayerSelection,
    patchPlayerSprites = patchGen2PlayerSprites,
  }
end

