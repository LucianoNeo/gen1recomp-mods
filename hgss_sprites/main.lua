-- HGSS Visual Overhaul 2.0
--
-- The registries and hooks below are Mod API 2.  One deliberately narrow
-- engine-internals hook is also installed for overworld sheets: g1recomp's
-- public SpriteRenderer hard-codes 16x16 cells, while HGSS's authored cells
-- are 32x32.  Without this adapter the engine silently crops the DS art into
-- GBC-sized fragments.  The adapter only changes the quad size/anchor for
-- this mod's 32x192 sheets; every other sprite keeps the stock renderer.

local SPECIES = [[
BULBASAUR IVYSAUR VENUSAUR CHARMANDER CHARMELEON CHARIZARD
SQUIRTLE WARTORTLE BLASTOISE CATERPIE METAPOD BUTTERFREE WEEDLE KAKUNA
BEEDRILL PIDGEY PIDGEOTTO PIDGEOT RATTATA RATICATE SPEAROW FEAROW EKANS
ARBOK PIKACHU RAICHU SANDSHREW SANDSLASH NIDORAN_F NIDORINA NIDOQUEEN
NIDORAN_M NIDORINO NIDOKING CLEFAIRY CLEFABLE VULPIX NINETALES
JIGGLYPUFF WIGGLYTUFF ZUBAT GOLBAT ODDISH GLOOM VILEPLUME PARAS
PARASECT VENONAT VENOMOTH DIGLETT DUGTRIO MEOWTH PERSIAN PSYDUCK
GOLDUCK MANKEY PRIMEAPE GROWLITHE ARCANINE POLIWAG POLIWHIRL POLIWRATH
ABRA KADABRA ALAKAZAM MACHOP MACHOKE MACHAMP BELLSPROUT WEEPINBELL
VICTREEBEL TENTACOOL TENTACRUEL GEODUDE GRAVELER GOLEM PONYTA RAPIDASH
SLOWPOKE SLOWBRO MAGNEMITE MAGNETON FARFETCHD DODUO DODRIO SEEL DEWGONG
GRIMER MUK SHELLDER CLOYSTER GASTLY HAUNTER GENGAR ONIX DROWZEE HYPNO
KRABBY KINGLER VOLTORB ELECTRODE EXEGGCUTE EXEGGUTOR CUBONE MAROWAK
HITMONLEE HITMONCHAN LICKITUNG KOFFING WEEZING RHYHORN RHYDON CHANSEY
TANGELA KANGASKHAN HORSEA SEADRA GOLDEEN SEAKING STARYU STARMIE MR_MIME
SCYTHER JYNX ELECTABUZZ MAGMAR PINSIR TAUROS MAGIKARP GYARADOS LAPRAS
DITTO EEVEE VAPOREON JOLTEON FLAREON PORYGON OMANYTE OMASTAR KABUTO
KABUTOPS AERODACTYL SNORLAX ARTICUNO ZAPDOS MOLTRES DRATINI DRAGONAIR
DRAGONITE MEWTWO MEW
]]

local WALKERS = [[
AGATHA BEAUTY BIKER BIRD BLUE BRUNETTE_GIRL BRUNO CHANNELER COOK
COOLTRAINER_F COOLTRAINER_M DAISY FAIRY FISHER GAMBLER GENTLEMAN GIOVANNI
GIRL HIKER JAMES JESSIE KOGA LANCE LITTLE_GIRL LORELEI MIDDLE_AGED_MAN
MIDDLE_AGED_WOMAN MONSTER MR_FUJI OAK OFFICER_JENNY PIKACHU RED RED_BIKE
ROCKER ROCKET SAILOR SCIENTIST SEEL SILPH_WORKER_F SUPER_NERD
SURFING_PIKACHU SWIMMER WAITER YOUNGSTER
]]

local STANDING = [[
BALDING_GUY BIKE_SHOP_CLERK BULBASAUR CAPTAIN CHANSEY CLEFAIRY CLERK
FISHING_GURU GAMEBOY_KID GRAMPS GRANNY GUARD GYM_GUIDE JIGGLYPUFF
LINK_RECEPTIONIST LITTLE_BOY MOM NURSE ODDISH SAFARI_ZONE_WORKER SANDSHREW
SILPH_PRESIDENT SILPH_WORKER_M WARDEN
]]

local function words(text)
  return text:gmatch("[%w_]+")
end

local function assetName(species)
  if species == "NIDORAN_F" then return "nidoranf" end
  if species == "NIDORAN_M" then return "nidoranm" end
  if species == "MR_MIME" then return "mr.mime" end
  return species:lower()
end

local function patchOverworld(mod, shortId, frames, walker, file)
  file = file or shortId:lower()
  local frameHeight = file == "scientist" and 48 or 32
  local nativeImage = mod.assets:path("overrides/sprites/" .. file .. ".png")
  mod.content.sprites:patch("SPRITE_" .. shortId, {
    -- DRAMALESS_SHAPE builds its billboard UVs from def.image and assumes a
    -- 16px-tall Gen 1 frame.  Point that measurement at an equivalent proxy
    -- sheet while the renderer below supplies the untouched native HGSS
    -- texture.  Both sheets have the same normalized frame layout, so the
    -- voxel quad samples the complete 32/48px source instead of its top-left
    -- 16px fragment.  The proxy is never presented to the player.
    image = mod.assets:path("assets/voxel/frame_layout_" .. frames .. "_"
      .. frameHeight .. ".png"),
    hgssNativeImage = nativeImage,
    frames = frames,
    walker = walker,
    trueColor = true,
    hgssFrameWidth = 32,
    hgssFrameHeight = frameHeight,
    -- The scientist source is unusually tall (32x48). Preserve the entire
    -- frame, but fit it proportionally into the same 32px world height as
    -- the rest of the HGSS cast instead of making a 1.5x giant billboard.
    hgssVoxelWidth = frameHeight == 48 and (32 * 32 / 48) or 32,
    hgssVoxelHeight = 32,
  })
end

return function(mod)
  -- Any raster supplied by this overhaul already carries its authored HGSS
  -- colors. Normalize separators once so the same check works on Windows and
  -- packaged builds, then use it at every engine path that would otherwise
  -- quantize the image through a four-shade GB/SGB palette.
  local function isHgssTrueColorPath(path)
    if type(path) ~= "string" then return false end
    path = path:gsub("\\", "/")
    return path:find("overrides/battle/", 1, true) ~= nil
        or path:find("overrides/sprites/", 1, true) ~= nil
        or path:find("overrides/title/", 1, true) ~= nil
        or path:find("assets/icons/", 1, true) ~= nil
        or path:find("overrides/trainer_card/", 1, true) ~= nil
  end

  local function loadHdImage(path)
    local ok, image = pcall(love.graphics.newImage, mod.assets:path(path))
    if not ok or not image then return nil end
    image:setFilter("linear", "linear")
    return image
  end

  mod.options:define({
    {
      key = "crisp_display",
      label = "CRISP DISPLAY",
      type = "toggle",
      default = true,
    },
  })

  -- Keep the original 80x80 HGSS PNGs and render them 1:1.  This is the
  -- reference composition: a Pikachu's authored ~48px silhouette and Red's
  -- full back sprite remain visible instead of being shrunk to GBC scale.
  for species in words(SPECIES) do
    mod.content.pokemon:patch(species, {
      trueColor = true,
      battleScaleFront = 1,
      battleScaleBack = 1,
    })
    -- The base game already provides an icon record for every Gen I species.
    -- Registering those same IDs collides in the record registry, so update
    -- the existing records instead of trying to create duplicates.
    mod.content.icons:patch(species, {
      image = mod.assets:path("assets/icons/" .. assetName(species) .. ".png"),
      frames = 2,
    })
  end

  -- The player's trainer back is not species-keyed, so route it to the
  -- bundled image through the public field registry and scale that path.
  local playerBack = mod.assets:path("overrides/battle/redb.png")
  mod.content.field:patch("playerPics", {
    back = playerBack,
    oakBack = mod.assets:path("overrides/battle/profoakb.png"),
  })
  mod.content.battle_sprite_scales:register("hgss_player_back", {
    path = playerBack,
    scale = 1,
  })
  local oakBack = mod.assets:path("overrides/battle/profoakb.png")
  mod.content.battle_sprite_scales:register("hgss_oak_back", {
    path = oakBack,
    scale = 1,
  })

  -- Trainer portraits are data records rather than a public image registry.
  -- Keep the authored 80x80 DS raster; the narrow draw adapter below centers
  -- it in the original trainer slot without throwing away half the pixels.
  local TRAINER_PICS = {
    OPP_AGATHA = "agatha", OPP_BEAUTY = "beauty", OPP_BIKER = "biker",
    OPP_BIRD_KEEPER = "birdkeeper", OPP_BLACKBELT = "blackbelt",
    OPP_BLAINE = "blaine", OPP_BROCK = "brock", OPP_BRUNO = "bruno",
    OPP_BUG_CATCHER = "bugcatcher", OPP_BURGLAR = "burglar",
    OPP_CHANNELER = "channeler", OPP_COOLTRAINER_F = "cooltrainerf",
    OPP_COOLTRAINER_M = "cooltrainerm", OPP_CUE_BALL = "cueball",
    OPP_ENGINEER = "engineer", OPP_ERIKA = "erika", OPP_FISHER = "fisher",
    OPP_GAMBLER = "gambler", OPP_GENTLEMAN = "gentleman",
    OPP_GIOVANNI = "giovanni", OPP_HIKER = "hiker",
    OPP_JR_TRAINER_F = "jr.trainerf",
    OPP_JR_TRAINER_M = "jr.trainerm", OPP_JUGGLER = "juggler",
    OPP_KOGA = "koga", OPP_LANCE = "lance", OPP_LASS = "lass",
    OPP_LORELEI = "lorelei", OPP_LT_SURGE = "lt.surge", OPP_MISTY = "misty",
    OPP_POKEMANIAC = "pokemaniac", OPP_PROF_OAK = "prof.oak",
    OPP_PSYCHIC_TR = "psychic", OPP_RIVAL1 = "rival1", OPP_RIVAL2 = "rival2",
    OPP_RIVAL3 = "rival3", OPP_ROCKER = "rocker", OPP_ROCKET = "rocket",
    OPP_SABRINA = "sabrina", OPP_SAILOR = "sailor", OPP_SCIENTIST = "scientist",
    OPP_SUPER_NERD = "supernerd", OPP_SWIMMER = "swimmer", OPP_TAMER = "tamer",
    OPP_YOUNGSTER = "youngster",
  }
  local TRAINER_HD_BY_PATH = {}
  for trainerId, file in pairs(TRAINER_PICS) do
    local portrait = mod.assets:path("overrides/battle/trainers/" .. file .. ".png")
    TRAINER_HD_BY_PATH[portrait] = loadHdImage(
      "assets/graphics/trainers/front_hd/" .. file .. ".png")
    mod.content.trainers:patch(trainerId, {
      pic = portrait,
      trueColor = true,
    })
    mod.content.battle_sprite_scales:register("hgss_trainer_" .. file, {
      path = portrait,
      scale = 1,
    })
  end
  -- Jessie & James are not a separate Yellow trainer class. Their four
  -- encounters are Rocket parties 42-45, which the engine selects through
  -- picJessieJames. Keep the normal Rocket portrait for every other grunt.
  local jessieJamesPic = mod.assets:path(
    "overrides/battle/trainers/jessie_james.png")
  mod.content.trainers:patch("OPP_ROCKET", {
    picJessieJames = jessieJamesPic,
  })
  TRAINER_HD_BY_PATH[jessieJamesPic] = loadHdImage(
    "assets/graphics/trainers/front_hd/jessie_james.png")
  mod.content.battle_sprite_scales:register("hgss_trainer_jessie_james", {
    path = jessieJamesPic,
    scale = 1,
  })

  -- The public hook supplies the true-color flag; Oak's tutorial back is
  -- provided through the dedicated playerPics oakBack asset above.
  mod.hooks:wrap("player.sprite", function(next, path, ctx)
    local resolved = next(path, ctx)
    if ctx.oakDemo then
      -- The Yellow Pallet tutorial uses Oak in the player's back slot.
      -- Keep the authored HGSS colors; the vanilla demo palette turns the
      -- coat into broken purple/orange fragments.
      ctx.trueColor = true
    elseif not ctx.demo then
      ctx.trueColor = true
    end
    return resolved
  end)

  for shortId in words(WALKERS) do
    patchOverworld(mod, shortId, 6, true)
  end
  -- A few Yellow map objects refer to fallback IDs (HIKER/SUPER_NERD) even
  -- though their names/classes are Blackbelt and Burglar.  Supply the
  -- missing native HGSS IDs so the object-local corrections below can point
  -- to real sprites instead of silently failing on absent registry entries.
  patchOverworld(mod, "BLACKBELT", 6, true, "bruno")
  patchOverworld(mod, "BURGLAR", 6, true, "rocket")
  for shortId in words(STANDING) do
    patchOverworld(mod, shortId, 3, false)
  end
  patchOverworld(mod, "SNORLAX", 1, false)

  -- Gym maps in Yellow deliberately reuse generic GBC character IDs.  Keep
  -- those generic IDs intact for ordinary NPCs and expose dedicated HGSS
  -- sheets for the named leaders; the map-enter hook below selects them by
  -- object name.  All seven leaders use the native six-frame 32px DS sheet.
  local LEADER_SHEETS = {
    GYM_BROCK = "gym_brock",
    GYM_MISTY = "gym_misty",
    GYM_LT_SURGE = "gym_lt_surge",
    GYM_KOGA = "gym_koga",
    GYM_SABRINA = "gym_sabrina",
    GYM_BLAINE = "gym_blaine",
    GYM_GIOVANNI = "gym_giovanni",
    HGSS_BLUE = "gary",
  }
  for shortId, file in pairs(LEADER_SHEETS) do
    patchOverworld(mod, shortId, 6, true, file)
  end
  -- Oak keeps the verified HGSS front frame and uses the AI-authored
  -- back/side/walk cells generated from that reference.  The replacement is
  -- a real walker so turning and walking select the corresponding cells.
  patchOverworld(mod, "HGSS_OAK", 6, true, "oak")
  patchOverworld(mod, "HGSS_BILL", 6, true, "bill")

  -- The stock renderer always builds 16x16 quads.  Our generated sheets are
  -- 32x192 (six 32x32 frames in native DS density), so install a small,
  -- version-pinned compatibility adapter.  It preserves palette resolution,
  -- right-facing flips, walking cadence and the fishing top-half behavior.
  local SpriteRenderer = require("src.render.SpriteRenderer")
  local SpriteAssets = require("src.render.Assets")
  local PaletteFX = require("src.render.PaletteFX")
  local BattleState = require("src.battle.BattleState")
  local oldNew = SpriteRenderer.new
  local oldDraw = SpriteRenderer.draw

  -- DRAMALESS_SHAPE deliberately keeps its namespace private, so there is
  -- no public billboard-size hook to call.  Locate its SpriteBillboards
  -- table through the registered voxel callback once content has merged,
  -- then widen only our proxy-backed cards.  Texture UVs remain untouched;
  -- the native 32/48px image still supplies every authored pixel.
  local voxelBillboardsPatched = false
  local function patchVoxelBillboards()
    if voxelBillboardsPatched or not (debug and debug.getupvalue) then return end
    local okP, Pipelines = pcall(require, "src.render.Pipelines")
    local voxel = okP and Pipelines.get and Pipelines.get("voxel")
    if not (voxel and type(voxel.drawWorld) == "function") then return end
    local seen = {}
    local function find(value, depth)
      if depth > 10 or seen[value] then return nil end
      local kind = type(value)
      if kind ~= "function" and kind ~= "table" then return nil end
      seen[value] = true
      if kind == "table" then
        if type(value.mesh) == "function"
          and type(value.shadowQuad) == "function" then return value end
        for _, child in pairs(value) do
          local hit = find(child, depth + 1)
          if hit then return hit end
        end
      else
        local index = 1
        while true do
          local name, child = debug.getupvalue(value, index)
          if not name then break end
          local hit = find(child, depth + 1)
          if hit then return hit end
          index = index + 1
        end
      end
      return nil
    end
    local billboards = find(voxel.drawWorld, 0)
    if not billboards then return end
    local originalMesh = billboards.mesh
    local sized = setmetatable({}, { __mode = "k" })
    local function nativeMesh(def, frame)
      local mesh = originalMesh(def, frame)
      if not (mesh and def and def.hgssNativeImage) then return mesh end
      local width = tonumber(def.hgssVoxelWidth or def.hgssFrameWidth) or 32
      local height = tonumber(def.hgssVoxelHeight or def.hgssFrameHeight) or 32
      local stamp = width .. "x" .. height
      if sized[mesh] ~= stamp and mesh.getVertex and mesh.setVertex then
        local left = 8 - width / 2
        for vertex = 1, 4 do
          local data = { mesh:getVertex(vertex) }
          local right = data[1] > 8
          local top = data[2] > 8
          data[1] = right and (left + width) or left
          data[2] = top and height or 0
          mesh:setVertex(vertex, unpack(data))
        end
        sized[mesh] = stamp
      end
      return mesh
    end
    billboards.mesh = nativeMesh
    billboards.shadowQuad = nativeMesh

    -- Voxel's BattlePics reconstructs white interiors for alpha-keyed Gen 1
    -- artwork. Our 80x80 HGSS battle sprites already contain authored RGB and
    -- real alpha, so that flood fill mistakes legitimate openings (notably
    -- the gap between Pikachu's tail and body) for white paint. Bypass the
    -- reconstruction only for native-density pictures; vanilla 56px art
    -- keeps the compatibility fill it needs.
    local seenPics = {}
    local function findBattlePics(value, depth)
      if depth > 10 or seenPics[value] then return nil end
      local kind = type(value)
      if kind ~= "function" and kind ~= "table" then return nil end
      seenPics[value] = true
      if kind == "table" then
        if type(value.filled) == "function" and value.FILL
           and value.DRAIN then return value end
        for _, child in pairs(value) do
          local hit = findBattlePics(child, depth + 1)
          if hit then return hit end
        end
      else
        local index = 1
        while true do
          local name, child = debug.getupvalue(value, index)
          if not name then break end
          local hit = findBattlePics(child, depth + 1)
          if hit then return hit end
          index = index + 1
        end
      end
      return nil
    end
    local battlePics = findBattlePics(voxel.drawWorld, 0)
    if battlePics then
      local originalFilled = battlePics.filled
      battlePics.filled = function(image, ...)
        if image and image.getDimensions then
          local width, height = image:getDimensions()
          if width >= 80 and height >= 80 then return image end
        end
        return originalFilled(image, ...)
      end
    end
    voxelBillboardsPatched = true
  end

  -- BattleState's trainer branch calls love.graphics.draw(image, x, y)
  -- directly and has no public scale/placement field.  Native 80px portraits
  -- are centered by shifting that one draw 16px left (the classic 160px
  -- field has 64px of room on the right); all Pokemon and vanilla draws keep
  -- the engine's original path untouched.
  local oldBattleDrawPicsLayer = BattleState.drawPicsLayer
  local voxelRedBackPath = mod.assets:path("assets/voxel/red_back_final.png")
  local voxelOakBackPath = mod.assets:path("assets/voxel/oak_back_final.png")
  local oldBattleEnter = BattleState.enter
  BattleState.enter = function(self, ...)
    local okP, Pipelines = pcall(require, "src.render.Pipelines")
    local opts = self.game and self.game.save and self.game.save.options
    local modOpts = opts and opts.modOptions and opts.modOptions.DRAMALESS_SHAPE
    local staged = okP and Pipelines.level("voxel") > 0
      and (not modOpts or modOpts.battles ~= false)
    local pics = self.data and self.data.field and self.data.field.playerPics
    if not (staged and pics) then return oldBattleEnter(self, ...) end
    local key = self.oakDemo and "oakBack" or "back"
    local original = pics[key]
    pics[key] = self.oakDemo and voxelOakBackPath or voxelRedBackPath
    local ok, a, b, c = pcall(oldBattleEnter, self, ...)
    pics[key] = original
    if not ok then error(a, 0) end
    return a, b, c
  end

  BattleState.drawPicsLayer = function(self, ...)
    -- DRAMALESS_SHAPE renders each side into a private texture by temporarily
    -- replacing the opposite battler with boolean false.  In that pass the
    -- portrait must stay inside the voxel card; the post-presentation HD
    -- overlay would otherwise create a second, giant trainer on the screen.
    local voxelTexturePass = self.player == false or self.enemy == false
    local trainer = self.trainerPic and self:picImage(self.trainerPic)
    local trainerPath = self.trainer
      and (self.trainer.picJessieJames or self.trainer.pic)
    self.hgssBattleTrainerHd = not voxelTexturePass
      and self.showEnemyTrainer and trainerPath
      and TRAINER_HD_BY_PATH[trainerPath] or nil
    local player = self.playerBackPic and self:picImage(self.playerBackPic)
    local playerWidth = player and player:getWidth() or 0
    local animatedPlayer = playerWidth == 400 or playerWidth == 320
    if (not trainer or trainer:getWidth() < 80) and not animatedPlayer then
      return oldBattleDrawPicsLayer(self, ...)
    end
    local originalDraw = love.graphics.draw
    local playerQuad
    local playerFrameCount = playerWidth == 320 and 4 or 5
    if animatedPlayer then
      playerQuad = love.graphics.newQuad(0, 0, 80, 80, playerWidth, 80)
    end
    love.graphics.draw = function(image, x, y, ...)
      if image == trainer and type(x) == "number" and type(y) == "number" then
        -- The native portrait is replaced after presentation by the 320px
        -- transparent source. Do not draw it underneath: covering it later
        -- with an opaque white 80x80 rectangle erased voxel/background mods.
        if self.hgssBattleTrainerHd then return end
        if voxelTexturePass then return originalDraw(image, x, y, ...) end
        return originalDraw(image, x - 16, y, ...)
      end
      local imageWidth, imageHeight = image:getDimensions()
      local animatedImage = self.showPlayerBack and imageHeight == 80
        and (imageWidth == 320 or imageWidth == 400)
      if (image == player or animatedImage) and type(x) == "number"
         and type(y) == "number" then
        -- Play the authored sequence once per battle, then hold the final
        -- pose: five frames for Red and four for Oak's Yellow tutorial.
        -- A modulo loop would keep either character gesturing forever.
        self.hgssRedAnimStart = self.hgssRedAnimStart
          or love.timer.getTime()
        local elapsed = math.max(0, love.timer.getTime()
          - self.hgssRedAnimStart)
        local frame = math.min(playerFrameCount - 1, math.floor(elapsed * 8))
        local quad = playerQuad
        if image ~= player or imageWidth ~= playerWidth then
          quad = love.graphics.newQuad(0, 0, 80, 80,
                                       imageWidth, imageHeight)
        end
        quad:setViewport(frame * 80, 0, 80, 80, imageWidth, imageHeight)
        return originalDraw(image, quad, x, y, ...)
      end
      return originalDraw(image, x, y, ...)
    end
    local ok, a, b, c = pcall(oldBattleDrawPicsLayer, self, ...)
    love.graphics.draw = originalDraw
    if not ok then error(a, 0) end
    return a, b, c
  end

  SpriteRenderer.new = function(spriteDef, seed)
    patchVoxelBillboards()
    local self = oldNew(spriteDef, seed)
    if self and spriteDef and spriteDef.hgssNativeImage then
      self.image = SpriteAssets.image(spriteDef.hgssNativeImage)
    end
    if self and self.image then
      local iw, ih = self.image:getDimensions()
      local fw = tonumber(spriteDef and spriteDef.hgssFrameWidth) or 32
      local fh = tonumber(spriteDef and spriteDef.hgssFrameHeight) or 32
      if iw == fw and ih >= fh and ih % fh == 0 then
        self.hgssFrames = {}
        self.hgssFrameWidth = fw
        self.hgssFrameHeight = fh
        local count = math.min(6, math.floor(ih / fh))
        for frame = 0, count - 1 do
          self.hgssFrames[frame] = love.graphics.newQuad(
            0, frame * fh, fw, fh, iw, ih)
        end
        self.isHgssSheet = true
      end
    end
    return self
  end

  SpriteRenderer.draw = function(self, px, py, camX, camY, facing,
                                  walkPhase, stepFlip, topHalf)
    if not self.isHgssSheet then
      return oldDraw(self, px, py, camX, camY, facing, walkPhase,
                     stepFlip, topHalf)
    end
    local fw = self.hgssFrameWidth or 32
    local fh = self.hgssFrameHeight or 32
    local x = math.floor(px - camX) - math.floor(fw / 2) + 8
    local y = math.floor(py - camY) - fh + 16
    local stand = { down = 0, up = 1, left = 2, right = 2 }
    local walk = { down = 3, up = 4, left = 5, right = 5 }
    local frame = (self.def.walker and walkPhase == 1)
      and walk[facing] or stand[facing]
    frame = frame or 0
    local quad = self.hgssFrames[frame] or self.hgssFrames[0]
    if topHalf then
      self.hgssHalfFrames = self.hgssHalfFrames or {}
      if not self.hgssHalfFrames[frame] then
        local iw, ih = self.image:getDimensions()
        self.hgssHalfFrames[frame] = love.graphics.newQuad(
          0, frame * fh, fw, math.floor(fh / 2), iw, ih)
      end
      quad = self.hgssHalfFrames[frame]
    end
    local image = self.resolveImage and self:resolveImage() or self.image
    local flip = facing == "right"
    if self.def.trueColor and PaletteFX.markTrueColor then
      PaletteFX.markTrueColor(x, y, fw, topHalf and math.floor(fh / 2) or fh)
    end
    if flip then
      love.graphics.draw(image, quad, x + fw, y, 0, -1, 1)
    else
      love.graphics.draw(image, quad, x, y)
    end
  end

  -- PartyMenu's public icon registry is intentionally compatible with the
  -- Game Boy path: it assumes 16x16 OBP art and sends the whole UI canvas
  -- through the four-shade SGB shader.  HGSS party art is authored at 32x32
  -- and in full RGB, so install the same narrow adapter used by overworld:
  -- keep the native frame, draw it with nearest filtering, and report a
  -- trueColor rectangle so no palette pass can collapse the hues.
  local PartyMenu = require("src.ui.PartyMenu")
  local PartyAssets = require("src.render.Assets")
  local PartyPaletteFX = require("src.render.PaletteFX")

  local PartyFont = require("src.render.Font")
  local PartyHudTiles = require("src.render.HudTiles")
  local PartyTheme = require("src.ui.Theme")
  local oldPartyDraw = PartyMenu.draw
  local oldPartyDrawIcon = PartyMenu.drawIcon
  local partyIconImages = {}
  local partyIconRoot = mod.assets:path("assets/icons/")

  local function partyIconPath(game, mon)
    local icons = game.data and game.data.icons
    local def = game.data and game.data.pokemon and game.data.pokemon[mon.species]
    if not icons then return nil end
    local entry = (icons.bySpecies and icons.bySpecies[mon.species])
               or (def and def.icon)
    local name, path
    if type(entry) == "string" then
      name = entry
      path = icons.icons and icons.icons[entry]
    elseif type(entry) == "table" then
      path = entry.image
    end
    if not path then
      name = def and def.dex and icons.byDex and icons.byDex[def.dex]
      path = name and icons.icons and icons.icons[name]
    end
    return require("src.pokemon.Sprites").iconPath(
      game.data, mon, path, { name = name })
  end

  local function isHgssPartyIcon(path)
    return type(path) == "string"
       and path:sub(1, #partyIconRoot) == partyIconRoot
  end

  local function loadPartyIcon(path)
    local resolved = PartyAssets.resolve(path)
    if partyIconImages[resolved] == nil then
      local ok, image = pcall(love.graphics.newImage, resolved)
      if ok and image and image.setFilter then
        image:setFilter("nearest", "nearest")
      end
      partyIconImages[resolved] = ok and image or false
    end
    return partyIconImages[resolved] or nil
  end

  PartyMenu.drawIcon = function(game, mon, x, y, selected, counter, forceAlt)
    local path = partyIconPath(game, mon)
    if not isHgssPartyIcon(path) then
      return oldPartyDrawIcon(game, mon, x, y, selected, counter, forceAlt)
    end
    local image = loadPartyIcon(path)
    if not image then return end
    local alt = forceAlt and true or false
    if selected then
      local hp = mon.hp or 0
      local maxHp = mon.stats and mon.stats.hp or 1
      local px = math.floor(hp * 48 / math.max(1, maxHp))
      local speed = px >= 27 and 5 or px >= 10 and 16 or 32
      alt = math.floor((counter or 0) / speed) % 2 == 1
    end
    local iw, ih = image:getDimensions()
    local frame = alt and 1 or 0
    if iw < 32 or ih < (frame + 1) * 32 then return end
    PartyPaletteFX.markTrueColor(x, y, 32, 32)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(image,
      love.graphics.newQuad(0, frame * 32, 32, 32, iw, ih), x, y)
    return true
  end

  -- Compact 4x7 pixel glyphs for the party-name column.  The regular engine
  -- font advances 8px per character, but each HGSS cell has only 48px beside
  -- its 32px icon.  A dedicated crisp mini-font keeps names such as
  -- CHARIZARD and BLASTOISE complete without fractional scaling artifacts.
  local MINI_FONT = {
    A={"0110","1001","1001","1111","1001","1001","1001"},
    B={"1110","1001","1001","1110","1001","1001","1110"},
    C={"0111","1000","1000","1000","1000","1000","0111"},
    D={"1110","1001","1001","1001","1001","1001","1110"},
    E={"1111","1000","1000","1110","1000","1000","1111"},
    F={"1111","1000","1000","1110","1000","1000","1000"},
    G={"0111","1000","1000","1011","1001","1001","0111"},
    H={"1001","1001","1001","1111","1001","1001","1001"},
    I={"1111","0110","0110","0110","0110","0110","1111"},
    J={"0011","0001","0001","0001","0001","1001","0110"},
    K={"1001","1010","1100","1100","1010","1001","1001"},
    L={"1000","1000","1000","1000","1000","1000","1111"},
    M={"1001","1111","1111","1001","1001","1001","1001"},
    N={"1001","1101","1101","1011","1011","1001","1001"},
    O={"0110","1001","1001","1001","1001","1001","0110"},
    P={"1110","1001","1001","1110","1000","1000","1000"},
    Q={"0110","1001","1001","1001","1011","1001","0111"},
    R={"1110","1001","1001","1110","1010","1001","1001"},
    S={"0111","1000","1000","0110","0001","0001","1110"},
    T={"1111","0110","0110","0110","0110","0110","0110"},
    U={"1001","1001","1001","1001","1001","1001","0110"},
    V={"1001","1001","1001","1001","1001","0110","0110"},
    W={"1001","1001","1001","1111","1111","1111","1001"},
    X={"1001","1001","0110","0110","0110","1001","1001"},
    Y={"1001","1001","0110","0110","0110","0110","0110"},
    Z={"1111","0001","0010","0100","1000","1000","1111"},
    ["0"]={"0110","1001","1011","1101","1001","1001","0110"},
    ["1"]={"0110","1100","0110","0110","0110","0110","1111"},
    ["2"]={"0110","1001","0001","0010","0100","1000","1111"},
    ["3"]={"1110","0001","0001","0110","0001","0001","1110"},
    ["4"]={"1001","1001","1001","1111","0001","0001","0001"},
    ["5"]={"1111","1000","1000","1110","0001","0001","1110"},
    ["6"]={"0111","1000","1000","1110","1001","1001","0110"},
    ["7"]={"1111","0001","0010","0010","0100","0100","0100"},
    ["8"]={"0110","1001","1001","0110","1001","1001","0110"},
    ["9"]={"0110","1001","1001","0111","0001","0001","1110"},
    ["."]={"0000","0000","0000","0000","0000","0110","0110"},
    [" "]={"0000","0000","0000","0000","0000","0000","0000"},
    ["?"]={"1110","0001","0010","0100","0100","0000","0100"},
  }

  local function drawPartyName(name, x, y)
    local text = tostring(name or ""):upper()
    local count = #text
    if count == 0 then return end
    local advance = count <= 9 and 5 or math.max(3, math.floor(48 / count))
    local glyphWidth = advance >= 4 and 4 or 3
    for index = 1, count do
      local glyph = MINI_FONT[text:sub(index, index)] or MINI_FONT["?"]
      local gx = x + (index - 1) * advance
      for row, bits in ipairs(glyph) do
        for col = 1, glyphWidth do
          if bits:sub(col, col) == "1" then
            love.graphics.rectangle("fill", gx + col - 1, y + row - 1, 1, 1)
          end
        end
      end
    end
  end

  local function drawNativePartyEntry(self, mon, index, x, y)
    local def = self.game.data.pokemon[mon.species]
    PartyMenu.drawIcon(self.game, mon, x, y, index == self.index,
                       self.blink or 0)
    local textX = x + 32
    love.graphics.setColor(0, 0, 0, 1)
    drawPartyName(mon.nickname or def.name, textX, y)
    PartyFont.draw("L" .. tostring(mon.level), textX, y + 8)
    if self.tmhm then
      local can = false
      for _, move in ipairs(def.tmhm or {}) do
        if move == self.tmhm.move then can = true break end
      end
      PartyFont.draw(can and "ABLE" or "NO", textX + 24, y + 8)
    else
      local shown = mon
      if self.heal and self.heal.mon == mon then
        shown = { hp = math.floor(self.heal.shown), stats = mon.stats }
      end
      -- Three segments fit exactly in the 48px text column.  Marking the
      -- bar trueColor keeps its green/yellow/red ramp independent from the
      -- party screen's legacy SGB zone list.
      PartyHudTiles.drawHPBar(self.game.data, textX / 8, (y + 16) / 8,
                              shown, nil, false, 3)
      PartyPaletteFX.markTrueColor(textX, y + 16, 48, 8)
      if mon.hp <= 0 then
        PartyFont.draw("FNT", textX + 24, y + 8)
      elseif mon.status then
        PartyFont.draw(mon.status, textX + 24, y + 8)
      end
    end
    if index == self.index then
      PartyFont.drawCode(PartyTheme.cursor, x, y + 8)
    elseif index == self.swapFrom or index == self.softboiledFrom then
      PartyFont.drawCode(PartyTheme.cursorHollow, x, y + 8)
    end
  end

  PartyMenu.draw = function(self)
    local party = self.party or self.game.save.party
    local hasNative = false
    for _, mon in ipairs(party) do
      if isHgssPartyIcon(partyIconPath(self.game, mon)) then
        hasNative = true
        break
      end
    end
    if not hasNative then return oldPartyDraw(self) end

    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.rectangle("fill", 0, 0, 160, 144)
    love.graphics.setColor(0, 0, 0, 1)
    if #party == 0 then
      PartyFont.draw("No POKéMON!", 16, 64)
    end
    -- The six 32px DS cells are arranged as HGSS-style two columns by
    -- three rows.  This preserves every authored pixel without stacking
    -- 32px art into the old 16px Game Boy rows.
    for i, mon in ipairs(party) do
      local slot = i - 1
      local col = slot % 2
      local row = math.floor(slot / 2)
      drawNativePartyEntry(self, mon, i, col * 80, row * 32)
    end

    -- Keep the original interaction text and submenu actions; only the
    -- party entries above are reflowed to the native DS grid.
    PartyFont.drawBox(0, 12, 20, 6)
    love.graphics.setColor(0, 0, 0, 1)
    local prompt
    if self.swapFrom then
      prompt = "Move to where?"
    elseif self.softboiledFrom or self.pickOnly then
      prompt = "Use on which one?"
    elseif self.tmhm then
      prompt = self.game.data.text._PartyMenuUseTMText or "Use TM on which\nPOKéMON?"
    elseif self.battle then
      prompt = self.game.data.text._PartyMenuBattleText or "Bring out which\nPOKéMON?"
    else
      prompt = self.game.data.text._PartyMenuNormalText or "Choose a POKéMON."
    end
    local ly = 112
    for line in (prompt .. "\n"):gmatch("([^\n]*)\n") do
      PartyFont.draw(line, 8, ly)
      ly = ly + 16
    end
    if self.submenu then
      local n = #self.subItems
      PartyFont.drawBox(9, 17 - n * 2 - 1, 11, n * 2 + 1)
      local y0 = (17 - n * 2) * 8
      for si, entry in ipairs(self.subItems) do
        PartyFont.draw(entry.label, 88, y0 + (si - 1) * 16)
      end
      PartyFont.drawCode(PartyTheme.cursor, 80,
                         y0 + (self.subIndex - 1) * 16)
    end
    love.graphics.setColor(1, 1, 1, 1)
  end

  -- OakSpeech resolves trainer descriptors without carrying trainer metadata
  -- into its trueColor return value. As a result, the intro's full-color Oak
  -- portrait was still collapsed to purple/orange GB shades. Propagate the
  -- flag for every trainer portrait owned by this overhaul (Oak, rival and
  -- any modded/custom intro step), while leaving vanilla assets untouched.
  local OakSpeech = require("src.ui.OakSpeech")
  local oldResolveOakSpeechPic = OakSpeech.resolvePic
  OakSpeech.resolvePic = function(game, desc, speech)
    local image, flip, trueColor = oldResolveOakSpeechPic(game, desc, speech)
    if trueColor then return image, flip, true end
    local trainerId
    if desc == "oak" then
      trainerId = "OPP_PROF_OAK"
    elseif desc == "rival" then
      trainerId = "OPP_RIVAL1"
    elseif type(desc) == "table" and desc.type == "trainer" then
      trainerId = desc.id
    end
    local trainer = trainerId and game.data.trainers
                    and game.data.trainers[trainerId]
    if trainer and (trainer.trueColor or isHgssTrueColorPath(trainer.pic)) then
      trueColor = true
    end
    return image, flip, trueColor and true or false
  end

  local oldOakSpeechNew = OakSpeech.new
  OakSpeech.new = function(...)
    local speech = oldOakSpeechNew(...)
    speech.hgssHdPics = {}
    local function map(low, path)
      local hd = low and loadHdImage(path)
      if low and hd then speech.hgssHdPics[low] = hd end
    end
    map(speech.oakPic, "assets/graphics/trainers/front_hd/prof.oak.png")
    map(speech.rivalPic, "assets/graphics/trainers/front_hd/rival1.png")
    map(speech.playerPic, "assets/graphics/intro_hd/red.png")
    if speech.demoSpecies then
      map(speech.demoPic, "assets/graphics/pokemon/front_hd/"
        .. assetName(speech.demoSpecies):upper() .. ".png")
    end
    return speech
  end

  -- OakSpeech still draws its native 56/80px picture into the low-resolution
  -- canvas before the post-presentation HD layer. Once the white cover was
  -- removed for transparency, that original became visible behind Red and
  -- could also thicken the edges of Oak/Blue. Suppress only pictures that
  -- have an HD replacement; Pokémon and shrink frames keep the stock path.
  local oldOakSpeechDraw = OakSpeech.draw
  OakSpeech.draw = function(self, ...)
    local hd = self.pic and self.hgssHdPics and self.hgssHdPics[self.pic]
    if not hd then return oldOakSpeechDraw(self, ...) end
    local originalDraw = love.graphics.draw
    love.graphics.draw = function(image, ...)
      if image == self.pic then return end
      return originalDraw(image, ...)
    end
    local ok, a, b, c = pcall(oldOakSpeechDraw, self, ...)
    love.graphics.draw = originalDraw
    if not ok then error(a, 0) end
    return a, b, c
  end

  -- TrainerState normally remaps portraits through the four-shade MEWMON
  -- palette. Our portrait PNGs are already an exact nearest 80->40 raster,
  -- so keep their authored HGSS colors instead of collapsing them to DMG
  -- shades. Vanilla portraits retain the engine's original palette path.
  local oldTrainerPalette = BattleState.trainerPalette
  BattleState.trainerPalette = function(data, trainer)
    local path = trainer and trainer.pic
    if isHgssTrueColorPath(path)
       or (trainer and trainer.trueColor) then
      return nil
    end
    return oldTrainerPalette(data, trainer)
  end

  -- A nil trainer palette prevents the initial quantization, but later battle
  -- effects can still rebuild that same picture through a GB fade/mono path.
  -- True-color trainer portraits have no four DMG shades to permute, so return
  -- their original image exactly as the engine already does for true-color
  -- Pokemon sprites.
  local oldBattlePicImage = BattleState.picImage
  BattleState.picImage = function(self, image)
    local trainer = self and self.trainer
    local path = trainer and (trainer.picJessieJames or trainer.pic)
    if image == (self and self.trainerPic)
       and (isHgssTrueColorPath(path) or (trainer and trainer.trueColor)) then
      return image
    end
    return oldBattlePicImage(self, image)
  end

  -- The trainer-card portrait already advertises trueColor through
  -- playerPath, but the leader faces and badge sheet have no registry record
  -- capable of carrying that flag. Mark their complete grid explicitly so
  -- full-color HGSS badges are not collapsed by the card's MEWMON zone.
  local TrainerCard = require("src.ui.TrainerCard")
  local oldTrainerCardDraw = TrainerCard.draw
  TrainerCard.draw = function(self, ...)
    local result = oldTrainerCardDraw(self, ...)
    PartyPaletteFX.markTrueColor(16, 94, 128, 50)
    return result
  end

  -- Yellow carries three unused aliases that share Red's real sheet.
  patchOverworld(mod, "UNUSED_RED_1", 6, true, "red")
  patchOverworld(mod, "UNUSED_RED_2", 6, true, "red")
  patchOverworld(mod, "UNUSED_RED_3", 6, true, "red")

  -- A private high-code page supplies six border pieces and three menu
  -- markers.  field.theme routes the global UI to them without colliding
  -- with the native text/charmap pages.
  mod.content.font:register("hgss_chrome", {
    image = mod.assets:path("assets/ui/hgss_border.png"),
    base = 0x200,
    glyphsPerRow = 9,
    advance = 8,
  })
  mod.content.field:patch("theme", {
    border = {
      tl = 0x200, h = 0x201, tr = 0x202,
      v = 0x203, bl = 0x204, br = 0x205,
    },
    cursor = 0x206,
    cursorHollow = 0x207,
    moreArrow = 0x208,
  })

  -- Merely swapping the six 8x8 border glyphs still leaves a monochrome
  -- Game Boy window. Draw the global boxes as true-color DS chrome instead:
  -- navy outer edge, cool-gray inset and a clean white content surface.
  -- Every menu continues to own its original geometry and text layout.
  local UiFont = require("src.render.Font")
  local UiPaletteFX = require("src.render.PaletteFX")
  UiFont.drawBox = function(tx, ty, tw, th)
    local x, y, w, h = tx * 8, ty * 8, tw * 8, th * 8
    local r, g, b, a = love.graphics.getColor()
    love.graphics.setColor(0.10, 0.18, 0.29, 1)
    love.graphics.rectangle("fill", x, y, w, h)
    love.graphics.setColor(0.55, 0.67, 0.76, 1)
    love.graphics.rectangle("fill", x + 1, y + 1, w - 2, h - 2)
    love.graphics.setColor(0.86, 0.91, 0.94, 1)
    love.graphics.rectangle("fill", x + 2, y + 2, w - 4, h - 4)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.rectangle("fill", x + 3, y + 3, w - 6, h - 6)
    love.graphics.setColor(0.72, 0.82, 0.88, 1)
    love.graphics.rectangle("fill", x + 3, y + 3, w - 6, 1)
    UiPaletteFX.markTrueColor(x, y, w, h)
    love.graphics.setColor(r, g, b, a)
  end

  local oldUiDrawCode = UiFont.drawCode
  UiFont.drawCode = function(code, x, y)
    local filled = code == 0x206 or code == 0xED
    local hollow = code == 0x207 or code == 0xEC
    local more = code == 0x208 or code == 0xEE
    if not filled and not hollow and not more then
      return oldUiDrawCode(code, x, y)
    end
    local r, g, b, a = love.graphics.getColor()
    if more then
      love.graphics.setColor(0.18, 0.39, 0.66, 1)
      love.graphics.polygon("fill", x + 1, y + 2, x + 7, y + 2,
                            x + 4, y + 6)
    else
      love.graphics.setColor(filled and 0.86 or 0.30,
                            filled and 0.22 or 0.49,
                            filled and 0.18 or 0.70, 1)
      love.graphics.polygon(filled and "fill" or "line",
                            x + 1, y + 1, x + 7, y + 4,
                            x + 1, y + 7)
    end
    UiPaletteFX.markTrueColor(x, y, 8, 8)
    love.graphics.setColor(r, g, b, a)
  end

  -- HGSS-like health colors use the engine's supported four-shade palette
  -- path, so battle, party and summary bars stay correct in every renderer.
  mod.content.palettes:override("GREENBAR", {
    { 255, 255, 255 }, { 184, 224, 184 }, { 72, 184, 72 }, { 24, 32, 32 },
  })
  mod.content.palettes:override("YELLOWBAR", {
    { 255, 255, 255 }, { 248, 232, 152 }, { 248, 200, 48 }, { 24, 32, 32 },
  })
  mod.content.palettes:override("REDBAR", {
    { 255, 255, 255 }, { 248, 184, 176 }, { 232, 80, 72 }, { 24, 32, 32 },
  })

  -- Render the actual fill as RGB after the legacy tile bar. This makes the
  -- HGSS green/yellow/red states visible in battle, party and summary even
  -- when the selected display filter would otherwise remap them to GB hues.
  local UiHudTiles = require("src.render.HudTiles")
  local function drawHgssHP(tx, ty, mon, segments)
    segments = math.max(1, math.floor(segments or 6))
    local maxHP = math.max(1, mon.stats.hp)
    local ratio = math.max(0, math.min(1, mon.hp / maxHP))
    local x, y, width = tx * 8 + 15, ty * 8 + 1, segments * 8 + 2
    local color = ratio >= 0.5625 and { 0.20, 0.72, 0.31, 1 }
      or ratio >= 0.2083 and { 0.96, 0.73, 0.12, 1 }
      or { 0.89, 0.22, 0.18, 1 }
    local r, g, b, a = love.graphics.getColor()
    love.graphics.setColor(0.12, 0.16, 0.18, 1)
    love.graphics.rectangle("fill", x, y, width, 6)
    love.graphics.setColor(0.82, 0.86, 0.88, 1)
    love.graphics.rectangle("fill", x + 1, y + 1, width - 2, 4)
    if ratio > 0 then
      love.graphics.setColor(color)
      love.graphics.rectangle("fill", x + 2, y + 2,
        math.max(1, math.floor((width - 4) * ratio)), 2)
    end
    UiPaletteFX.markTrueColor(x, y, width, 6)
    love.graphics.setColor(r, g, b, a)
  end
  local oldUiHPBar = UiHudTiles.drawHPBar
  UiHudTiles.drawHPBar = function(data, tx, ty, mon, barType, grayFill,
                                  segments)
    oldUiHPBar(data, tx, ty, mon, barType, grayFill, segments)
    drawHgssHP(tx, ty, mon, segments)
  end

  -- BattleState cached the original drawHPBar function when its module was
  -- loaded, so repaint its two live bars explicitly after the stock HUD.
  local oldBattleDrawHUDs = BattleState.drawHUDs
  BattleState.drawHUDs = function(self, slide)
    local result = oldBattleDrawHUDs(self, slide)
    if self.enemy and not self.showEnemyTrainer and not self.enemySendingOut
       and slide == 0 and not self.introBalls and not self.enemy.fainted then
      drawHgssHP(2, 2, {
        hp = self.enemy.shownHP or self.enemy.mon.hp,
        stats = self.enemy.mon.stats,
      })
    end
    if self.player and not self.safari and not self.demo
       and not self.showPlayerBack and slide == 0 then
      drawHgssHP(10, 9, {
        hp = self.player.shownHP or self.player.mon.hp,
        stats = self.player.mon.stats,
      })
    end
    return result
  end

  -- These are live display settings, not a replacement renderer.  In
  -- particular, FILL, survey zoom and tilt can all make pixel sizes uneven
  -- or make the 16px character art appear visually mismatched.
  local liveGame

  -- g1recomp normally rasterizes every UI sprite into the 160x144 canvas
  -- before enlarging it. A 320px source therefore collapses back to 80px and
  -- looks just as blocky as the DS original. Repaint only the intro portraits
  -- after the low-resolution canvas has been presented, using the exact same
  -- logical coordinates converted to window space. UI, text and borders keep
  -- their normal renderer; the HD character pixels survive to the display.
  local HdRenderer = require("src.render.Renderer")
  local oldRendererEndFrame = HdRenderer.endFrame

  local function presentationMetrics(renderer)
    local ww, wh = love.graphics.getDimensions()
    local pw, ph = ww, wh
    if love.graphics.getPixelDimensions then
      pw, ph = love.graphics.getPixelDimensions()
    end
    local dpiX = ww > 0 and pw / ww or 1
    local dpiY = wh > 0 and ph / wh or 1
    local uiw, uih = renderer:uiSize()
    local up = renderer:uiScale()
    if renderer.uiFill then up = math.min(ph / uih, pw / uiw) end
    local sx, sy = up / dpiX, up / dpiY
    local ox = math.floor((pw - uiw * up) / 2) / dpiX
    local oy = math.floor((ph - uih * up) / 2) / dpiY
    return sx, sy, ox, oy
  end

  local function visibleHdState()
    local stack = liveGame and liveGame.stack and liveGame.stack.states
    if not stack then return nil end
    for i = #stack, 1, -1 do
      local state = stack[i]
      if state and (state.hgssHdPics or state.hgssBattleTrainerHd) then
        return state
      end
      if state and state.isOpaque then break end
    end
    return nil
  end

  HdRenderer.endFrame = function(self, ...)
    local a, b, c = oldRendererEndFrame(self, ...)
    local state = visibleHdState()
    if not state then return a, b, c end
    local sx, sy, ox, oy = presentationMetrics(self)
    love.graphics.setColor(1, 1, 1, 1)

    if state.hgssBattleTrainerHd and not state.dramaticShapeShot then
      -- Repaint the 320px source after presentation. Passing it through the
      -- 160x144 canvas first would throw away the extra character detail.
      -- WideBattle translates the classic enemy region by +136px, so its
      -- trainer slot begins at 216 instead of the classic slot at 80.
      local trainerX = state.wideLayout and state:wideLayout() and 216 or 80
      local slide = (state.introSlide or 0) * 2
      local offset = state.picOffset and state:picOffset("foe") or 0
      trainerX = trainerX - slide + offset
      local shakeX = state.fx and state.fx.shakeX or 0
      local shakeY = state.fx and state.fx.shakeY or 0
      trainerX = trainerX + (shakeX or 0)
      love.graphics.draw(state.hgssBattleTrainerHd,
        ox + trainerX * sx, oy + (shakeY or 0) * sy,
        0, sx / 4, sy / 4)
      return a, b, c
    end

    local hd = state.pic and state.hgssHdPics[state.pic]
    if hd then
      -- OakSpeech's text box begins at logical y=96. The former 80px HD
      -- canvas ended at y=112, so the box covered the trainer's feet. Fit
      -- the complete authored canvas into a 64px square, center it, and pin
      -- its bottom to y=92 for a four-pixel safety gap above the dialogue.
      local hdw, hdh = hd:getDimensions()
      local logicalScale = 64 / math.max(hdw, hdh)
      local drawW, drawH = hdw * logicalScale, hdh * logicalScale
      local x = (160 - drawW) / 2
      local y = 92 - drawH
      local off, alpha = 0, 1
      local reveal = state.picReveal
      if reveal and reveal.kind == "fade" then
        alpha = math.min(1, reveal.t / reveal.dur)
      elseif reveal and reveal.kind == "wipe" then
        off = math.floor((160 - x) *
          (1 - math.min(1, reveal.t / reveal.dur)))
      end
      love.graphics.setColor(1, 1, 1, alpha)
      if state.picFlip then
        love.graphics.draw(hd, ox + (x + off + drawW) * sx, oy + y * sy,
          0, -sx * logicalScale, sy * logicalScale)
      else
        love.graphics.draw(hd, ox + (x + off) * sx, oy + y * sy,
          0, sx * logicalScale, sy * logicalScale)
      end
      love.graphics.setColor(1, 1, 1, 1)
    end
    return a, b, c
  end
  -- Gym maps reuse generic Yellow sprite IDs, so these redirects must be
  -- scoped to the exact leader object on its own map.  Matching a name
  -- substring globally would turn story NPCs (Rocket Giovanni, aides named
  -- OAK, etc.) into a gym leader by accident.
  local GYM_LEADER_OBJECTS = {
    PEWTER_GYM = { PEWTERGYM_BROCK = "SPRITE_GYM_BROCK" },
    CERULEAN_GYM = { CERULEANGYM_MISTY = "SPRITE_GYM_MISTY" },
    VERMILION_GYM = { VERMILIONGYM_LT_SURGE = "SPRITE_GYM_LT_SURGE" },
    FUCHSIA_GYM = { FUCHSIAGYM_KOGA = "SPRITE_GYM_KOGA" },
    SAFFRON_GYM = { SAFFRONGYM_SABRINA = "SPRITE_GYM_SABRINA" },
    CINNABAR_GYM = { CINNABARGYM_BLAINE = "SPRITE_GYM_BLAINE" },
    VIRIDIAN_GYM = { VIRIDIANGYM_GIOVANNI = "SPRITE_GYM_GIOVANNI" },
  }

  -- Only these objects are Professor Oak himself.  OAKS_AIDE, OAKSLAB_GIRL,
  -- Pokedex objects and similar names must retain their own charsets.
  local OAK_OBJECTS = {
    PALLETTOWN_OAK = true,
    OAKSLAB_OAK1 = true,
    OAKSLAB_OAK2 = true,
    HALLOFFAME_OAK = true,
    CHAMPIONSROOM_OAK = true,
    QA_OAK = true,
  }

  -- A few imported Yellow map objects carry a fallback charset whose name
  -- does not match the character class.  Keep the fix local to those exact
  -- objects; global sprite patches would damage legitimate Cooltrainers,
  -- Hikers and Super Nerds elsewhere in the game.
  local OBJECT_SPRITE_FIXES = {
    BILLS_HOUSE = {
      BILLSHOUSE_BILL1 = "SPRITE_HGSS_BILL",
      BILLSHOUSE_BILL2 = "SPRITE_HGSS_BILL",
    },
    VERMILION_CITY = {
      VERMILIONCITY_BEAUTY = "SPRITE_BEAUTY",
    },
    FIGHTING_DOJO = {
      FIGHTINGDOJO_BLACKBELT1 = "SPRITE_BLACKBELT",
      FIGHTINGDOJO_BLACKBELT2 = "SPRITE_BLACKBELT",
      FIGHTINGDOJO_BLACKBELT3 = "SPRITE_BLACKBELT",
      FIGHTINGDOJO_BLACKBELT4 = "SPRITE_BLACKBELT",
      FIGHTINGDOJO_KARATE_MASTER = "SPRITE_BLACKBELT",
    },
    POKEMON_MANSION_B1F = {
      POKEMONMANSIONB1F_BURGLAR = "SPRITE_BURGLAR",
    },
  }

  local function applyLeaderSprites()
    local game = liveGame
    local overworld = game and game.overworld
    if not overworld or not overworld.npcs then return end
    local mapId = tostring(overworld.map and overworld.map.id or "")
    local gymObjects = GYM_LEADER_OBJECTS[mapId]
    local objectFixes = OBJECT_SPRITE_FIXES[mapId]
    for _, npc in ipairs(overworld.npcs) do
      local def = npc.def
      local objectName = tostring(def and def.name or "")
      local target = (gymObjects and gymObjects[objectName])
        or (objectFixes and objectFixes[objectName])
      -- Yellow calls Gary/Blue simply RIVAL in every map object.  Those names
      -- are specific enough that this does not collide with generic NPCs.
      if not target and objectName:find("RIVAL", 1, true) then
        target = "SPRITE_HGSS_BLUE"
      elseif not target and OAK_OBJECTS[objectName] then
        target = "SPRITE_HGSS_OAK"
      end
      if target and game.data.sprites[target] and def.sprite ~= target then
        def.sprite = target
        if target == "SPRITE_HGSS_OAK" then
          -- Oak's map objects are authored as stationary Yellow NPCs. The
          -- replacement charset has a real six-frame walk cycle, so carry
          -- the walker flag onto the live object as well as the registry.
          def.walker = true
        end
        npc.sprite = SpriteRenderer.new(game.data.sprites[target], npc.id)
        if target == "SPRITE_HGSS_OAK" and npc.sprite then
          npc.sprite.def.walker = true
        end
      end
    end
  end

  local function applyCrispDisplay(game)
    if not mod.options:get("crisp_display") then return end
    local options = game and game.save and game.save.options
    if not options then return end
    options.battleFit = "fixed"
    options.battleLayout = "wide"
    options.uiLayout = "centered"
    options.zoom = 0
    options.tilt = 0
    options.gbcfx = 0
    if game.applyOptions then game:applyOptions(options) end
  end

  mod.events:on("game.ready", function(ev)
    liveGame = ev and ev.game
    applyCrispDisplay(liveGame)
    applyLeaderSprites()
  end)
  mod.events:on("map.entered", applyLeaderSprites)
  mod.events:on("map.reloaded", applyLeaderSprites)
  -- CONTINUE restores the standalone options after game.ready.  Reapply the
  -- cosmetic policy only after that restore has completed.
  mod.events:on("save.loaded", function()
    applyCrispDisplay(liveGame)
    applyLeaderSprites()
  end)
  mod.events:on("save.created", function()
    applyCrispDisplay(liveGame)
    applyLeaderSprites()
  end)

  mod.exports.coverage = {
    pokemon = 151,
    partyIcons = 151,
    battleTrainers = 46,
    overworldCharacters = 70,
    chromeGlyphs = 9,
    trainerCardAssets = 4,
    leaderOverworldCharsets = 9,
    nativeRuntimeScale = true,
    nativeDsOverworld = true,
    integerBattleScale = 1,
  }
end
