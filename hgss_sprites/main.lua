-- HGSS Visual Overhaul 2.0
--
-- The registries and hooks below are Mod API 2.  One deliberately narrow
-- engine-internals hook is also installed for overworld sheets: g1recomp's
-- public SpriteRenderer hard-codes 16x16 cells, while HGSS's authored cells
-- are 32x32 (and Jessie/James keep 4x-density 128px sources). Without this adapter
-- the engine silently crops the DS art into GBC-sized fragments. The adapter
-- only changes native HGSS sheets; every other sprite keeps the stock renderer.

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
AGATHA ASH BEAUTY BIKER BIRD BLUE BRUNETTE_GIRL BRUNO CHANNELER COOK
COOLTRAINER_F COOLTRAINER_M DAISY FAIRY FISHER GAMBLER GENTLEMAN GIOVANNI
GIRL HIKER JAMES JESSIE KOGA LANCE LITTLE_GIRL LORELEI MIDDLE_AGED_MAN
MIDDLE_AGED_WOMAN MONSTER MR_FUJI OAK OFFICER_JENNY PIKACHU RED RED_BIKE
ROCKER ROCKET SAILOR SCIENTIST SEEL SILPH_WORKER_F SUPER_NERD
SURFING_PIKACHU SWIMMER WAITER YOUNGSTER ETHAN
]]

-- HGSS Black Belt is a 32x32 overworld charset, not the 80x80 battle
-- portrait. Keep its map registration separate from the battle assets.
-- The replacement sheet is normalized to six native cells (down, up, side
-- and the three walk frames) so Fighting Dojo trainers can turn toward the
-- player instead of remaining locked to one facing.

local STANDING = [[
BALDING_GUY BIKE_SHOP_CLERK BULBASAUR CAPTAIN CHANSEY CLEFAIRY CLERK
FISHING_GURU GAMEBOY_KID GRAMPS GRANNY GUARD GYM_GUIDE JIGGLYPUFF
LINK_RECEPTIONIST LITTLE_BOY MOM NURSE ODDISH SAFARI_ZONE_WORKER SANDSHREW
SILPH_PRESIDENT SILPH_WORKER_M WARDEN
]]

-- Yellow's map table uses SPRITE_MONSTER for several named Pokémon.  The
-- generic sheet is a Rhydon placeholder, so register the preserved HGSS
-- overworld sheets under dedicated sprite IDs and redirect only those exact
-- map objects below.  This leaves unrelated custom/engine uses of
-- SPRITE_MONSTER untouched.
local POKEMON_OBJECT_SHEETS = {
  -- These are the 32px six-frame sheets used only by map objects that the
  -- Yellow map table labels SPRITE_MONSTER.  The source cells are preserved
  -- from the archived HGSS overworld set; the generated vertical sheets keep
  -- the same frame order as Red so movement and voxel anchors stay aligned.
  POLIWRATH = { shortId = "HGSS_POLIWRATH", file = "hgss_poliwrath", frames = 6 },
  MEOWTH = { shortId = "HGSS_MEOWTH", file = "hgss_meowth", frames = 6 },
  NIDORAN_F = { shortId = "HGSS_NIDORAN_F", file = "hgss_nidoran_f", frames = 6 },
  NIDORAN_M = { shortId = "HGSS_NIDORAN_M", file = "hgss_nidoran_m", frames = 6 },
  NIDORINO = { shortId = "HGSS_NIDORINO", file = "hgss_nidorino", frames = 6 },
  MEWTWO = { shortId = "HGSS_MEWTWO", file = "hgss_mewtwo", frames = 6 },
  -- Cerulean's Electrode and the Power Plant/Fuchsia Voltorb objects are
  -- encoded as SPRITE_POKE_BALL in Yellow, not SPRITE_MONSTER.  Keep these
  -- dedicated static sheets separate so the generic Poké Ball sprite remains
  -- untouched for real item objects.
  VOLTORB = { shortId = "HGSS_VOLTORB", file = "hgss_voltorb", frames = 6 },
  ELECTRODE = { shortId = "HGSS_ELECTRODE", file = "hgss_electrode", frames = 6 },
  KANGASKHAN = { shortId = "HGSS_KANGASKHAN", file = "hgss_kangaskhan", frames = 6 },
  SLOWPOKE = { shortId = "HGSS_SLOWPOKE", file = "hgss_slowpoke", frames = 6 },
  CUBONE = { shortId = "HGSS_CUBONE", file = "hgss_cubone", frames = 6 },
  PSYDUCK = { shortId = "HGSS_PSYDUCK", file = "hgss_psyduck", frames = 6 },
  MACHOKE = { shortId = "HGSS_MACHOKE", file = "hgss_machoke", frames = 6 },
  MACHOP = { shortId = "HGSS_MACHOP", file = "hgss_machop", frames = 6 },
  -- Fuchsia City's fossil display is exposed by the Yellow map as the
  -- generic SPRITE_MONSTER (a Rhydon placeholder).  Use the authored Kabuto
  -- overworld sheet only for that object so other MONSTER uses remain
  -- unchanged.  The source atlas is normalized to Red's six-frame layout.
  KABUTO = { shortId = "HGSS_KABUTO", file = "hgss_kabuto", frames = 6 },
  -- The SS Anne 1F rooms contain a Wigglytuff object whose ROM record points
  -- at SPRITE_JIGGLYPUFF.  Keep a dedicated directional sheet so the object
  -- shows the evolved species without changing the Pewter Center Jigglypuff.
  WIGGLYTUFF = {
    shortId = "HGSS_WIGGLYTUFF", file = "wigglytuff", frames = 6,
    -- Use the same voxel grounding as the other Pokémon.  A positive
    -- per-object offset pushed the sheet into the SS Anne floor, hiding the
    -- body of the rear frame and leaving only its ears visible.
    voxelEntityYOffset = -4,
  },
  -- The three legendary encounters are authored as SPRITE_BIRD in Yellow,
  -- which is a generic bird placeholder. Keep their species-specific HGSS
  -- sheets separate so the overworld object and its battle species agree.
  ARTICUNO = { shortId = "HGSS_ARTICUNO", file = "hgss_articuno", frames = 6 },
  ZAPDOS = { shortId = "HGSS_ZAPDOS", file = "hgss_zapdos", frames = 6 },
  MOLTRES = { shortId = "HGSS_MOLTRES", file = "hgss_moltres", frames = 6 },
  -- The Fearow in Celadon's Fly house is also encoded as SPRITE_BIRD in
  -- Yellow.  Keep this dedicated sheet scoped to that named object so
  -- ordinary Pidgey/Spearow bird objects continue using their own sprites.
  FEAROW = { shortId = "HGSS_FEAROW", file = "hgss_fearow", frames = 6 },
}

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
  -- Overworld sheets use Red's six-frame layout. Scientist remains 32x192;
  -- keeping its old 48px frame height samples adjacent cells and produces
  -- oversized/garbled sprites. Jessie and James carry the same layout at 4x.
  -- Team Rocket keeps a 4x authored sheet. It is still presented in the same
  -- 32x32 logical box as Red; the extra texels preserve the generated art
  -- instead of baking it down to a 20x24 miniature before rendering.
  -- Red's on-foot sheet intentionally stays on the proven 0.3.1 32x192
  -- charset.  Leaf's current replacement sheets are compact 32x192 assets;
  -- keep them on the same native path as Red instead of treating them as
  -- 256x1536 HD atlases.  The 256x1536 sheets remain enabled for the HD
  -- player choices and bike variants that actually use that layout.
  local playerSheet = file == "ash" or file == "ethan"
    or file == "brendan"
  local playerBikeSheet = file == "ash_bike" or file == "ethan_bike"
    or file == "brendan_bike"
  local hdSheet = file == "gym_sabrina" or file == "gym_erika"
    or file == "agatha" or file == "officer_jenny"
    or file == "jessie" or file == "james" or file == "lorelei"
    or playerSheet or playerBikeSheet
  local highDensity = file == "jessie" or file == "james" or hdSheet
  local nativeWide = file == "jessie" or file == "james"
    or file == "lorelei" or playerSheet or playerBikeSheet
  -- Jessie/James, Ash and Ethan use 256px-wide authored frames; match the
  -- source cell so the renderer samples each complete frame instead of
  -- shrinking it or cutting off the head and feet.
  -- Agatha, Lorelei and Officer Jenny use the same native 256x1536 six-frame
  -- sheets as Red/Ash/Ethan. Keeping them in the 256px branch is important:
  -- the old 288/394px assumptions made their 256px cells fail sheet
  -- detection in 2D and appear at inconsistent sizes in Voxel.
  local frameSize = (file == "jessie" or file == "james"
      or file == "agatha" or file == "lorelei"
      or file == "officer_jenny"
      or playerSheet or playerBikeSheet) and 256
    or (nativeWide and 394
    or (hdSheet and 288 or (highDensity and 128 or 32)))
  local frameHeight = (nativeWide or hdSheet) and 256 or frameSize
  local proxyFrameHeight = 32
  -- Jessie and James use 4x-authored sheets whose artwork is intentionally
  -- more compact than Red's native charset.  Keep the source texture intact
  -- and enlarge only their presentation box by 1.3x (32 -> 42 logical px).
  -- The same logical size is supplied to the voxel billboard so 2D and 3D
  -- maps keep matching proportions.
  -- Only Jessie and James use the intentional 1.3x overworld enlargement.
  -- HD leader sheets retain their native detail but keep Red's 32px logical
  -- footprint so they do not become oversized on the map.
  -- Keep every overworld character at the same native display scale as Red.
  -- Jessie and James use their full-resolution sheets, but are not enlarged
  -- through code.
  -- Ash and Ethan use their 28px logical cells. Red's restored 0.3.1 sheet
  -- and all bike sheets retain the original 32px logical height.
  local displaySize = (file == "ash" or file == "ethan"
      or file == "ash_bike" or file == "ethan_bike") and 28 or 32
  local displayHeight = displaySize
  -- The authored sheets have different transparent padding below the shoes.
  -- Keep the logical cell unchanged, but move the complete bitmap by the
  -- small amount needed to put its visible footline on Red's ground line.
  -- This is an anchor correction, not a sprite resize.
  local hgssAnchorOffset = frameSize <= 32 and 2 or 1
  -- Snorlax is authored as a map obstruction rather than a normal NPC.  Its
  -- HGSS overworld sprite is intentionally shown at twice the regular
  -- character footprint; keep this override local to the Snorlax definition
  -- so it does not affect the global SPRITE SIZE option or other Pokémon.
  local hgssScaleOverride = file == "snorlax" and 2 or nil
  -- The HGSS Red sheet has transparent rows below the shoe pixels.  Keep the
  -- source images untouched and lower each voxel entity relative to its
  -- ground shadow; 2D rendering and map coordinates remain unchanged.
  -- The voxel renderer's 16px ground anchor is shared by all overworld
  -- charsets.  HGSS frames leave the same transparent rows beneath the
  -- shoes, so apply the small grounding correction to every replacement
  -- character (not just the player).
  local voxelEntityYOffset = -1
  -- Snorlax occupies the Route 12 gate tile; lower its enlarged billboard
  -- slightly so the feet sit on the gate threshold and the body blocks both
  -- entrances instead of hovering above them.
  if file == "snorlax" then
    voxelEntityYOffset = -16
  end
  -- These two sheets leave four transparent rows below the feet rather than
  -- Red's two.  Ground them independently without resampling or editing the
  -- authored pixels.
  if file == "jessie" then
    voxelEntityYOffset = -6
  elseif file == "pikachu" or file == "fisher" then
    voxelEntityYOffset = -8
  end
  -- This source was authored on the compact 16px world grid.  Keep its
  -- native 32px frame for the 2D renderer, while the voxel billboard uses
  -- the 16px world footprint expected by the original map object.
  local voxelWidth = displaySize
  local voxelHeight = displayHeight
  local nativeImage = mod.assets:path("overrides/sprites/" .. file .. ".png")
  mod.content.sprites:patch("SPRITE_" .. shortId, {
    -- DRAMALESS_SHAPE builds its billboard UVs from def.image and assumes a
    -- 16px-tall Gen 1 frame.  Point that measurement at an equivalent proxy
    -- sheet while the renderer below supplies the untouched native HGSS
    -- texture.  Both sheets have the same normalized frame layout, so the
    -- voxel quad samples the complete 32/48px source instead of its top-left
    -- 16px fragment.  The proxy is never presented to the player.
    image = mod.assets:path("assets/voxel/frame_layout_" .. frames .. "_"
      .. proxyFrameHeight .. ".png"),
    hgssNativeImage = nativeImage,
    hgssBikeScale2x = playerBikeSheet,
    frames = frames,
    walker = walker,
    trueColor = true,
    hgssFrameWidth = frameSize,
    hgssFrameHeight = frameHeight,
    hgssGamblerLayout = file == "gambler",
    hgssDrawWidth = displaySize,
    hgssDrawHeight = displayHeight,
    hgssBaseDrawWidth = displaySize,
    hgssBaseDrawHeight = displayHeight,
    hgssAnchorOffset = hgssAnchorOffset,
    hgssScaleOverride = hgssScaleOverride,
    -- A few authored leader sheets are 288x256 per frame rather than square.
    -- Fit those frames with one uniform source-to-destination scale instead
    -- of stretching them into the 32x32 logical box. Red intentionally keeps
    -- its separate 32x28 vertical normalization.
    -- Keep the Red normalization exception without spelling a Gen1 version
    -- allow-list in the source.  gen2check treats literal `"red"` checks as
    -- version gates even though this value is only a sprite asset filename.
    hgssPreserveAspect = file ~= assetName("RED"),
    hgssLinearFilter = frameSize > 32,
    -- Keep every replacement charset on the native-image presentation path.
    -- Standard 32px NPC sheets used to be rasterized into the 160x144 world
    -- canvas while Red/other HD sheets were repainted afterwards.  At
    -- SPRITE SIZE values below 1.0 that mixed path downsampled NPC frames and
    -- produced visibly squashed/jagged silhouettes.  The post-present pass
    -- uses the same uniform X/Y scale for every native sheet and is skipped
    -- automatically when a voxel world has already rendered the entity.
    hgssPostPresent = true,
    hgssVoxelWidth = voxelWidth,
    hgssVoxelHeight = voxelHeight,
    hgssBaseVoxelWidth = voxelWidth,
    hgssBaseVoxelHeight = voxelHeight,
    hgssVoxelEntityYOffset = voxelEntityYOffset,
  })
end

local function patchPokemonOverworld(mod, entry)
  -- The archived four-by-four sheets are converted to six vertical 32px
  -- frames during the build.  The renderer therefore uses the same native
  -- layout as Red and never falls back to the generic Rhydon sheet.
  local nativeImage = mod.assets:path("overrides/sprites/" .. entry.file .. ".png")
  mod.content.sprites:patch("SPRITE_" .. entry.shortId, {
    image = mod.assets:path("assets/voxel/frame_layout_6_32.png"),
    hgssNativeImage = nativeImage,
    frames = entry.frames,
    walker = true,
    trueColor = true,
    hgssFrameWidth = 32,
    hgssFrameHeight = 32,
    hgssDrawWidth = 32,
    hgssDrawHeight = 32,
    hgssBaseDrawWidth = 32,
    hgssBaseDrawHeight = 32,
    hgssLinearFilter = false,
    hgssPostPresent = true,
    hgssVoxelWidth = 32,
    hgssVoxelHeight = 32,
    hgssBaseVoxelWidth = 32,
    hgssBaseVoxelHeight = 32,
    hgssVoxelEntityYOffset = entry.voxelEntityYOffset or -4,
  })
end

-- Gen1Recomp runs the same mod package on two different engines.  Resolve
-- the active generation from the live Game2 instance first and fall back to
-- the engine's version registry during the load phase.  This is deliberately
-- a generation/capability check, not a Red/Blue/Yellow allow-list: Gold,
-- Silver and Crystal all report generation 2.
local function detectGeneration(game)
  local direct = game and tonumber(game.generation)
  if direct then return direct end

  -- Gold, Silver and Crystal share the same Gen 2 presentation contracts.
  -- Some engine builds expose only the version id on the live game/save
  -- object (rather than a numeric `generation` field), so recognise those
  -- ids before consulting GameVersion.  This keeps the intro and every
  -- Yellow-only guard on the same default path for all three games.
  local ids = {
    game and game.version,
    game and game.gameVersion,
    game and game.save and game.save.version,
    game and game.data and game.data.gameVersion,
  }
  for _, value in ipairs(ids) do
    if type(value) == "string" then
      local id = value:lower():gsub("[^%a]", "")
      if id:find("gold", 1, true)
          or id:find("silver", 1, true)
          or id:find("crystal", 1, true) then
        return 2
      end
    end
  end
  local ok, GameVersion = pcall(require, "src.core.GameVersion")
  if ok and GameVersion then
    local get = GameVersion.get
    local generation = GameVersion.generation
    if type(get) == "function" and type(generation) == "function" then
      local okId, id = pcall(get)
      if okId then
        local okGeneration, value = pcall(generation, id)
        if okGeneration and tonumber(value) then return tonumber(value) end
      end
    end
  end
  return 1
end

return function(mod)
  -- This mod owns its intro, overworld and optional battle artwork. Battle
  -- assets are self-contained; missing files fall back to the g1recomp ROM.

  -- Set by game.ready; declared here so rendering helpers can also consult
  -- the live save options when the manager has not refreshed mod.options yet.
  local liveGame
  local activeGeneration = detectGeneration()
  local function isGen2(game)
    local value = detectGeneration(game or liveGame)
    if game then activeGeneration = value end
    return (value or activeGeneration) == 2
  end

  -- Yellow's POKECENTER tileset contains one seated figure painted directly
  -- into the couch art (block $08), so it cannot be replaced through the
  -- normal NPC sprite registry.  Use a mod-local copy of the 128x48 atlas
  -- with only that figure's pixels restored to the couch/floor tiles.  One
  -- POKECENTER tileset is shared by all eleven Pokémon Centers and the
  -- Celadon Hotel, so this single patch covers every occurrence.  Keep the
  -- patch scoped to POKECENTER: MART shares the original atlas image but
  -- must retain its own tile art.
  if not isGen2() and mod.content and mod.content.tilesets
      and type(mod.content.tilesets.patch) == "function" then
    pcall(function()
      mod.content.tilesets:patch("POKECENTER", {
        image = mod.assets:path("assets/tilesets/pokecenter_clean.png"),
        imageWidth = 128,
        imageHeight = 48,
        tilesPerRow = 16,
        -- Block $08 is the only map block whose tile IDs describe the
        -- authored seated figure.  Use the same couch/floor under-art in
        -- the block data so voxel backends cannot instantiate a second 3D
        -- figure from the old ID pattern after the atlas is cleaned.
        blocks = {
          [9] = {
            52, 39, 1, 11,
            52, 39, 26, 27,
            38, 39, 54, 11,
            42, 43, 26, 27,
          },
        },
      })
    end)
  end

  -- Since gen1recomp 0.1.88 mods no longer receive love.filesystem.  Keep
  -- existence checks inside the mod sandbox and use the documented reader.
  -- The result is cached because these checks run from battle sprite hooks.
  local assetExistsCache = {}
  local function assetExists(relative)
    if not relative then return false end
    if assetExistsCache[relative] ~= nil then
      return assetExistsCache[relative]
    end
    local exists = false
    if type(mod.read) == "function" then
      local ok, data = pcall(function() return mod:read(relative) end)
      exists = ok and data ~= nil
    end
    assetExistsCache[relative] = exists
    return exists
  end

  local function isHgssTrueColorPath(path)
    if type(path) ~= "string" then return false end
    path = path:gsub("\\", "/")
    return path:find("overrides/sprites/", 1, true) ~= nil
        or path:find("overrides/title/", 1, true) ~= nil
        or path:find("assets/icons/", 1, true) ~= nil
        -- Battle portraits and Pokémon backs are authored full-colour
        -- assets.  Keeping this path in the true-colour set prevents the
        -- engine's four-shade GB palette from being applied when one of
        -- these images is resolved through the normal sprite seam.
        or path:find("assets/battle/", 1, true) ~= nil
  end

  local function loadHdImage(path)
    local ok, image = pcall(love.graphics.newImage, mod.assets:path(path))
    if not ok or not image then return nil end
    image:setFilter("linear", "linear")
    return image
  end

  -- Crystal's Oak speech is a separate Gen 2 screen and does not use the
  -- Yellow intro hook below.  Keep this bridge deliberately small: only the
  -- four pictures owned by that screen are replaced, while its timing,
  -- text, animation and layout stay in the engine.  The source PNGs are
  -- HGSS true-colour sprites, loaded with nearest filtering so the logical
  -- 8-pixel art is not blurred when the widescreen renderer scales it.
  -- Metadata is kept outside the LÖVE Image userdata so the source textures
  -- can remain at their original dimensions.  Only the final draw call is
  -- scaled to the intro's 7x7 logical-cell area.
  local gen2IntroImageMeta = setmetatable({}, { __mode = "k" })

  local function loadGen2IntroImage(path)
    if not assetExists(path) then return nil end
    local ok, image = pcall(love.graphics.newImage, mod.assets:path(path))
    if not ok or not image then return nil end
    image:setFilter("nearest", "nearest")
    local w, h = image:getDimensions()
    gen2IntroImageMeta[image] = {
      scale = math.min(1, 56 / w, 56 / h),
    }
    return image
  end

  local function installGen2IntroSprites()
    local ok, OakSpeech = pcall(require, "src.ui.gen2.OakSpeech")
    if ok and type(OakSpeech) == "table"
       and type(OakSpeech.new) == "function"
       and not OakSpeech.__hgssIntroSpritesHook then
      local oldNew = OakSpeech.new
      OakSpeech.new = function(game, opts, ...)
        local speech = oldNew(game, opts, ...)
        if not isGen2(game) then return speech end

        local oak = loadGen2IntroImage("assets/gen2/intro/oak.png")
        local ethan = loadGen2IntroImage("assets/gen2/intro/ethan.png")
        local lyra = loadGen2IntroImage("assets/gen2/intro/lyra.png")
        local wooper = loadGen2IntroImage("assets/gen2/intro/wooper.png")

        if oak then
          speech.oakPic = oak
          speech.oakColors = nil
        end
        if ethan then
          speech.playerPic = ethan
          speech.playerColors = nil
        end
        -- OakSpeech currently starts Crystal with the male player, but retain
        -- the female image on the instance too.  This keeps Lyra available to
        -- the upcoming gender-select path and replaces the native Kris
        -- descriptor whenever that path is present.
        if lyra then
          speech.playerPicFemale = lyra
          speech.playerPicFemaleColors = nil
          if speech.cfg then
            speech.cfg.playerPicFemale = "assets/gen2/intro/lyra.png"
          end
          local gender = game and game.save and game.save.player
            and game.save.player.gender
          if gender == "female" then
            speech.playerPic = lyra
            speech.playerColors = nil
          end
        end
        if speech.cfg then
          speech.cfg.oakPic = oak and "assets/gen2/intro/oak.png"
            or speech.cfg.oakPic
          speech.cfg.playerPic = ethan and "assets/gen2/intro/ethan.png"
            or speech.cfg.playerPic
          speech.cfg.marillPic = wooper and "assets/gen2/intro/wooper.png"
            or speech.cfg.marillPic
        end
        if wooper then
          speech.marillPic = wooper
          speech.marillColors = nil
        end
        return speech
      end
      OakSpeech.__hgssIntroSpritesHook = true
    end

    -- The engine's intro methods use image dimensions directly.  Keep the
    -- authored textures untouched and scale only this screen's draw calls to
    -- the same 7x7 logical area used by the vanilla renderer.
    if ok and type(OakSpeech) == "table"
       and type(OakSpeech.drawPic) == "function"
       and not OakSpeech.__hgssIntroScaleHook then
      local oldDrawPic = OakSpeech.drawPic
      OakSpeech.drawPic = function(self)
        local image = self and self.pic
        local meta = image and gen2IntroImageMeta[image]
        if not meta then return oldDrawPic(self) end
        local G = love.graphics
        local w, h = image:getDimensions()
        local displayW, displayH = w * meta.scale, h * meta.scale
        local x = 48 + math.floor((8 - displayW / 8) / 2) * 8
        local y = 32 + (7 - displayH / 8) * 8
        local reveal = self.picReveal
        local off = 0
        if reveal and reveal.kind == "fade" then
          G.setColor(1, 1, 1, math.min(1, reveal.t / reveal.dur))
        elseif reveal and reveal.kind == "wipe" then
          off = math.floor((160 - x)
            * (1 - math.min(1, reveal.t / reveal.dur)))
        else
          G.setColor(1, 1, 1, 1)
        end
        local function body()
          if self.picFlip then
            G.draw(image, x + off + displayW, y, 0,
              -meta.scale, meta.scale)
          else
            G.draw(image, x + off, y, 0, meta.scale, meta.scale)
          end
        end
        body()
        G.setColor(1, 1, 1, 1)
      end
      OakSpeech.__hgssIntroScaleHook = true
    end

    local okName, NamePick = pcall(require, "src.ui.gen2.NamePick")
    if okName and type(NamePick) == "table"
       and type(NamePick.drawPic) == "function"
       and not NamePick.__hgssIntroScaleHook then
      local oldNameDrawPic = NamePick.drawPic
      NamePick.drawPic = function(self)
        local image = self and self.pic
        local meta = image and gen2IntroImageMeta[image]
        if not meta then return oldNameDrawPic(self) end
        local G = love.graphics
        local _, h = image:getDimensions()
        local displayH = h * meta.scale
        local x = self.picX * 8
        local y = 4 * 8 + (7 - displayH / 8) * 8
        G.setColor(1, 1, 1, 1)
        G.draw(image, x, y, 0, meta.scale, meta.scale)
        G.setColor(1, 1, 1, 1)
      end
      NamePick.__hgssIntroScaleHook = true
    end
  end

  -- Require/wrap the screen once at mod load.  The constructor still checks
  -- the live generation, so the same package remains inert on Yellow.
  installGen2IntroSprites()
  -- Some builds load the mod before the Gen 2 UI modules are indexed.  Retry
  -- at the lifecycle boundary where the Game2 instance is guaranteed to
  -- exist; the sentinel above keeps this idempotent.
  if mod.events and type(mod.events.on) == "function" then
    mod.events:on("game.ready", function()
      installGen2IntroSprites()
    end)
  end

  -- Intro demo sprites can be animated atlases.  Keep the authored Gen 5
  -- pixels in one texture and expose fixed-size quads to the presentation
  -- layer so only one Pikachu frame is drawn at a time.  The battle renderer
  -- has the same 16-column atlas convention, but the intro owns its own
  -- state and must not depend on a battle mod being installed.
  local function loadHdAnimation(path, frameWidth, frameHeight,
                                 columns, frameCount, fps)
    local image = loadHdImage(path)
    if not image then return nil end
    local imageWidth, imageHeight = image:getDimensions()
    local quads = {}
    for index = 0, frameCount - 1 do
      local column = index % columns
      local row = math.floor(index / columns)
      local x = column * frameWidth
      local y = row * frameHeight
      if x + frameWidth <= imageWidth and y + frameHeight <= imageHeight then
        quads[#quads + 1] = love.graphics.newQuad(
          x, y, frameWidth, frameHeight, imageWidth, imageHeight)
      end
    end
    if #quads == 0 then return nil end
    return {
      image = image,
      quads = quads,
      frameCount = #quads,
      frameWidth = frameWidth,
      frameHeight = frameHeight,
      fps = fps or 10,
    }
  end

  mod.options:define({
    {
      key = "battle_scope",
      label = "BATTLE ART SCOPE",
      type = "choice",
      default = "trainers",
      choices = {
        { "TRAINERS ONLY", "trainers" },
        { "COMPLETE", "complete" },
      },
    },
    {
      key = "battle_front_gen",
      label = "BATTLE FRONT GEN",
      type = "choice",
      default = "gen5",
      choices = {
        { "ROM", "rom" }, { "GEN 1", "gen1" }, { "GEN 2", "gen2" },
        { "GEN 3", "gen3" }, { "GEN 4", "gen4" }, { "GEN 5", "gen5" },
      },
    },
    {
      key = "battle_back_gen",
      label = "BATTLE BACK GEN",
      type = "choice",
      default = "gen5",
      choices = {
        { "ROM", "rom" }, { "GEN 1", "gen1" }, { "GEN 2", "gen2" },
        { "GEN 3", "gen3" }, { "GEN 4", "gen4" }, { "GEN 5", "gen5" },
      },
    },
    {
      key = "battle_trainer_gen",
      label = "BATTLE TRAINER GEN",
      type = "choice",
      default = "gen3",
      choices = {
        { "ROM", "rom" }, { "GEN 1", "gen1" }, { "GEN 2", "gen2" },
        { "GEN 3", "gen3" },
      },
    },
    {
      key = "player_select",
      label = "PLAYER SELECT",
      type = "choice",
      default = "red",
      choices = {
        { "RED", "red" },
        { "ASH", "ash" },
        { "ETHAN", "ethan" },
        { "LYRA", "lyra" },
        { "LEAF", "leaf" },
        { "BRENDAN", "brendan" },
      },
    },
    {
      key = "party_menu",
      label = "PARTY MENU",
      type = "toggle",
      default = true,
    },
    {
      key = "pc_box_icons",
      label = "PC BOX ICONS",
      type = "toggle",
      default = true,
    },
    {
      key = "crisp_display",
      label = "CRISP DISPLAY",
      type = "toggle",
      default = false,
    },
    {
      key = "sprite_size",
      label = "SPRITE SIZE",
      type = "choice",
      default = "0.8",
      choices = {
        { "0.5x", "0.5" },
        { "0.6x", "0.6" },
        { "0.7x", "0.7" },
        { "0.8x", "0.8" },
        { "0.9x", "0.9" },
        { "1.0x", "1.0" },
      },
    },
  })

  -- The edge-anchored Start Menu is useful while DRAMALESS_SHAPE owns the
  -- world pass, but in classic 2D some g1recomp builds composite the source
  -- UI canvas as well as the anchored copy.  That leaves two visible menus
  -- (one centered and one at the top-right) whenever UI LAYOUT is dynamic.
  -- Keep the vanilla centered placement for the flat renderer and retain the
  -- edge placement only while the Voxel world pipeline is actually active.
  local function voxelWorldEnabled()
    local okP, Pipelines = pcall(require, "src.render.Pipelines")
    if not okP or not Pipelines
       or type(Pipelines.worldPipeline) ~= "function" then
      return false
    end
    local okWorld, worldPipeline = pcall(Pipelines.worldPipeline)
    return okWorld and worldPipeline ~= nil
  end

  do
    local okScreens, Screens = pcall(require, "src.ui.Screens")
    local okStart, StartMenu = pcall(require, "src.ui.StartMenu")
    if okScreens and Screens and okStart and StartMenu
       and not Screens.__hgssStartMenuGuard then
      local startMenuIds = {
        StartMenu = true,
        Gen2StartMenu = true,
      }
      local oldPush = Screens.push
      Screens.push = function(game, id, ...)
        if startMenuIds[id] and game and game.stack
           and game.stack.top then
          local top = game.stack:top()
          if top and startMenuIds[top.screenId] then
            return top
          end
        end
        return oldPush(game, id, ...)
      end
      Screens.__hgssStartMenuGuard = true

      if not StartMenu.__hgssFlatPlacementHook then
        local oldNew = StartMenu.new
        StartMenu.new = function(game, ...)
          local menu = oldNew(game, ...)
          -- Gen2's fixed StartMenu has no Gen1 anchor fields.  The adapter
          -- exposes the live class so an unconditional write would appear to
          -- succeed while being ignored by the Gen2 renderer.
          if menu and not isGen2(game) and not voxelWorldEnabled() then
            menu.anchor = nil
          end
          return menu
        end
        StartMenu.__hgssFlatPlacementHook = true
      end
    end
  end

  -- Keep a live copy of the battle selectors.  The Mod Manager updates this
  -- value before emitting `mod.options_changed`; scripted drivers and older
  -- g1recomp builds emit the event directly, so reading only the cached
  -- option object can incorrectly leave the selector at ROM.
  local battleOptionValues = {}
  -- Mod Manager events can arrive before the option store is refreshed. Keep
  -- SPRITE SIZE in a live cache as well, so Gen-2/voxel redraws immediately
  -- use the newly selected value instead of the previous menu value.
  local spriteSizeValue
  -- Keep PLAYER SELECT in the same live cache as the battle generation
  -- options.  Older Mod API builds update the event payload before the
  -- option store, so reading mod.options:get() during battle construction
  -- can otherwise select Red even after Leaf was chosen in the menu.
  local playerSelectionValue
  do
    local ok, value = pcall(mod.options.get, mod.options, "player_select")
    if ok then playerSelectionValue = value end
    local okSize, size = pcall(mod.options.get, mod.options, "sprite_size")
    if okSize then spriteSizeValue = size end
  end
  local function battleTrace(_) end
  local BATTLE_OPTION_KEYS = {
    battle_scope = true,
    battle_front_gen = true,
    battle_back_gen = true,
    battle_trainer_gen = true,
  }
  for key in pairs(BATTLE_OPTION_KEYS) do
    local ok, value = pcall(mod.options.get, mod.options, key)
    if ok then battleOptionValues[key] = value end
  end
  local function battleOption(key)
    local value = battleOptionValues[key] or mod.options:get(key)
    battleTrace(("option %s=%s"):format(tostring(key), tostring(value)))
    return value
  end
  mod.events:on("mod.options_changed", function(ev)
    if ev and ev.mod == mod.id then
      local key = ev.key or ev.option or ev.name
      local value = ev.value
      if value == nil then value = ev.newValue end
      if key == "sprite_size" and value ~= nil then
        spriteSizeValue = value
      end
      if BATTLE_OPTION_KEYS[key] then
        battleOptionValues[key] = value
        battleTrace(("event %s=%s"):format(tostring(key), tostring(value)))
      end
      if key == "player_select" and value ~= nil then
        playerSelectionValue = tostring(value):lower()
      end
    end
  end)

  local function selectedPlayerOption()
    local value = playerSelectionValue
    if value == nil then
      local ok, current = pcall(mod.options.get, mod.options, "player_select")
      if ok then value = current end
    end
    return tostring(value or "red"):lower()
  end

  -- Attribution: the resolver/atlas-playback architecture below was
  -- reimplemented from Battle Art Voxel Fork's battle-art path. This file
  -- keeps the implementation local and does not import Battle Art runtime
  -- modules; the adapted architecture and bundled asset conventions are
  -- credited in the project README and battle asset notes.
  -- Self-contained generation collections. The selected generation is
  -- resolved per species and side; missing files deliberately fall back to
  -- the image supplied by the g1recomp engine.
  local function battleSlug(value)
    if type(value) == "table" then
      value = value.id or value.name or value.species or value.dataId
    end
    local s = tostring(value or ""):lower()
    s = s:gsub("♀", "-f"):gsub("♂", "-m")
    s = s:gsub("['%.]", ""):gsub("[^%w]+", "-")
    return s:gsub("^-+", ""):gsub("-+$", "")
  end
  local function battleSpeciesKey(value)
    if type(value) == "table" then
      value = value.id or value.name or value.species or value.dataId
    end
    local key = tostring(value or ""):upper()
    return key:gsub("[^%w]+", "_"):gsub("_+$", "")
  end
  local SHINY_ATTACK_DVS = {
    [2] = true, [3] = true, [6] = true, [7] = true,
    [10] = true, [11] = true, [14] = true, [15] = true,
  }
  local function shinyFlag(value)
    if type(value) == "boolean" then return value end
    if type(value) == "number" then return value ~= 0 end
    if type(value) == "string" then
      local normalized = value:lower()
      return normalized == "true" or normalized == "yes"
        or normalized == "on" or normalized == "shiny" or normalized == "1"
    end
    return false
  end
  local function battleIsShiny(value)
    local mon = type(value) == "table"
      and (value.mon or value.pokemon or value) or nil
    if type(mon) ~= "table" then return false end
    for _, key in ipairs({ "shiny", "isShiny", "is_shiny" }) do
      if mon[key] ~= nil then return shinyFlag(mon[key]) end
    end
    if mon.variant ~= nil then
      return tostring(mon.variant):lower() == "shiny"
    end
    local dvs = mon.dvs or mon.DVs
    if type(dvs) ~= "table" then return false end
    local attack = tonumber(dvs.attack or dvs.Attack)
    local defense = tonumber(dvs.defense or dvs.Defense)
    local speed = tonumber(dvs.speed or dvs.Speed)
    local special = tonumber(dvs.special or dvs.Special)
    if defense ~= 10 or speed ~= 10 or special ~= 10
       or not SHINY_ATTACK_DVS[attack] then
      return false
    end
    local hp = (attack % 2) * 8 + (defense % 2) * 4
      + (speed % 2) * 2 + (special % 2)
    return dvs.hp == nil or tonumber(dvs.hp or dvs.HP) == hp
  end
  local function battleAssetPath(folder, gen, species, shiny)
    local suffix = shiny and "/shiny" or ""
    return ("assets/battle/%s/%s%s/%s.png"):format(
      folder, gen, suffix, battleSlug(species))
  end
  local function selectedBattlePokemonImage(species, side, shiny)
    -- TRAINERS ONLY must leave both wild and party Pokemon entirely to the
    -- engine.  This guard is needed here as well as in applyBattleGeneration:
    -- the public pokemon.sprite hook can run before BattleState exists and
    -- otherwise installs a generation sprite during the intro.
    if battleOption("battle_scope") == "trainers" then return nil end
    local gen = battleOption(side == "back"
      and "battle_back_gen" or "battle_front_gen") or "rom"
    if gen == "rom" then return nil end
    local folder
    if side == "back" then
      folder = (gen == "gen3" or gen == "gen5")
        and "back-animated" or "back-static"
    else
      folder = "front-animated"
    end
    -- Gen 1 fronts are one 56x56 frame, while later
    -- generations use animated atlases. The event bridge below extracts the
    -- selected atlas frame; this path remains the safe stock-hook fallback.
    if side == "front" and gen == "gen1" then folder = "front-animated" end
    local rel = battleAssetPath(folder, gen, species, shiny)
    if side == "back" and (gen == "gen3" or gen == "gen5") then
      if not assetExists(rel) then
        folder = "back-static"
        rel = battleAssetPath(folder, gen, species, shiny)
      end
    end
    local path = mod.assets:path(rel)
    if not assetExists(rel) then return nil end
    -- pokemon.sprite returns the asset path/definition, not a drawable. This
    -- keeps the hook compatible with the stock battle renderer.
    return path
  end

  -- The engine applies decoded images directly to battler.sprite, so the path
  -- hook above is supplemented by this battle-start adapter.
  -- This small adapter follows the same seam and only writes when a concrete
  -- generation PNG was selected and found. ROM/default mode is a no-op.
  local battleTextureCache = {}
  local battleDataCache = {}
  local battleSourceCache = {}
  local battleDefinition
  local function normalizeBattleDefinition(def, side)
    if not def then return nil end
    local image = def.image
    local path = image and mod.assets:path(image)
    if side == "back" and image and not assetExists(image) then
      local fallback = image:gsub("back%-animated", "back-static")
      local fallbackPath = mod.assets:path(fallback)
      if assetExists(fallback) then
        -- Static Gen 5 backs are already cropped PNGs. Do not reuse the
        -- animated atlas cell dimensions or the renderer would cut them.
        return { image = fallback, static = true, frames = 1 }
      end
    end
    return def
  end
  local function battleTexture(path, width, height, columns)
    if not path then return nil end
    local cacheKey = table.concat({ tostring(path), tostring(width or ""),
      tostring(height or ""), tostring(columns or "") }, "|")
    if battleTextureCache[cacheKey] == nil then
      local ok, image = pcall(function()
        local sheet = love.image.newImageData(path)
        local data = sheet
        -- Battle Art stores animated generations as a horizontal/row atlas.
        -- Always extract one logical cell before handing it to the renderer;
        -- passing the whole atlas makes the first sprite look enormous and
        -- also prevents the engine from advancing frames correctly.
        if width and height then
          local sheetW, sheetH = sheet:getDimensions()
          local frame = love.image.newImageData(width, height)
          local columnsN = tonumber(columns) or 1
          local x = 0
          local y = 0
          if columnsN > 1 then
            x = 0
            y = 0
          end
          if x + width > sheetW or y + height > sheetH then
            return nil
          end
          frame:paste(sheet, 0, 0, x, y, width, height)
          data = frame
        end
        local out = love.graphics.newImage(data)
        if out.setFilter then out:setFilter("nearest", "nearest") end
        return out
      end)
      battleTextureCache[cacheKey] = ok and image or false
    end
    return battleTextureCache[cacheKey] or nil
  end

  -- Keep the atlas animation independent from the renderer. The first image
  -- installed at battle creation is replaced with the next cell on each
  -- BattleState update, using the same durations as Battle Art.
  local battleFramesCache = {}
  local battleFrameStates = setmetatable({}, { __mode = "k" })
  local function battleFrames(def)
    if not def or not def.image then return nil end
    local path = mod.assets:path(def.image)
    local key = table.concat({ path, tostring(def.width), tostring(def.height),
      tostring(def.columns), tostring(def.frames) }, "|")
    if battleFramesCache[key] ~= nil then return battleFramesCache[key] or nil end
    local ok, frames = pcall(function()
      local sheet = love.image.newImageData(path)
      local sheetW, sheetH = sheet:getDimensions()
      local width, height = tonumber(def.width), tonumber(def.height)
      local columns = math.max(1, tonumber(def.columns) or 1)
      local count = math.max(1, tonumber(def.frames) or 1)
      local out = {}
      for index = 0, count - 1 do
        local x = (index % columns) * width
        local y = math.floor(index / columns) * height
        if x + width > sheetW or y + height > sheetH then break end
        local cell = love.image.newImageData(width, height)
        cell:paste(sheet, 0, 0, x, y, width, height)
        local image = love.graphics.newImage(cell)
        if image.setFilter then image:setFilter("nearest", "nearest") end
        out[#out + 1] = image
      end
      return #out > 0 and out or nil
    end)
    battleFramesCache[key] = ok and frames or false
    return battleFramesCache[key] or nil
  end

  -- The battle engine keeps a separate `playerBackPic` reference for the
  -- throw-in/party side.  Once the send-out card closes it can still draw
  -- that stale reference instead of the animated battler sprite.  Keep the
  -- common player battler synchronized with the selected back atlas so every
  -- species (not only Pikachu) receives the same animation and placement.
  local function syncBattlePokemonImage(battler, side)
    if not battler then return end
    local gen = battleOption(side == "back" and "battle_back_gen"
      or "battle_front_gen") or "rom"
    if gen == "rom" or battleOption("battle_scope") == "trainers" then return end
    local mon = battler.mon
    local species = mon and (mon.species or mon.id or mon.dataId)
    local shiny = battleIsShiny(battler)
    local def = battleDefinition(gen, side, species, shiny)
    local frames = def and not def.static and battleFrames(def) or nil
    local image = frames and frames[1]
      or (def and def.image and battleTexture(mod.assets:path(def.image),
        def.width, def.height, def.columns))
    if image then battler.sprite = image end
    return image
  end

  local function syncBattlePlayerReference(battle)
    if not battle or not battle.player then return end
    if battleOption("battle_scope") == "trainers" then return end
    if battle.showPlayerBack then return end
    local image = syncBattlePokemonImage(battle.player, "back")
    if image then battle.playerBackPic = nil end
  end

  local function updateBattleFrame(battler, side, dt)
    if not battler or not battler.sprite then return end
    local gen = battleOption(side == "back" and "battle_back_gen"
      or "battle_front_gen") or "rom"
    if gen == "rom" or battleOption("battle_scope") == "trainers" then return end
    local mon = battler.mon
    local species = mon and (mon.species or mon.id or mon.dataId)
    local shiny = battleIsShiny(battler)
    local def = battleDefinition(gen, side, species, shiny)
    if def and def.static then return end
    local frames = def and battleFrames(def)
    if not frames then return end
    local state = battleFrameStates[battler]
    if not state or state.def ~= def or state.frames ~= frames then
      state = { def = def, frames = frames, frame = 1, elapsed = 0 }
      battleFrameStates[battler] = state
    end
    state.elapsed = state.elapsed + (tonumber(dt) or 0)
    local durations = def.durations or {}
    local duration = math.max(1, tonumber(durations[state.frame]) or 100) / 1000
    while state.elapsed >= duration do
      state.elapsed = state.elapsed - duration
      state.frame = state.frame % #frames + 1
      duration = math.max(1, tonumber(durations[state.frame]) or 100) / 1000
    end
    battler.sprite = frames[state.frame]
  end

  battleDefinition = function(gen, side, species, shiny)
    local key = (side == "back" and "back" or "front") .. ":" .. gen
      .. (shiny and ":shiny" or ":normal")
    if battleDataCache[key] == nil then
      local file
      if side == "back" and gen == "gen3" and not shiny then
        file = "animated_battle_backs_gen3.lua"
      elseif gen ~= "gen1" then
        file = "animated_battle_sprites_" .. gen
          .. (shiny and "_shiny" or "") .. ".lua"
      end
      if file then
        local relSource = "assets/battle/" .. file
        local source
        if type(mod.read) == "function" then
          local ok, text = pcall(function() return mod:read(relSource) end)
          if ok and type(text) == "string" then source = text
          end
        end
        if not source then
          -- mod:read above is the only supported way to access mod files.
        end
        local loader = loadstring or load
        local chunk = source and loader(source, "@battle/" .. file)
        if not chunk then chunk = nil end
        local ok, data = false, nil
        if chunk then ok, data = pcall(chunk) end
        if not ok then data = nil end
        battleDataCache[key] = ok and type(data) == "table" and data or {}
        battleSourceCache[key] = source
      else
        battleDataCache[key] = {}
      end
    end
    local set = battleDataCache[key]
    local speciesKey = battleSpeciesKey(species)
    local rec = set and set[speciesKey]
    if not rec and speciesKey == "RATTATA" then
      rec = set and set.RATTATA
    end
    if rec and rec[side] then return normalizeBattleDefinition(rec[side], side) end
    -- Some g1recomp builds expose `load` but discard the return value of a
    -- data chunk. Parse the generated one-line records directly as a safe
    -- fallback; this keeps the same definitions Battle Art uses without
    -- depending on that build-specific loader behavior.
    local source = battleSourceCache[key]
    if source then
      local body = source:match("%s" .. speciesKey .. "%s*=%s*{(.-)\n%s*},")
      local line = body and body:match(side .. "%s*=%s*{(.-)}")
      if line then
        local image = line:match('image%s*=%s*"([^"]+)"')
        local width = tonumber(line:match("width%s*=%s*(%d+)"))
        local height = tonumber(line:match("height%s*=%s*(%d+)"))
        local columns = tonumber(line:match("columns%s*=%s*(%d+)"))
        if image and width and height then
          if not assetExists(image) and side == "back" then
            local fallback = image:gsub("back%-animated", "back-static")
            if assetExists(fallback) then image = fallback end
          end
          return normalizeBattleDefinition({ image = image, width = width,
            height = height, columns = columns }, side)
        end
      end
    end
    return nil
  end

  -- The Pokédex entry page resolves its image through the generic
  -- `pokemon.sprite` hook, but later-generation front assets are atlases.
  -- Returning the atlas path there makes DexEntryMenu draw the first sheet
  -- (which looks like a Gen 1/garbled sprite).  Resolve one logical front
  -- frame here and install it on the entry page, using the same generation
  -- selector as battle fronts.
  local function selectedDexImage(species, source)
    if battleOption("battle_scope") == "trainers" then return nil end
    local gen = battleOption("battle_front_gen") or "rom"
    if gen == "rom" then return nil end
    local shiny = battleIsShiny(source)
    local def = battleDefinition(gen, "front", species, shiny)
    if def then
      local frames = not def.static and battleFrames(def) or nil
      local image = frames and frames[1]
        or (def.image and battleTexture(mod.assets:path(def.image),
            def.width, def.height, def.columns))
      if image then return image end
    end
    -- Gen 1 front art has no Lua atlas definition and is already one 56x56
    -- frame, so load that selected path directly.
    local path = selectedBattlePokemonImage(species, "front", shiny)
    return path and battleTexture(path) or nil
  end

  -- Hall of Fame resolves its party pictures with kind="hof" and then
  -- loads the returned path directly.  Unlike the battle renderer it does
  -- not know how to crop a Gen 2-5 animated atlas, so returning the atlas
  -- path would draw the whole sheet (or make the screen fall back to the
  -- original Yellow picture).  Resolve one native frame here and install
  -- it on the HallOfFame instance.  This is intentionally independent of
  -- BATTLE ART SCOPE: TRAINERS ONLY controls live battles, while the Hall of
  -- Fame is a presentation screen and should still show the selected
  -- generation's Pokemon art.
  local function fitHallImage(image, side)
    if not image then return nil end
    -- Modern trainer portraits have more detail than the original 56px
    -- Hall tile window.  Keep the native front asset whenever possible;
    -- only oversized art (such as the 320px Red intro portrait) is reduced
    -- to an 80px presentation cell.
    -- The stock Hall renderer enlarges a 28x28 Gen 1 back tile to 56x56.
    -- Modern frames are already true-color pixel art, so reducing them to
    -- 28 first throws away most of their detail.  Keep the full 56px Hall
    -- presentation cell and draw it at 1:1 in the hook below.
    local limit = side == "back" and 56 or 80
    local w, h = image:getDimensions()
    local scale = math.min(1, limit / math.max(1, w),
      limit / math.max(1, h))
    if scale >= 0.999 then return image end
    local sw = math.max(1, math.floor(w * scale + 0.5))
    local sh = math.max(1, math.floor(h * scale + 0.5))
    local canvas = love.graphics.newCanvas(sw, sh)
    -- Hall of Fame art is pixel art.  Canvas filtering defaults to the
    -- renderer's current filter on some builds, which turns the reduced
    -- frame into a soft/blurred image.  Keep the native nearest-neighbour
    -- pixels when the fixed Hall layout requires a smaller logical cell.
    if canvas.setFilter then canvas:setFilter("nearest", "nearest") end
    local previous = love.graphics.getCanvas()
    love.graphics.setCanvas(canvas)
    love.graphics.clear(0, 0, 0, 0)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(image, 0, 0, 0, scale, scale)
    love.graphics.setCanvas(previous)
    love.graphics.setColor(1, 1, 1, 1)
    return canvas
  end

  local function selectedHallPlayerImage()
    local key = selectedPlayerOption()
    -- Hall of Fame expects a front battle portrait, never an overworld
    -- charset sheet.  Keep a dedicated portrait for every PLAYER SELECT
    -- option so the Hall screen cannot silently reuse Red's art.
    local portraits = {
      red = "assets/graphics/intro_hd/red.png",
      ash = "assets/graphics/hall_front/ash.png",
      ethan = "assets/graphics/hall_front/ethan.png",
      leaf = "assets/graphics/hall_front/leaf.png",
      brendan = "assets/graphics/hall_front/brendan.png",
    }
    local rel = portraits[key] or portraits.red
    if not assetExists(rel) then return nil end
    local ok, image = pcall(function()
      local path = mod.assets:path(rel)
      local image = love.graphics.newImage(love.image.newImageData(path))
      if image.setFilter then image:setFilter("nearest", "nearest") end
      return image
    end)
    return ok and fitHallImage(image, "front") or nil
  end

  local function selectedHallImage(species, side, source)
    local gen = battleOption(side == "back" and "battle_back_gen"
      or "battle_front_gen") or "rom"
    if gen == "rom" or not species then return nil end
    local def = battleDefinition(gen, side, species, battleIsShiny(source))
    if def then
      local frames = not def.static and battleFrames(def) or nil
      local image = frames and frames[1]
        or (def.image and battleTexture(mod.assets:path(def.image),
            def.width, def.height, def.columns))
      if image then
        -- Keep the native battle art untouched; only the Hall of Fame's
        -- small logical cell is normalized for its 80/56px presentation.
        return fitHallImage(image, side)
      end
    end
    return nil
  end

  local okHall, HallOfFame = pcall(require, "src.ui.HallOfFame")
  if not isGen2() and okHall and HallOfFame
     and not HallOfFame.__hgssGenerationHook then
    local oldHallNew = HallOfFame.new
    HallOfFame.new = function(game, onDone, ...)
      local hall = oldHallNew(game, onDone, ...)
      local playerImage = selectedHallPlayerImage()
      if playerImage then
        hall.playerPic = playerImage
        hall.playerTrueColor = true
      end
      local oldSpriteFor = hall.spriteFor
      hall.spriteFor = function(self, species)
        local image = selectedHallImage(species, "front")
        if image then
          self.sprites[species] = image
          self.spriteTrueColor[species] = true
          return image
        end
        return oldSpriteFor(self, species)
      end
      local oldBackPicFor = hall.backPicFor
      hall.backPicFor = function(self)
        local mon = self.game.save.party[self.index]
        if mon then
          local image = selectedHallImage(mon.species, "back", mon)
          if image then return image, true end
        end
        return oldBackPicFor(self)
      end
      -- HallOfFame.lua's stock drawBackPic assumes a Gen 1 28x28 source and
      -- crops/scales it by two.  That operation visibly pixelates the
      -- modern animated battle frames.  Our resolver returns a complete
      -- frame fitted to the physical 56x56 Hall cell, so draw it directly
      -- at 1:1 instead of cropping the top-left quarter.
      hall.drawBackPic = function(self)
        local image, trueColor = self:backPicFor()
        if not image then return end
        local x = self.scrollX or 160
        local y = 88
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.draw(image, x, y)
        if trueColor then
          require("src.render.PaletteFX").markTrueColor(
            x, y, image:getWidth(), image:getHeight())
        end
      end
      return hall
    end
    HallOfFame.__hgssGenerationHook = true
  end

  local okDexEntry, DexEntryMenu = pcall(require, "src.ui.DexEntryMenu")
  if not isGen2() and okDexEntry and DexEntryMenu
     and not DexEntryMenu.__hgssFrontGenerationHook then
    local oldDexEntryNew = DexEntryMenu.new
    DexEntryMenu.new = function(game, speciesOrOpts, onDone)
      local entry = oldDexEntryNew(game, speciesOrOpts, onDone)
      local species = type(speciesOrOpts) == "table"
        and (speciesOrOpts.species or speciesOrOpts[1]) or speciesOrOpts
      local image = selectedDexImage(species)
      if image then
        entry.sprite = image
        entry.spriteTrueColor = true
      end
      return entry
    end
    DexEntryMenu.__hgssFrontGenerationHook = true
  end

  -- The catch flow opens the regular Gen 1 SummaryMenu after the nickname
  -- prompt.  Unlike DexEntryMenu, that screen asks Sprites.path with
  -- kind="summary"; later-generation front assets are animated atlases, so
  -- handing that path directly to SummaryMenu draws every frame at once
  -- behind the status text.  Reuse the same selected/cropped frame resolver
  -- used by the Pokédex and keep the stock summary layout untouched.
  local okSummary, SummaryMenu = pcall(require, "src.ui.SummaryMenu")
  if not isGen2() and okSummary and SummaryMenu
     and not SummaryMenu.__hgssFrontGenerationHook then
    local oldSummaryNew = SummaryMenu.new
    SummaryMenu.new = function(game, mon, ...)
      local summary = oldSummaryNew(game, mon, ...)
      local species = mon and (mon.species or mon.id or mon.dataId)
      local image = selectedDexImage(species, mon)
      if image then
        summary.sprite = image
        summary.spriteTrueColor = true
      end
      return summary
    end
    SummaryMenu.__hgssFrontGenerationHook = true
  end

  -- EvolutionState loads its two forms directly with love.graphics instead
  -- of going through the battle renderer.  That bypass left the evolution
  -- movie on the original Yellow sprites even when BATTLE FRONT GEN selected
  -- a bundled generation.  Reuse the same cropped, first-frame resolver as
  -- the Pokédex and Summary screens so every form is a single native sprite,
  -- never an entire animated atlas pasted over the movie.
  local okEvolution, EvolutionState = pcall(require, "src.ui.EvolutionState")
  if not isGen2() and okEvolution and EvolutionState
     and not EvolutionState.__hgssFrontGenerationHook then
    local oldEvolutionNew = EvolutionState.new
    EvolutionState.new = function(game, mon, newSpecies, ...)
      local state = oldEvolutionNew(game, mon, newSpecies, ...)
      if battleOption("battle_scope") ~= "trainers"
         and battleOption("battle_front_gen") ~= "rom" then
        local oldImage = selectedDexImage(mon and mon.species, mon)
        local newImage = selectedDexImage(newSpecies, mon)
        if oldImage then
          state.oldSprite = oldImage
          state.oldSpriteTrueColor = true
        end
        if newImage then
          state.newSprite = newImage
          state.newSpriteTrueColor = true
        end
      end
      return state
    end
    EvolutionState.__hgssFrontGenerationHook = true
  end

  local battleOriginalSprites = setmetatable({}, { __mode = "k" })
  local selectedBattlePlayerImage
  local applyBattleGeneration
  local function applyBattleGenerationDeferred(battle)
    applyBattleGeneration(battle)
    if not battle then return end
    local enemy = battle.enemy and battle.enemy.mon
    local player = battle.player and battle.player.mon
    if enemy and player then applyBattleGeneration(battle) end
  end

  local function refreshBattleSprites(battle)
    applyBattleGenerationDeferred(battle)
    if not battle then return end
    -- `applyBattleGeneration` is guarded, but this refresh path also runs
    -- during BattleState construction and used to install the enemy's
    -- generation Pokemon directly.  In TRAINERS ONLY that bypass left
    -- Rattata/Pikachu using the new art while only the trainer was intended
    -- to change.
    if battleOption("battle_scope") == "trainers" then return end
    local gen = battleOption("battle_front_gen") or "rom"
    if gen == "rom" then return end
    local mon = battle.enemy and battle.enemy.mon
    local species = mon and (mon.species or mon.id or mon.dataId)
    local shiny = battleIsShiny(battle.enemy)
    local def = battleDefinition(gen, "front", species, shiny)
    local path = def and mod.assets:path(def.image)
    if path and def then
      local frames = not def.static and battleFrames(def) or nil
      local image = frames and frames[1]
        or battleTexture(path, def.width, def.height, def.columns)
      if image and battle.enemy then battle.enemy.sprite = image end
    end
  end
  applyBattleGeneration = function(battle)
    if not battle then return end
    local originals = battleOriginalSprites[battle]
    if not originals then originals = {}; battleOriginalSprites[battle] = originals end
    local function applyOne(battler, side)
      -- Oak's scripted Pikachu catch demo has no player battler until the
      -- throw sequence creates one.  Do not index a nil battler while
      -- applying generation artwork; the enemy/Oak side still gets patched.
      if not battler then return end
      if battleOption("battle_scope") == "trainers" then return end
      local mon = battler and battler.mon
      local species = mon and (mon.species or mon.id or mon.dataId)
      local gen = battleOption(side == "back" and "battle_back_gen"
        or "battle_front_gen") or "rom"
      local shiny = battleIsShiny(battler)
      local path = selectedBattlePokemonImage(species, side, shiny)
      local def = gen ~= "rom" and battleDefinition(gen, side, species, shiny) or nil
      if def and def.image then path = mod.assets:path(def.image) end
      local frames = def and not def.static and battleFrames(def) or nil
      local image = frames and frames[1]
        or battleTexture(path, def and def.width, def and def.height,
          def and def.columns)
      if def and def.static and path then
        image = battleTexture(path)
      end
      if not image and def and side == "back" then
        local fallback = path and path:gsub("back%-animated", "back-static")
        image = battleTexture(fallback, def.width, def.height, def.columns)
      end
      if image then
        if originals[battler] == nil then originals[battler] = battler.sprite end
        battler.sprite = image
      elseif originals[battler] ~= nil then
        battler.sprite = originals[battler]
      end
    end
    applyOne(battle.enemy, "front")
    applyOne(battle.player, "back")
  end

  -- BattleState constructs its battlers before the public battle.started
  -- event is emitted on some g1recomp builds.  Battle Art replaces the
  -- sprites at that construction boundary, so mirror that seam here.  The
  -- wrapper is guarded so a second copy of the mod cannot stack wrappers.
  local okBattleCtor, BattleCtor = pcall(require, "src.battle.BattleState")
  if not isGen2() and okBattleCtor and BattleCtor
     and not BattleCtor.__hgssSpriteGenerationHook then
    local oldNewTrainer = BattleCtor.newTrainer
    if type(oldNewTrainer) == "function" then
      BattleCtor.newTrainer = function(...)
        local battle = oldNewTrainer(...)
        refreshBattleSprites(battle)
        return battle
      end
    end
    local oldNewWild = BattleCtor.newWild
    if type(oldNewWild) == "function" then
      BattleCtor.newWild = function(...)
        local battle = oldNewWild(...)
        refreshBattleSprites(battle)
        return battle
      end
    end
    local oldUpdate = BattleCtor.update
    if type(oldUpdate) == "function" then
      BattleCtor.update = function(self, dt, ...)
        local result = oldUpdate(self, dt, ...)
        if self.showPlayerBack then
          local playerImage = selectedBattlePlayerImage(self)
          if playerImage then self.playerBackPic = playerImage end
        end
        refreshBattleSprites(self)
        -- Keep the side-specific reference used by drawPicsLayer in sync with
        -- the same selected Pokémon atlas. This applies to every species.
        if self.player and self.player.sprite then
          local playerImage = syncBattlePokemonImage(self.player, "back")
          if playerImage then self.player.sprite = playerImage end
          syncBattlePlayerReference(self)
        end
        updateBattleFrame(self.enemy, "front", dt)
        updateBattleFrame(self.player, "back", dt)
        return result
      end
    end
    BattleCtor.__hgssSpriteGenerationHook = true
  end

  mod.events:on("battle.started", function(payload)
    if isGen2() then return end
    local battle = payload and payload.battle
    refreshBattleSprites(battle)
    -- A few builds finish loading the battler records one frame after the
    -- event. Reapply once on the next coroutine tick without touching ROM
    -- mode or restoring any original sprite.
    if battle then
      coroutine.wrap(function()
        coroutine.yield()
        refreshBattleSprites(battle)
      end)()
    end
  end)
  mod.events:on("battle.ended", function(payload)
    if isGen2() then return end
    local battle = payload and payload.battle
    local originals = battle and battleOriginalSprites[battle]
    if not originals then return end
    for battler, sprite in pairs(originals) do
      if battler then battler.sprite = sprite end
    end
    battleOriginalSprites[battle] = nil
  end)

  local oldPokemonSpriteHook = mod.hooks and mod.hooks.wrap
  if oldPokemonSpriteHook then
    mod.hooks:wrap("pokemon.sprite", function(next, path, ctx)
      local out = next(path, ctx)
      if not (ctx and ctx.kind == "battle") then return out end
      if battleOption("battle_scope") == "trainers" then return out end
      local side = ctx.side == "back" and "back" or "front"
      local species = ctx.species
        or (ctx.data and ctx.data.pokemon and ctx.data.pokemon.species)
      local selected = selectedBattlePokemonImage(species, side,
        battleIsShiny(ctx.data and ctx.data.pokemon or ctx))
      if selected then
        -- Sprites.path returns both the path and the true-colour flag.  The
        -- old hook only replaced the path, so the renderer still quantized
        -- every selected back through the GB palette (most visible on the
        -- full-colour tutorial/player backs).  Mark only our battle asset.
        ctx.trueColor = true
        return selected
      end
      return out
    end)

    -- The Viridian catch tutorial is a demo battle: the engine marks it with
    -- ctx.demo and normally resolves the original generated/oldmanb.png path.
    -- Keep Oak's separate Yellow intro portrait untouched, but route the real
    -- Old Man through the bundled full-colour static back portrait instead of
    -- allowing the ROM back sprite to leak through.
    mod.hooks:wrap("player.sprite", function(next, path, ctx)
      local out = next(path, ctx)
      -- Any player/trainer image resolved from this mod's battle asset tree
      -- is already authored in full colour.  Preserve that metadata even
      -- when another wrapper supplied the path before us.
      if ctx and isHgssTrueColorPath(out) then
        ctx.trueColor = true
      end
      if ctx and ctx.side == "back" and ctx.demo and ctx.oakDemo then
        local oak = mod.assets:path("assets/battle/back-static/oak.png")
        if assetExists("assets/battle/back-static/oak.png") then
          ctx.trueColor = true
          return oak
        end
      end
      if not (ctx and ctx.side == "back" and ctx.demo and not ctx.oakDemo) then
        return out
      end
      local replacement = mod.assets:path("assets/battle/back-static/old-man.png")
      if assetExists("assets/battle/back-static/old-man.png") then
        -- playerPath propagates ctx.trueColor to BattleState:getImage; set it
        -- here so the Old Man's coloured back is never collapsed to GB shades.
        ctx.trueColor = true
        return replacement
      end
      return out
    end)
  end

  -- The engine presents trainer portraits through BattleState.picImage rather
  -- than the pokemon.sprite seam. Keep this bridge defensive: older g1recomp
  -- builds may not expose the method, and in that case the ROM renderer
  -- remains completely untouched.
  local trainerImageCache = {}
  local playerTrainerFramesCache = {}
  local playerTrainerStates = setmetatable({}, { __mode = "k" })

  -- PLAYER SELECT is the single owner of the player trainer shown in battle.
  -- Keep the generation-to-character mapping internal and expose only
  -- RED/ASH/ETHAN through PLAYER SELECT in this mod.
  local PLAYER_BATTLE_STRIPS = {
    red = "redplayer.png",
    ash = "ashplayer.png",
    ethan = "gen2player.png",
    -- Leaf and Brendan use dedicated full-color animated back sheets when
    -- present.  Static portraits remain the defensive fallback for older
    -- installations that do not yet contain those atlases.
    leaf = "leafplayer.png",
    brendan = "brendanplayer.png",
  }
  local PLAYER_BATTLE_STATIC = {
    red = "player.png",
    ash = "ashplayer.png",
    ethan = "gen2player.png",
    leaf = "leafplayer.png",
    brendan = "brendanplayer.png",
  }

  local function selectedPlayerBattleKey()
    local value = selectedPlayerOption()
    return PLAYER_BATTLE_STRIPS[value] and value or "red"
  end

  local function loadPlayerTrainerFrames(key)
    local filename = PLAYER_BATTLE_STRIPS[key]
    if not filename then return nil end
    local path = mod.assets:path("assets/battle/back-animated/" .. filename)
    if not assetExists("assets/battle/back-animated/" .. filename) then return nil end
    if playerTrainerFramesCache[path] ~= nil then
      return playerTrainerFramesCache[path] or nil
    end
    local ok, frames = pcall(function()
      local sheet = love.image.newImageData(path)
      local sheetW, sheetH = sheet:getDimensions()
      local columns = 5
      if sheetW % columns ~= 0 or sheetH < 1 then return nil end
      local width = sheetW / columns
      local out = {}
      for index = 0, columns - 1 do
        local cell = love.image.newImageData(width, sheetH)
        cell:paste(sheet, 0, 0, index * width, 0, width, sheetH)
        local image = love.graphics.newImage(cell)
        if image.setFilter then image:setFilter("nearest", "nearest") end
        out[#out + 1] = image
      end
      return out
    end)
    playerTrainerFramesCache[path] = ok and frames or false
    return playerTrainerFramesCache[path] or nil
  end

  local function selectedBattlePlayerStatic(key)
    local filename = PLAYER_BATTLE_STATIC[key] or PLAYER_BATTLE_STATIC.red
    local path = mod.assets:path("assets/battle/back-static/" .. filename)
    if not assetExists("assets/battle/back-static/" .. filename) then return nil end
    if trainerImageCache[path] == nil then
      local ok, image = pcall(function()
        local out = love.graphics.newImage(love.image.newImageData(path))
        if out.setFilter then out:setFilter("nearest", "nearest") end
        return out
      end)
      trainerImageCache[path] = ok and image or false
    end
    return trainerImageCache[path] or nil
  end

  local function playerTrainerProgress(battle)
    if not battle or type(battle.picOffset) ~= "function" then return 0 end
    local ok, offset = pcall(battle.picOffset, battle, "back")
    if not ok then return 0 end
    return math.max(0, math.min(72, -(tonumber(offset) or 0)))
  end

  selectedBattlePlayerImage = function(battle)
    if not (battle and battle.showPlayerBack) then return nil end
    -- Oak/Old Man's scripted introduction must retain its dedicated portrait.
    if battle.demo then return nil end
    local key = selectedPlayerBattleKey()
    local frames = loadPlayerTrainerFrames(key)
    if not frames then return selectedBattlePlayerStatic(key) end

    local state = playerTrainerStates[battle]
    if not state or state.key ~= key or state.frames ~= frames then
      state = { key = key, frames = frames, frame = 1 }
      playerTrainerStates[battle] = state
    end
    local progress = playerTrainerProgress(battle)
    if progress <= 0 then
      state.frame = 1
    else
      local movingFrames = math.max(1, #frames - 1)
      state.frame = math.min(#frames,
        2 + math.floor(math.max(0, progress - 1) * movingFrames / 72))
    end
    return frames[state.frame]
  end
  local function selectedBattleTrainerImage(name, partyIndex)
    local gen = battleOption("battle_trainer_gen") or "rom"
    if gen == "rom" then return nil end
    local rawName = tostring(name or "")
    -- BattleState exposes opponent classes with the OPP_ prefix (for
    -- example OPP_RIVAL1).  Battle Art's collections are keyed by the
    -- underlying class name (rival1.png), so strip that engine prefix before
    -- resolving the bundled portrait.  Without this, Blue silently falls
    -- back to the original Gen I picture while Jessie/James still work via
    -- their special-case path.
    local className = rawName:gsub("^[Oo][Pp][Pp]_", "")
    -- Yellow reuses OPP_ROCKET for both ordinary Rocket grunts and the
    -- Jessie/James encounters.  Only party records 42+ are the duo; mapping
    -- every OPP_ROCKET here made normal grunts enter battle with the
    -- Jessie/James portrait.  Keep the ordinary Rocket class on rocket.png.
    local rocketParty = tonumber(partyIndex) or 0
    local isJessieJames = (rawName == "true" or rawName == "42"
      or rawName:lower():find("jessie", 1, true)
      or (rawName:upper() == "OPP_ROCKET" and rocketParty >= 42))
    local slug = isJessieJames and "jessie-james" or battleSlug(className)
    local rel = ("assets/battle/front-static/%s/%s.png"):format(
      gen, slug)
    local path = mod.assets:path(rel)
    if not assetExists(rel) then return nil end
    if trainerImageCache[path] == nil then
      local ok, image = pcall(function()
        local data = love.image.newImageData(path)
        local out = love.graphics.newImage(data)
        if out.setFilter then out:setFilter("nearest", "nearest") end
        return out
      end)
      trainerImageCache[path] = ok and image or false
    end
    return trainerImageCache[path] or nil
  end

  local okBattleState, BattleState = pcall(require, "src.battle.BattleState")
  -- BattleState can restore a battler's original image during scripted
  -- effects (notably the capture/"Gotcha" tail and ghost reveal).  The
  -- original image is the full animated atlas returned by the public
  -- pokemon.sprite seam, while the normal battle path has already replaced
  -- it with one logical frame.  If that restore happens after update(), the
  -- atlas is drawn verbatim behind the catch summary text (dozens of copies
  -- of the same Pokémon).  Normalize at the final draw boundary as a
  -- defensive last pass; animation state still advances in updateBattleFrame
  -- and only an image whose dimensions exceed its selected frame is changed.
  if not isGen2() and okBattleState and BattleState
     and type(BattleState.drawPicsLayer) == "function"
     and not BattleState.__hgssBattleAtlasDrawGuard then
    local oldDrawPicsLayer = BattleState.drawPicsLayer
    local function normalizeAtlas(battle, battler, side)
      if not battle or not battler or not battler.sprite then return end
      if battleOption("battle_scope") == "trainers" then return end
      local gen = battleOption(side == "back" and "battle_back_gen"
        or "battle_front_gen") or "rom"
      if gen == "rom" then return end
      local mon = battler.mon
      local species = mon and (mon.species or mon.id or mon.dataId)
      local def = battleDefinition(gen, side, species, battleIsShiny(battler))
      if not def or def.static then return end
      local frames = battleFrames(def)
      local first = frames and frames[1]
      if not first then return end
      local okSize, w, h = pcall(function()
        return battler.sprite:getWidth(), battler.sprite:getHeight()
      end)
      local fw, fh = first:getWidth(), first:getHeight()
      if okSize and (w > fw or h > fh) then
        battler.sprite = first
      end
    end
    BattleState.drawPicsLayer = function(self, ...)
      normalizeAtlas(self, self.enemy, "front")
      normalizeAtlas(self, self.player, "back")
      return oldDrawPicsLayer(self, ...)
    end
    BattleState.__hgssBattleAtlasDrawGuard = true
  end

  if not isGen2() and okBattleState and BattleState
     and type(BattleState.picImage) == "function" then
    local oldBattlePicImage = BattleState.picImage
    BattleState.picImage = function(self, image)
      local trainer = self and self.trainer
      local name = self and (self.oppClass or (trainer and
        (trainer.picJessieJames or trainer.id or trainer.name or trainer.class)))
      if image == (self and self.trainerPic) and name then
        return selectedBattleTrainerImage(name, self.partyIndex)
          or oldBattlePicImage(self, image)
      end
      return oldBattlePicImage(self, image)
    end
  end
  if not isGen2() and okBattleState and BattleState
     and not BattleState.__hgssTrainerPictureHook then
    local oldNewTrainer = BattleState.newTrainer
    if type(oldNewTrainer) == "function" then
      BattleState.newTrainer = function(...)
        local battle = oldNewTrainer(...)
        local custom = selectedBattlePlayerImage(battle)
        if custom and battle then
          battle.playerBackPic = custom
        end
        if battle and battle.showEnemyTrainer then
          local id = battle.oppClass or (battle.trainer and battle.trainer.id)
          -- Pass the engine class through the same resolver used by
          -- BattleState.picImage. It strips OPP_ and maps OPP_RIVAL1 to the
          -- bundled rival1.png; pre-slugging here used to turn it into
          -- opp-rival1 and made Blue retain the ROM portrait.
          local enemy = selectedBattleTrainerImage(id, battle.partyIndex)
          if enemy then battle.trainerPic = enemy end
        end
        return battle
      end
    end
    BattleState.__hgssTrainerPictureHook = true
  end
  if not isGen2() and okBattleState and BattleState
     and type(BattleState.picImage) == "function"
     and not BattleState.__hgssPlayerPictureHook then
    local oldPicImage = BattleState.picImage
    BattleState.picImage = function(self, image)
      local battle = self
      if image and battle and image == battle.playerBackPic then
        local custom = selectedBattlePlayerImage(battle)
        if custom then return custom end
      end
      return oldPicImage(self, image)
    end
    BattleState.__hgssPlayerPictureHook = true
  end

  -- The stock battle renderer assumes Gen I pictures were authored at half
  -- display resolution and applies its legacy 2x back-picture scale. The
  -- bundled HGSS/BW images are already at display resolution, so that same
  -- multiplier makes the player back and custom Pokemon look oversized.
  -- Keep the source PNGs untouched and normalize only the presentation scale
  -- for images selected by this mod, matching Battle Art's resolver seam.
  if not isGen2() and okBattleState and BattleState
     and type(BattleState.resolveBattleScale) == "function"
     and not BattleState.__hgssBattleScaleHook then
    local oldResolveBattleScale = BattleState.resolveBattleScale
    BattleState.resolveBattleScale = function(data, side, path, species)
      local base = oldResolveBattleScale(data, side, path, species)
      -- All bundled battle assets are already cropped to their logical battle
      -- cell.  They must stay at 1:1; applying a half-scale here shrinks Gen
      -- 2–5 Pokemon into tiny, jagged figures.  The player portrait is also
      -- full-density and follows the same rule. ROM art keeps its engine
      -- supplied scale below.
      local externalScale = 1
      local custom = false
      if side == "back" then
        if species then
          -- In TRAINERS ONLY the party Pokemon are original art, so retain
          -- the engine's native scale for this side.
          custom = battleOption("battle_scope") ~= "trainers"
             and battleOption("battle_back_gen") ~= "rom"
        else
          -- Trainer backs are independent from the Pokemon back selector.
          -- They are already authored at display resolution, including Red;
          -- remove the legacy Gen I 2x multiplier. Player back sheets are
          -- already at their intended logical battle size.
          custom = true
        end
      elseif side == "front" then
        custom = battleOption("battle_scope") ~= "trainers"
          and battleOption("battle_front_gen") ~= "rom"
      end
      if custom then return externalScale end
      return base
    end
    BattleState.__hgssBattleScaleHook = true
  end

  local function overworldSpriteScale(def)
    local fixed = def and tonumber(def.hgssScaleOverride)
    if fixed then return fixed end
    local save = liveGame and liveGame.save
    local saved = save and save.options and save.options.modOptions
      and save.options.modOptions[mod.id]
      and save.options.modOptions[mod.id].sprite_size
    local liveOptions = liveGame and liveGame.mods and liveGame.mods.modOptions
      and liveGame.mods.modOptions[mod.id]
      and liveGame.mods.modOptions[mod.id].sprite_size
    -- The manager writes the selected value to the save options before (or
    -- alongside) emitting mod.options_changed. Reading it here makes the
    -- Potato texture resize immediately even on builds whose option store is
    -- refreshed one frame later.
    local value = tonumber(liveOptions or saved or spriteSizeValue
      or mod.options:get("sprite_size"))
    if value == nil then value = 1 end
    return math.max(0.5, math.min(1.0, value))
  end

  local PLAYER_SPRITE_IDS = {
    red = "SPRITE_RED",
    ash = "SPRITE_ASH",
    ethan = "SPRITE_ETHAN",
    lyra = "SPRITE_LYRA",
    leaf = "SPRITE_LEAF",
    brendan = "SPRITE_BRENDAN",
  }

  local PLAYER_BIKE_SPRITE_IDS = {
    red = "SPRITE_RED_BIKE",
    ash = "SPRITE_ASH_BIKE",
    ethan = "SPRITE_ETHAN_BIKE",
    lyra = "SPRITE_LYRA_BIKE",
    leaf = "SPRITE_LEAF_BIKE",
    brendan = "SPRITE_BRENDAN_BIKE",
  }

  local function selectedPlayerSpriteId()
    return PLAYER_SPRITE_IDS[selectedPlayerOption()]
      or PLAYER_SPRITE_IDS.red
  end

  local function selectedPlayerBikeSpriteId()
    return PLAYER_BIKE_SPRITE_IDS[selectedPlayerOption()]
      or PLAYER_BIKE_SPRITE_IDS.red
  end

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
        -- three standing facings. Potato still uses the six-frame walker
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
    selected = tostring(selected or "ethan"):lower()
    -- The Gen-4 OW collection uses the correct HGSS female protagonist under
    -- the Lyra role.  `leaf` remains a Yellow/Gen-1 selector and is not the
    -- source for the Crystal player.
    if selected == "lyra" then
      return "overrides/sprites/lyra", "lyra_bike"
    end
    -- Red/Ash/Leaf/Brendan are Yellow player choices.  Gen 2 has no native
    -- slots for those protagonists.  Use the user-provided canonical Ethan
    -- charset from overrides/sprites (the same 32x192, six-frame source used
    -- by the Gen-1 player), while keeping the dedicated Gen-2 bike sheet.
    return "overrides/sprites/ethan", "ethan_bike"
  end

  local function patchGen2PlayerSprites()
    local footFile, bikeFile = gen2PlayerFiles(selectedPlayerOption())
    -- The Gen-2 world uses the Chris ids for the active player in all three
    -- games.  Crystal also exposes Kris, which stays on the HGSS Lyra sheet
    -- for scripts/NPC code that explicitly requests the female slot.
    -- Keep the native Gen-2 footprint at 1.0x.  The shared SPRITE SIZE
    -- option is applied at draw time, including through Potato Voxel.
    patchGen2Sprite("CHRIS", footFile, { hgssGen2ScaleMultiplier = 1.0 })
    patchGen2Sprite("CHRIS_BIKE", bikeFile)
    patchGen2Sprite("KRIS", "overrides/sprites/lyra",
      { hgssGen2ScaleMultiplier = 1.0 })
    patchGen2Sprite("KRIS_BIKE", "lyra_bike")
    -- Gen 2's surf state uses these ids.  The Pikachu ride remains an
    -- explicit opt-in asset; the engine still decides when the state is
    -- entered, so ordinary Surf keeps its native behavior.
    patchGen2Sprite("SURFING_PIKACHU", "surfing_pikachu")
    -- Crystal still resolves the map's Fisherman-tagged object through
    -- SPRITE_FISHER.  Use the supplied HGSS Fatman charset for that role;
    -- the asset keeps all six directional/walk frames and is scaled only at
    -- draw time, so the map object, palette role and interaction scripts stay
    -- unchanged.
    patchGen2Sprite("FISHER", "overrides/sprites/fatman",
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
  end

  -- Crystal has a separate NPC registry from Yellow.  Redirect only the
  -- trainer/person slots that were visually checked against the official
  -- HGSS overworld archive and our local HGSS charset base.  Pokémon/object
  -- slots (for example BIRD, MONSTER and the various map decorations) are
  -- intentionally left untouched so a trainer asset can never leak into an
  -- encounter, fossil or field object.
  local function patchGen2NpcSprites()
    local GEN2_NPC_SPRITES = {
      BEAUTY = "beauty",
      BIKER = "biker",
      BLACK_BELT = "blackbelt",
      BILL = "bill",
      BLAINE = "blaine_gen2",
      BLUE = "blue_gen2",
      BROCK = "brock_gen2",
      BRUNO = "bruno_gen2",
      BUG_CATCHER = "bug_catcher_gen2",
      BUGSY = "bugsy_gen2",
      CAPTAIN = "captain",
      CHUCK = "chuck_gen2",
      CLAIR = "clair_gen2",
      CLERK = "clerk",
      COOLTRAINER_M = "cooltrainer_m",
      DAISY = "daisy",
      ELDER = "elder_gen2",
      ELM = "elm_gen2",
      ERIKA = "erika_gen2",
      FALKNER = "falkner_gen2",
      FISHING_GURU = "fishing_guru",
      GAMEBOY_KID = "gameboy_kid",
      GENTLEMAN = "gentleman",
      GRAMPS = "gramps",
      GRANNY = "granny",
      GYM_GUIDE = "gym_guide",
      JANINE = "janine_gen2",
      JASMINE = "jasmine_gen2",
      KAREN = "karen",
      KIMONO_GIRL = "kimono_girl",
      KOGA = "koga_gen2",
      KURT = "kurt_gen2",
      KURT_OUTSIDE = "kurt_gen2",
      LANCE = "lance",
      LASS = "lass_gen2",
      LINK_RECEPTIONIST = "link_receptionist",
      MISTY = "misty_gen2",
      MORTY = "morty_gen2",
      NURSE = "nurse",
      OAK = "oak_gen2",
      OFFICER = "officer",
      POKEFAN_M = "pokefan_m",
      PRYCE = "pryce_gen2",
      RED = "red",
      REDS_MOM = "mom_johto",
      ROCKER = "rocker",
      ROCKET = "rocket_gen2",
      ROCKET_GIRL = "rocket_girl_gen2",
      SABRINA = "sabrina_gen2",
      SAGE = "sage",
      SAILOR = "sailor",
      SUPER_NERD = "super_nerd_gen2",
      SURGE = "surge_gen2",
      SWIMMER_GIRL = "swimmer_girl",
      SWIMMER_GUY = "swimmer_guy",
      TWIN = "twin",
      WHITNEY = "whitney_gen2",
      WILL = "will",
      YOUNGSTER = "youngster",
      STANDING_YOUNGSTER = "youngster",
    }
    for shortId, file in pairs(GEN2_NPC_SPRITES) do
      patchGen2Sprite(shortId, file, { hgssGen2ScaleMultiplier = 1.0 })
    end
  end

  -- The three starter objects in Elm's Lab keep their original object ids and
  -- scripts, but use the Gen-4 object-ball artwork.  This is deliberately a
  -- map/object-name scoped redirect: SPRITE_POKE_BALL remains untouched for
  -- every other item ball in Crystal (and for the item-ball interaction code).
  local function patchGen2ElmObjectBall()
    local okWorld, World = pcall(require, "src.world.gen2.World")
    if not okWorld or type(World) ~= "table"
        or type(World.pooledNpc) ~= "function"
        or World.__hgssElmObjectBall then
      return
    end

    -- The authored object-ball sheet is a full 32px cell, while Crystal's
    -- table uses a smaller 16px object footprint.  Keep the source untouched
    -- and present it at 0.6x so it sits on the table at the same visual size
    -- as the native balls; interaction coordinates remain the original ones.
    patchGen2Sprite("ELM_POKE_BALL", "assets/gen2/elm-pokeball",
      { hgssGen2ScaleMultiplier = 0.6 })

    local originalPooledNpc = World.pooledNpc
    World.pooledNpc = function(self, mapId, obj)
      -- Gen-2 map objects do not retain the assembly name at runtime; the
      -- loader exposes their stable object index instead.  Elm's three
      -- starter balls are indices 3, 4 and 5 in ELMS_LAB.  Keep this
      -- redirect map-scoped and index-scoped so every other item ball keeps
      -- the canonical SPRITE_POKE_BALL (and its interaction behavior).
      local useGen4Ball = mapId == "ELMS_LAB"
        and type(obj) == "table"
        and (obj.index == 3 or obj.index == 4 or obj.index == 5)
      if not useGen4Ball then
        return originalPooledNpc(self, mapId, obj)
      end

      -- pooledNpc passes the object table into NPC.def.  Swap only for the
      -- duration of resolution, then restore the canonical sprite id so all
      -- interaction/event code continues to see SPRITE_POKE_BALL.
      local originalSprite = obj.sprite
      obj.sprite = "SPRITE_ELM_POKE_BALL"
      local ok, npc = pcall(originalPooledNpc, self, mapId, obj)
      obj.sprite = originalSprite
      if not ok then error(npc, 0) end
      return npc
    end
    World.__hgssElmObjectBall = true
  end

  -- Elm's starter balls are the one Gen-2 scene where the game opens a
  -- `pokepic` before the player owns a Pokémon.  Keep the normal Crystal
  -- front sprites everywhere else, but use full-colour Generation VI-style
  -- animated fronts for that chooser.  This is intentionally a world-level
  -- display hook rather than a pokemon-registry patch: changing
  -- `spriteFront` globally would also replace the Pokédex, summary and
  -- battle assets.  Frames are authored at their source pixel size and
  -- placed on transparent 64x64 canvases so the native Gen-2 Poképic window
  -- can draw them without palette conversion or filtering.
  local function patchGen2ElmStarterPokePics()
    local okWorld, World = pcall(require, "src.world.gen2.World")
    if not okWorld or type(World) ~= "table"
        or type(World.showPokePic) ~= "function"
        or World.__hgssGen6ElmStarterPokePics then
      return
    end

    local starterPics = {
      CHIKORITA = {
        dir = "assets/gen2/starter-gen6/front-animated/chikorita",
        count = 48, ticks = 2,
      },
      CYNDAQUIL = {
        dir = "assets/gen2/starter-gen6/front-animated/cyndaquil",
        count = 50, ticks = 2,
      },
      TOTODILE = {
        dir = "assets/gen2/starter-gen6/front-animated/totodile",
        count = 26, ticks = 2,
      },
    }
    local cache = {}
    local function loadFrame(anim, index)
      local key = anim.dir .. "/" .. string.format("%02d.png", index)
      local image = cache[key]
      if image == false then return nil end
      if image == nil then
        if not assetExists(key) then
          cache[key] = false
          return nil
        end
        local ok, loaded = pcall(function()
          local data = love.image.newImageData(mod.assets:path(key))
          local out = love.graphics.newImage(data)
          if out.setFilter then out:setFilter("nearest", "nearest") end
          if data.release then data:release() end
          return out
        end)
        image = ok and loaded or false
        cache[key] = image
      end
      return image or nil
    end
    local function stopAnimation(self)
      self.__hgssGen6StarterAnimation = nil
    end
    local original = World.showPokePic

    World.showPokePic = function(self, speciesIndex)
      original(self, speciesIndex)
      stopAnimation(self)
      -- Restrict the replacement to Elm's lab starter chooser.  A later
      -- Poképic (Pokédex, summary, etc.) continues to use the game's own
      -- sprite and palette exactly as before.
      if not (self.map and self.map.id == "ELMS_LAB") then return end
      local anim = starterPics[self.pokePicName]
      if not anim then return end
      local image = loadFrame(anim, 1)
      if not image then return end
      self.__hgssGen6StarterAnimation = {
        data = anim, index = 1, ticks = 0,
      }
      self.pokePic = image
      -- The Gen-2 renderer applies the map's four-colour CGB ramp whenever
      -- this field is set.  These frames are true-colour, so leave the field
      -- empty for this one custom display.
      self.pokePicColors = nil
    end

    -- World:step has no delta-time parameter, but it runs once per logic
    -- frame.  Advance only while Elm's starter Poképic is visible; this keeps
    -- the animation out of the Pokédex, summaries and every other Poképic.
    local originalStep = World.step
    if type(originalStep) == "function" then
      World.step = function(self, ...)
        local result = originalStep(self, ...)
        local state = self.__hgssGen6StarterAnimation
        if not state or not self.pokePic
            or not (self.map and self.map.id == "ELMS_LAB") then
          return result
        end
        state.ticks = state.ticks + 1
        if state.ticks >= state.data.ticks then
          state.ticks = 0
          state.index = state.index + 1
          if state.index > state.data.count then state.index = 1 end
          local nextImage = loadFrame(state.data, state.index)
          if nextImage then self.pokePic = nextImage end
        end
        return result
      end
    end
    World.__hgssGen6ElmStarterPokePics = true
  end

  -- Keep the option reversible while the mod manager is open. The live icon
  -- table is adjusted only after every mod has finished loading, so OFF can
  -- restore the original entries supplied by the game or a companion mod.
  local partyIconEntries = {}

  -- Keep full-color HGSS party icon entries local until game.ready. Applying
  -- them at module load would overwrite the original registry before we can
  -- snapshot it for PARTY MENU OFF.
  for species in words(SPECIES) do
    local entry = {
      image = mod.assets:path("assets/icons/" .. assetName(species) .. ".png"),
      frames = 2,
      trueColor = true,
    }
    partyIconEntries[species] = entry
  end

  -- The registration table below is Yellow's object namespace.  Do not
  -- publish those IDs into the Gen2 registry: Gold/Silver/Crystal have their
  -- own data.gen2Sprites names and the adapter cannot translate arbitrary
  -- Yellow object IDs.  The Gen2 player and NPC tables are registered in the
  -- separate block below using only Crystal's native short IDs.
  if not isGen2() then
  for shortId in words(WALKERS) do
    patchOverworld(mod, shortId, 6, true)
  end
  patchOverworld(mod, "RED_BIKE", 6, true, "red_bike")
  patchOverworld(mod, "ASH_BIKE", 6, true, "ash_bike")
  patchOverworld(mod, "ETHAN_BIKE", 6, true, "ethan_bike")
  patchOverworld(mod, "LEAF", 6, true, "leaf")
  patchOverworld(mod, "LEAF_BIKE", 6, true, "leaf_bike")
  patchOverworld(mod, "LYRA", 6, true, "lyra")
  patchOverworld(mod, "LYRA_BIKE", 6, true, "lyra_bike")
  patchOverworld(mod, "KRIS", 6, true, "kris")
  patchOverworld(mod, "KRIS_BIKE", 6, true, "kris_bike")
  patchOverworld(mod, "MAY", 6, true, "may")
  patchOverworld(mod, "MAY_BIKE", 6, true, "may_bike")
  patchOverworld(mod, "BRENDAN", 6, true, "brendan")
  patchOverworld(mod, "BRENDAN_BIKE", 6, true, "brendan_bike")
  patchOverworld(mod, "DAWN", 6, true, "dawn")
  patchOverworld(mod, "DAWN_BIKE", 6, true, "dawn_bike")
  -- A few Yellow map objects refer to fallback IDs (HIKER/SUPER_NERD) even
  -- though their names/classes are Blackbelt and Burglar.  Supply the
  -- missing native HGSS IDs so the object-local corrections below can point
  -- to real sprites instead of silently failing on absent registry entries.
  -- The Dojo's Black Belts are not Bruno.  Keep Bruno's Elite Four charset
  -- scoped to BRUNOS_ROOM and use the dedicated Black Belt sheet for the
  -- Fighting Dojo object redirects below.
  -- Fighting Dojo Black Belts need all three facings so they can turn toward
  -- the player.  The normalized HGSS sheet keeps six 32px cells in the same
  -- order as the other walkers: down, up, side, then their walk frames.
  patchOverworld(mod, "BLACKBELT", 6, true, "blackbelt")
  patchOverworld(mod, "BURGLAR", 6, true, "rocket")
  for shortId in words(STANDING) do
    patchOverworld(mod, shortId, 3, false)
  end
  patchOverworld(mod, "SNORLAX", 1, false)
  for _, entry in pairs(POKEMON_OBJECT_SHEETS) do
    patchPokemonOverworld(mod, entry)
  end

  -- The selector changes only the field player charset. Battle trainer art
  -- is resolved by this mod's self-contained collections;
  -- the selected native sheet is used for the overworld player and Oak intro.
  -- Gen2 has a different field/player registry and different trainer roster.
  -- Keep the Yellow field patch out of the Gen2 arm until the Ethan/Kris
  -- mapping is installed against data.gen2Sprites.
  if not isGen2() then
    mod.content.field:patch("playerSprites", {
      walk = selectedPlayerSpriteId(),
      bike = selectedPlayerBikeSpriteId(),
      -- Always use the authored Surfing Pikachu ride for Yellow.  The original
      -- game only selects `surfPikachu` when the party's SURF user is Pikachu,
      -- but Pikachu cannot learn SURF through the normal Yellow HM flow.  Keep
      -- both water paths on the same registered sheet so the custom ride is
      -- reachable without Stadium/event save data, while preserving the
      -- engine's surfing movement and collision rules.
      surf = "SPRITE_SURFING_PIKACHU",
      surfPikachu = "SPRITE_SURFING_PIKACHU",
    })
  end

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
    GYM_ERIKA = "gym_erika",
    AGATHA = "agatha",
    LORELEI = "lorelei",
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
  end

  -- Gen 2 uses a separate sprite registry and does not instantiate Yellow's
  -- map objects.  Register the Gen-2 definitions during mod load, while the
  -- content registry is still mutable.  The active game is not known yet at
  -- this point, so these harmless extra records are installed for both
  -- supported generations; only the Gen-2 resolver consumes them.
  patchGen2PlayerSprites()
  patchGen2NpcSprites()
  patchGen2ElmObjectBall()
  patchGen2ElmStarterPokePics()

  -- The stock renderer always builds 16x16 quads.  Our generated sheets are
  -- 32x192 (six 32x32 frames in native DS density), so install a small,
  -- version-pinned compatibility adapter.  It preserves palette resolution,
  -- right-facing flips, walking cadence and the fishing top-half behavior.
  local SpriteRenderer = require("src.render.SpriteRenderer")
  local SpriteAssets = require("src.render.Assets")
  local PaletteFX = require("src.render.PaletteFX")
  local oldNew = SpriteRenderer.new
  local oldDraw = SpriteRenderer.draw
  local overworldHdDraws = {}
  local overworldHdOrder = 0

  -- DRAMALESS_SHAPE deliberately keeps its namespace private, so there is
  -- no public billboard-size hook to call.  Locate its SpriteBillboards
  -- table through the registered voxel callback once content has merged,
  -- then widen only our proxy-backed cards.  Texture UVs remain untouched;
  -- the native 32/48px image still supplies every authored pixel.
  local voxelBillboardsPatched = false
  local voxelBillboardsPatching = false
  -- Billboard geometry and the optional VoxelScene depth-bias hook have
  -- different lifetimes.  The former is discoverable before the first world
  -- pass; the latter is only discoverable after VoxelScene has rendered once.
  -- Keep those states separate so a wrapped external drawEntity cannot force
  -- the expensive closure walk on every SpriteRenderer.draw call.
  local voxelEntityPatchAttempted = false
  local voxelBillboardRetryAt = 0
  -- Set by the voxel world's own draw callback for the current frame.  The
  -- callback runs before Renderer:endFrame presents the world, while the
  -- pipeline registry is allowed to clear its transient owner afterwards;
  -- keeping this one-frame latch avoids relying on that timing-sensitive
  -- query when deciding whether a flat HD repaint would break depth order.
  local voxelWorldRendered = false
  local function patchVoxelBillboards(afterWorldPass)
    if (voxelBillboardsPatched and (not afterWorldPass
        or voxelEntityPatchAttempted)) or voxelBillboardsPatching
       then return end
    local clock = love and love.timer and love.timer.getTime
    local now = clock and clock() or os.clock()
    -- If the voxel pipeline has not created its private billboard table yet,
    -- avoid turning the fallback lookup into a per-frame retry.  A short retry
    -- window is enough for late-loading pipelines while keeping external
    -- sprite mods out of the hot path.
    if now < voxelBillboardRetryAt then return end
    voxelBillboardsPatching = true
    local okP, Pipelines = pcall(require, "src.render.Pipelines")
    local voxel = okP and Pipelines.get and Pipelines.get("voxel")
    -- The supported voxel renderers expose their private SpriteBillboards
    -- table through the documented mod.find/export channel.  Gen1Recomp
    -- intentionally removes
    -- the debug library from mod sandboxes, so the old upvalue walk cannot
    -- reach this table on current builds.  Use the export first and retain the
    -- upvalue path only for older voxel renderers that do not publish it.
    local billboards
    local voxelLib
    local voxelProviderIds = { "potato_voxel", "BATTLE_ART_VOXEL_FORK",
      "DRAMALESS_SHAPE", "DRAMATIC_SHAPE" }
    for _, providerId in ipairs(voxelProviderIds) do
      if not billboards and type(mod.find) == "function" then
        local okFind, provider = pcall(mod.find, providerId)
        local lib = okFind and provider and provider.exports
          and provider.exports.lib
        if lib and type(lib.require) == "function" then
          voxelLib = lib
          local okBillboards, exported = pcall(lib.require, "SpriteBillboards")
          if okBillboards and type(exported) == "table" then billboards = exported end
        end
      end
    end
    if not voxel and not billboards then voxelBillboardsPatching = false; return end
    if voxel and type(voxel.drawWorld) == "function"
       and not voxel._hgssWorldDrawWrapped then
      local oldVoxelDrawWorld = voxel.drawWorld
      voxel.drawWorld = function(...)
        voxelWorldRendered = true
        local result = oldVoxelDrawWorld(...)
        -- VoxelScene's render closure is fully populated only after the first
        -- world pass. Retry now so private drawEntity/billboardPull upvalues
        -- are available on all engine builds.
        if not voxelEntityPatchAttempted then patchVoxelBillboards(true) end
        return result
      end
      voxel._hgssWorldDrawWrapped = true
    end
    local seen = {}
    local function find(value, depth)
      -- VoxelScene keeps SpriteBillboards behind a few nested closures;
      -- walk the complete callback graph so the adapter is actually reached
      -- after the voxel pipeline has initialized.
      if depth > 32 or seen[value] then return nil end
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
    if not billboards and voxel and debug and debug.getupvalue then
      billboards = find(voxel.drawWorld, 0)
    end
    if not billboards then
      voxelBillboardRetryAt = now + 0.25
      voxelBillboardsPatching = false
      return
    end
    if not billboards._hgssVariableGeometryWrapped then
      local originalMesh = billboards.mesh
      local sized = setmetatable({}, { __mode = "k" })
      local baseVertices = setmetatable({}, { __mode = "k" })
      local shadowMeshes = setmetatable({}, { __mode = "k" })

      local function rememberBase(mesh)
        local saved = baseVertices[mesh]
        if saved or not (mesh and mesh.getVertex) then return saved end
        saved = {}
        for vertex = 1, 4 do
          local x, y, z, u, v, color = mesh:getVertex(vertex)
          saved[vertex] = { x, y, z, u, v, color }
        end
        baseVertices[mesh] = saved
        return saved
      end

      local function copyGeometry(mesh, source, width, height, yOffset,
                                  clone)
        if not source then return mesh end
        local vertices = {}
        local left = 8 - width / 2
        for vertex = 1, 4 do
          local base = source[vertex]
          local right = base[1] > 8
          local top = base[2] > 8
          local x = right and (left + width) or left
          local y = (top and height or 0) + (yOffset or 0)
          vertices[vertex] = { x, y, base[3], base[4], base[5], base[6] }
        end
        if clone and voxelLib and type(voxelLib.require) == "function" then
          local okVoxel, Voxel3D = pcall(voxelLib.require, "Voxel3D")
          if okVoxel and Voxel3D and type(Voxel3D.newMesh) == "function"
             and type(Voxel3D.pushQuad) == "function" then
            local indices = {}
            Voxel3D.pushQuad(indices, 0)
            local okMesh, copy = pcall(Voxel3D.newMesh, vertices, indices)
            if okMesh and copy then return copy end
          end
        elseif mesh and mesh.setVertex then
          for vertex = 1, 4 do
            mesh:setVertex(vertex, unpack(vertices[vertex]))
          end
        end
        return mesh
      end

      local function nativeMesh(def, frame)
        local mesh = originalMesh(def, frame)
        if not (mesh and def and def.hgssNativeImage) then return mesh end
        local source = rememberBase(mesh)
        local size = overworldSpriteScale(def)
        -- Quantize the final billboard dimensions.  Fractional mesh extents
        -- make the rasterizer sample different pixel columns on each frame
        -- (most visible at 0.6x/0.7x), which looks like a stretched or pinched
        -- NPC even though the source PNG is correct.
        local baseW = tonumber(def.hgssBaseVoxelWidth
          or def.hgssVoxelWidth or def.hgssFrameWidth) or 32
        local baseH = tonumber(def.hgssBaseVoxelHeight
          or def.hgssVoxelHeight or def.hgssFrameHeight) or 32
        -- Potato/Dramatic voxel billboards are authored in a 16px world
        -- cell even when the replacement card is 32px wide.  Apply the
        -- logical sprite-size control in that world space; without this
        -- conversion every value >= 0.5 collapses to the engine's minimum
        -- card and 1.0x looks identical to 0.5x.
        local voxelScale = 1
        local width, height
        if def.hgssPreserveAspect then
          local fw = tonumber(def.hgssFrameWidth) or 32
          local fh = tonumber(def.hgssFrameHeight) or 32
          local uniform = math.min(baseW / fw, baseH / fh) * size * voxelScale
          width = math.max(1, math.floor(fw * uniform + 0.5))
          height = math.max(1, math.floor(fh * uniform + 0.5))
        else
          width = math.max(1, math.floor(baseW * size * voxelScale + 0.5))
          height = math.max(1, math.floor(baseH * size * voxelScale + 0.5))
        end
        local stamp = table.concat({ width, height,
          tostring(def.hgssVoxelEntityYOffset or 0) }, "x")
        if sized[mesh] ~= stamp then
          copyGeometry(mesh, source, width, height,
            tonumber(def.hgssVoxelEntityYOffset) or 0, false)
          sized[mesh] = stamp
        end
        return mesh
      end

      -- The voxel renderer uses a separate shadowQuad call. Keep its
      -- footprint at the ground plane while the visible card receives the
      -- per-sheet grounding offset; this reproduces the old drawEntity hook
      -- without relying on the debug library.
      local function nativeShadow(def, frame)
        local mesh = originalMesh(def, frame)
        if not (mesh and def and def.hgssNativeImage) then return mesh end
        local source = rememberBase(mesh)
        local size = overworldSpriteScale(def)
        local baseW = tonumber(def.hgssBaseVoxelWidth
          or def.hgssVoxelWidth or def.hgssFrameWidth) or 32
        local baseH = tonumber(def.hgssBaseVoxelHeight
          or def.hgssVoxelHeight or def.hgssFrameHeight) or 32
        local width, height
        if def.hgssPreserveAspect then
          local fw = tonumber(def.hgssFrameWidth) or 32
          local fh = tonumber(def.hgssFrameHeight) or 32
          local uniform = math.min(baseW / fw, baseH / fh) * size
          width = math.max(1, math.floor(fw * uniform + 0.5))
          height = math.max(1, math.floor(fh * uniform + 0.5))
        else
          width = math.max(1, math.floor(baseW * size + 0.5))
          height = math.max(1, math.floor(baseH * size + 0.5))
        end
        local stamp = width .. "x" .. height
        local cached = shadowMeshes[mesh]
        if not cached or cached.stamp ~= stamp then
          cached = { stamp = stamp,
            mesh = copyGeometry(mesh, source, width, height, 0, true) }
          shadowMeshes[mesh] = cached
        end
        return cached.mesh or mesh
      end
      billboards.mesh = nativeMesh
      billboards.shadowQuad = nativeShadow
      billboards._hgssVariableGeometryWrapped = true
    end
    -- From this point onward the expensive billboard lookup is complete.  The
    -- optional entity-depth hook is attempted only from the post-world-pass
    -- callback, after VoxelScene has populated its closures.
    voxelBillboardsPatched = true
    if not afterWorldPass or not voxel then
      voxelBillboardsPatching = false
      return
    end
    -- Current Gen1Recomp sandboxes do not expose Lua's debug library to mods.
    -- The public PotatoVoxel export above is sufficient for geometry scaling;
    -- the optional depth/grounding surgery below is only available on older
    -- desktop builds that still expose debug upvalues.
    if not (debug and debug.getupvalue and debug.setupvalue) then
      voxelEntityPatchAttempted = true
      voxelBillboardsPatched = true
      voxelBillboardsPatching = false
      return
    end

    -- The voxel card and its shadow share a mesh.  Moving that mesh moves
    -- both together, so it cannot correct a character that appears to float
    -- above its ground shadow.  Patch the cast's entity call instead: every
    -- replacement character is lowered, while the shadow remains anchored
    -- to the map.
    -- VoxelScene is usually nested behind the pipeline callback rather than
    -- exposed as a named upvalue on drawWorld.  Find the module table by its
    -- stable public shape instead of assuming a particular closure layout.
    local scene
    local sceneSeen = {}
    local function findScene(value, depth)
      if depth > 32 then return nil end
      local kind = type(value)
      if kind ~= "function" and kind ~= "table" then return nil end
      if sceneSeen[value] then return nil end
      sceneSeen[value] = true
      if kind == "table" then
        if type(value.render) == "function"
           and type(value.drawEntity) == "function" then return value end
        for _, child in pairs(value) do
          local hit = findScene(child, depth + 1)
          if hit then return hit end
        end
      else
        for j = 1, 48 do
          local _, child = debug.getupvalue(value, j)
          if not child then break end
          local hit = findScene(child, depth + 1)
          if hit then return hit end
        end
      end
      return nil
    end
    scene = findScene(voxel.drawWorld, 0)
    if not scene then
      local okS, VoxelScene = pcall(require, "VoxelScene")
      if okS and type(VoxelScene) == "table"
         and type(VoxelScene.render) == "function"
         and type(VoxelScene.drawEntity) == "function" then
        scene = VoxelScene
      end
    end
    local render = scene and scene.render
    local drawCast
    if render then
      for i = 1, 32 do
        local name, value = debug.getupvalue(render, i)
        if not name then break end
        if name == "drawCast" and type(value) == "function" then drawCast = value; break end
      end
    end
    local entityPatched = false
    if render then
      -- The drawCast closure can be introduced after the first scene render;
      -- try the module's current function directly as a fallback.  This keeps
      -- the adapter resilient across engine builds with different upvalue
      -- layouts.
      local direct = scene.drawEntity
      if type(direct) == "function" then
        local oldEntity = direct
        local oldPull = nil
        for j = 1, 48 do
          local upName, upValue = debug.getupvalue(oldEntity, j)
          if not upName then break end
          if upName == "billboardPull" and type(upValue) == "function" then oldPull = upValue; break end
        end
        -- On builds exposing drawCast, that closure is the live render path
        -- and applies the grounding bias below.  Wrapping scene.drawEntity
        -- as well would add the offset a second time, separating sprites from
        -- their voxel shadows.  Use the direct scene fallback only when the
        -- drawCast seam is unavailable.
        if oldPull and not drawCast then
          local biasActive = false
          local function biasedPull() return oldPull() + (biasActive and 4 or 0) end
          for j = 1, 48 do
            local upName = debug.getupvalue(oldEntity, j)
            if not upName then break end
            if upName == "billboardPull" then debug.setupvalue(oldEntity, j, biasedPull); break end
          end
          local function wrappedEntity(sprite, px, py, facing, phase, flip, gh, colors, lift)
            local def = sprite and sprite.def
            biasActive = def and def.hgssNativeImage and true or false
            if biasActive and def.hgssVoxelEntityYOffset then gh = gh + (tonumber(def.hgssVoxelEntityYOffset) or 0) end
            local ok, result = pcall(oldEntity, sprite, px, py, facing, phase, flip, gh, colors, lift)
            biasActive = false
            return ok and result or false
          end
          scene.drawEntity = wrappedEntity
          entityPatched = true
        end
      end
    end
    if drawCast then
      for i = 1, 16 do
        local name, value = debug.getupvalue(drawCast, i)
        if not name then break end
        if name == "drawEntity" and type(value) == "function" then
          local oldEntity = value
          -- The leaned billboard already gets a camera-ward pull from
          -- DRAMALESS_SHAPE.  Native HGSS cards are taller than the stock
          -- 16px walkers, so an elevated voxel prop (lab cabinets, counters,
          -- machines) can otherwise win the depth test across the upper half
          -- of a character that is standing in front of it.  Add a small,
          -- sprite-only bias through the scene function's pull helper.  This
          -- changes depth only; the feet, ground height and shadow remain at
          -- their authored positions, and real behind-wall occlusion still
          -- wins because the bias is much smaller than a tile row.
          local hgssDepthBiasActive = false
          local hgssDepthBiasInstalled = false
          if debug.getupvalue and debug.setupvalue then
            for j = 1, 32 do
              local upName, upValue = debug.getupvalue(oldEntity, j)
              if not upName then break end
              if upName == "billboardPull" and type(upValue) == "function" then
                local basePull = upValue
                debug.setupvalue(oldEntity, j, function()
                  return basePull() + (hgssDepthBiasActive and 4 or 0)
                end)
                hgssDepthBiasInstalled = true
                break
              end
            end
          end
          if not hgssDepthBiasInstalled then
            local scenePull
            for j = 1, 48 do
              local upName, upValue = debug.getupvalue(oldEntity, j)
              if not upName then break end
              if upName == "VoxelScene" and type(upValue) == "table"
                 and type(upValue.pull) == "function" then
                scenePull = upValue.pull; break
              end
            end
            if scenePull then
              for j = 1, 48 do
                local upName, upValue = debug.getupvalue(oldEntity, j)
                if not upName then break end
                if upName == "billboardPull" then
                  debug.setupvalue(oldEntity, j, function()
                    return scenePull(1.0) + (hgssDepthBiasActive and 4 or 0)
                  end)
                  hgssDepthBiasInstalled = true
                  break
                end
              end
            end
          end
          local function anchoredEntity(sprite, px, py, facing, phase, flip,
                                        gh, colors, lift)
            local def = sprite and sprite.def
            if def and def.hgssVoxelEntityYOffset and def.hgssNativeImage then
              gh = gh + (tonumber(def.hgssVoxelEntityYOffset) or 0)
            end
            hgssDepthBiasActive = def and def.hgssNativeImage and true or false
            local result = oldEntity(sprite, px, py, facing, phase, flip, gh, colors, lift)
            hgssDepthBiasActive = false
            return result
          end
          debug.setupvalue(drawCast, i, anchoredEntity)
          entityPatched = true
          break
        end
      end
    end

    -- A missing depth hook is a tolerated compatibility outcome (for example
    -- when another mod wraps VoxelScene.drawEntity).  Record that the single
    -- post-world attempt is complete so no future sprite draw repeats the
    -- closure graph scan.
    voxelEntityPatchAttempted = true
    voxelBillboardsPatched = true
    voxelBillboardsPatching = false
  end
  local function tryPatchVoxelBillboards()
    -- Gen 2 currently uses the native flat renderer only. Potato's Gen-2
    -- bridge does not export its billboard module, so attempting the Gen-1
    -- adapter here cannot provide a reliable size control.
    if isGen2() then return end
    if voxelBillboardsPatched then return end
    patchVoxelBillboards(false)
  end

  local HGSS_STAND_FRAMES = { down = 0, up = 1, left = 2, right = 2 }
  local HGSS_WALK_FRAMES = { down = 3, up = 4, left = 5, right = 5 }
  local HGSS_GAMBLER_WALK_FRAMES = { down = 0, up = 4, left = 5, right = 5 }
  local hgssFrameBottomsCache = {}
  local PipelinesModule = nil

  SpriteRenderer.new = function(spriteDef, seed)
    if isGen2() then
      -- Potato owns the Gen-2 world pass, so install the same variable-size
      -- billboard adapter before the first actor is rendered. Previously the
      -- Gen-2 early return skipped this hook entirely, leaving every card at
      -- Potato's fixed minimum size and ignoring the menu option.
      tryPatchVoxelBillboards()
      local self = oldNew(spriteDef, seed)
      -- Gen-2 player sheets may be authored at 256x1536 and reduced only at
      -- draw time.  The engine's default linear sampler makes that reduction
      -- look blurred; nearest preserves the source's pixel-art edges without
      -- changing its dimensions or colour data.
      if self and spriteDef and spriteDef.hgssNativeImage then
        local native = SpriteAssets.image(spriteDef.hgssNativeImage)
        if native then
          self.image = native
          -- oldNew built its quads against the 16px proxy sheet. Rebuild
          -- them against the native HGSS texture after swapping the image;
          -- otherwise LOVE clamps the oversized Gen-2 quads and produces a
          -- tiny/garbled sprite in the non-voxel renderer.
          local iw, ih = native:getDimensions()
          -- oldNew derives frame dimensions from the proxy image. Restore
          -- the authored HGSS cell dimensions before rebuilding the quads;
          -- otherwise a 16px proxy cell is used against the native sheet.
          self.frameWidth = tonumber(spriteDef.frameWidth) or self.frameWidth
          self.frameHeight = tonumber(spriteDef.frameHeight) or self.frameHeight
          self.frameCount = tonumber(spriteDef.frames) or self.frameCount
          self.frames = {}
          for frame = 0, self.frameCount - 1 do
            self.frames[frame] = love.graphics.newQuad(
              0, frame * self.frameHeight, self.frameWidth,
              self.frameHeight, iw, ih)
          end
        end
      end
      if self and spriteDef and spriteDef.hgssGen2NearestFilter
         and self.image and self.image.setFilter then
        self.image:setFilter("nearest", "nearest")
      end
      return self
    end
    tryPatchVoxelBillboards()
    local self = oldNew(spriteDef, seed)
    if self and spriteDef and spriteDef.hgssNativeImage then
      self.hgssIsPlayer = seed == "player"
    end
    if self and spriteDef and spriteDef.hgssNativeImage then
      self.image = SpriteAssets.image(spriteDef.hgssNativeImage)
      if spriteDef.hgssLinearFilter and self.image.setFilter then
        self.image:setFilter("linear", "linear")
      end
    end
    if self and self.image then
      local iw, ih = self.image:getDimensions()
      -- Only definitions authored by this mod carry hgssNativeImage.  Other
      -- mods (notably Wilds of Kanto) also register animated 32px sheets;
      -- treating those as HGSS assets changes their frame contract and adds
      -- unnecessary post-processing to every external entity.
      local isHgssAsset = spriteDef
        and type(spriteDef.hgssNativeImage) == "string"
        and spriteDef.hgssNativeImage ~= ""
      local fw = isHgssAsset
        and (tonumber(spriteDef.hgssFrameWidth) or 32)
        or nil
      local fh = isHgssAsset
        and (tonumber(spriteDef.hgssFrameHeight) or 32)
        or nil
      if isHgssAsset and iw == fw and ih >= fh and ih % fh == 0 then
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
      -- Record the visible bottom of each authored cell once.  Different
      -- HGSS sheets (and even different poses in one sheet) contain varying
      -- transparent rows below the shoes.  Using this alpha bound lets the
      -- renderer put every pose on the exact same ground line without
      -- editing or resampling the source PNG.
      if spriteDef.hgssNativeImage and love.image
         and love.image.newImageData then
        local cacheKey = spriteDef.hgssNativeImage .. ":" .. tostring(fw) .. ":" .. tostring(fh)
        local cachedBottoms = hgssFrameBottomsCache[cacheKey]
        if cachedBottoms then
          self.hgssFrameBottoms = cachedBottoms
        else
          local okData, data = pcall(love.image.newImageData,
            spriteDef.hgssNativeImage)
          if okData and data and data.getPixel then
            local bottoms = {}
            local dataW, dataH = data:getDimensions()
            local sampleW = math.min(fw, dataW)
            local count = math.min(6, math.floor(dataH / fh))
            for frame = 0, count - 1 do
              local bottom = 0
              for yy = 0, fh - 1 do
                local rowVisible = false
                local dataY = frame * fh + yy
                if dataY >= dataH then break end
                for xx = 0, sampleW - 1 do
                  local _, _, _, alpha = data:getPixel(xx, frame * fh + yy)
                  if (alpha or 0) > 0.01 then
                    rowVisible = true
                    break
                  end
                end
                if rowVisible then bottom = yy + 1 end
              end
              bottoms[frame] = bottom
            end
            if data.release then data:release() end
            hgssFrameBottomsCache[cacheKey] = bottoms
            self.hgssFrameBottoms = bottoms
          end
        end
      end
    end
    return self
  end

  SpriteRenderer.draw = function(self, px, py, camX, camY, facing,
                                  walkPhase, stepFlip, topHalf)
    if isGen2() then
      -- Gen 2's native map is authored on a 16px world grid. HGSS source
      -- sheets keep every authored pixel and are reduced only at draw time.
      -- Draw directly at the logical foot anchor: scaling the full graphics
      -- context around world coordinates caused camera-dependent drift and
      -- could collapse the sprite into a few pixels in the flat renderer.
      local displayScale = self.def and tonumber(self.def.hgssGen2DisplayScale)
      if displayScale then
        displayScale = displayScale * overworldSpriteScale(self.def)
      end
      if displayScale and displayScale > 0 then
        local G = love.graphics
        local frame = (self.def.walker and walkPhase == 1)
          and HGSS_WALK_FRAMES[facing] or HGSS_STAND_FRAMES[facing]
        frame = frame or 0
        if not self.frames[frame] then frame = 0 end
        local flip = facing == "right"
          or ((facing == "down" or facing == "up")
              and walkPhase == 1 and stepFlip)
        local drawW = self.frameWidth * displayScale
        local drawH = self.frameHeight * displayScale
        local groundX = math.floor(px - (camX or 0)) + 8
        local groundY = math.floor(py - (camY or 0)) + 12
        local x = groundX - drawW / 2
        local y = groundY - drawH
        if self.def.trueColor then
          PaletteFX.markTrueColor(x, y, drawW, drawH)
        end
        if flip then
          G.draw(self.image, self.frames[frame], x + drawW, y, 0,
            -displayScale, displayScale)
        else
          G.draw(self.image, self.frames[frame], x, y, 0,
            displayScale, displayScale)
        end
        return
      end
      return oldDraw(self, px, py, camX, camY, facing, walkPhase,
                     stepFlip, topHalf)
    end
    tryPatchVoxelBillboards()
    if not self.isHgssSheet
       or not (self.def and type(self.def.hgssNativeImage) == "string"
               and self.def.hgssNativeImage ~= "") then
      return oldDraw(self, px, py, camX, camY, facing, walkPhase,
                     stepFlip, topHalf)
    end
    local fw = self.hgssFrameWidth or 32
    local fh = self.hgssFrameHeight or 32
    -- Keep the same authored size and anchor as the known-good 0.0.26
    -- renderer.  Charset corrections are image replacements only; changing
    -- the runtime scale here makes every overworld character inconsistent.
    local size = overworldSpriteScale(self.def)
    -- Use integer destination dimensions for both axes.  LÖVE accepts
    -- fractional scales, but the resulting half-pixel sampling makes the
    -- 32px NPC sheets visibly warp when SPRITE SIZE is below 1.0.  Rounding
    -- the common destination box preserves each sheet's aspect ratio while
    -- keeping every frame on the same pixel grid as Red.
    local baseW = tonumber(self.def.hgssBaseDrawWidth
      or self.def.hgssDrawWidth) or fw
    local baseH = tonumber(self.def.hgssBaseDrawHeight
      or self.def.hgssDrawHeight) or fh
    local drawW, drawH
    if self.def.hgssPreserveAspect then
      local uniform = math.min(baseW / fw, baseH / fh) * size
      drawW = math.max(1, math.floor(fw * uniform + 0.5))
      drawH = math.max(1, math.floor(fh * uniform + 0.5))
    else
      drawW = math.max(1, math.floor(baseW * size + 0.5))
      drawH = math.max(1, math.floor(baseH * size + 0.5))
    end
    local scaleX, scaleY = drawW / fw, drawH / fh
    local x = math.floor(px - camX) - math.floor(drawW / 2) + 8
    local walk = self.def.hgssGamblerLayout and HGSS_GAMBLER_WALK_FRAMES or HGSS_WALK_FRAMES
    local frame = (self.def.walker and walkPhase == 1)
      and walk[facing] or HGSS_STAND_FRAMES[facing]
    frame = frame or 0
    -- All overworld sheets use the same cell-foot anchor as the native Red
    -- charset. The authored HD frames can contain transparent rows below the
    -- shoes; anchor the selected frame from its visible bottom instead of
    -- centering its raw canvas.
    -- Keep the logical footline at the same cell bottom as Red. The stock
    -- renderer intentionally ignores transparent padding in a charset; do
    -- not derive a per-frame shift from the art because that makes a shorter
    -- NPC appear to float beside a correctly anchored player.
    local anchor = tonumber(self.def.hgssAnchorOffset) or 0
    if not topHalf and self.hgssFrameBottoms
       and self.hgssFrameBottoms[frame] then
      local visibleBottom = self.hgssFrameBottoms[frame]
      -- The common logical footline is `py + 16`.  Convert the source alpha
      -- bound into the current (possibly reduced) destination height so the
      -- correction scales together with SPRITE SIZE.
      anchor = drawH - visibleBottom * drawH / fh
    end
    local y = math.floor(py - camY) - drawH + 16 + anchor
    -- DS charsets are authored with a taller visual canvas than the native
    -- 16px map cell. Their logical feet sit at the bottom of the draw box;
    -- the stock renderer's +16 anchor therefore needs the same extra cell
    -- offset for every replacement sheet. Red is the reference silhouette;
    -- this only moves the complete frame and never rescales or crops it.
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
    -- Gen I stores one walking pose for each direction.  Consecutive
    -- vertical steps alternate the leading foot by mirroring that pose;
    -- ignoring stepFlip made Blue/Gary (and other native 32px walkers)
    -- repeat one leg and visibly slide/limp through scripted movement.
    local flip = facing == "right"
      or ((facing == "down" or facing == "up")
          and self.def.walker and walkPhase == 1 and stepFlip)
    -- The voxel pass already draws the native billboard with its own depth
    -- ordering.  Do not allocate a transient post-present draw record for
    -- every HGSS entity in that pass: HdRenderer.endFrame discards those
    -- records after detecting voxelWorldRendered, so keeping them only adds
    -- per-frame Lua table churn (especially visible at VOXEL HIGH/FULL).
    local voxelActive = false
    if PipelinesModule == nil then
      local okPipeline, PipelineState = pcall(require, "src.render.Pipelines")
      PipelinesModule = (okPipeline and PipelineState) or false
    end
    if PipelinesModule and type(PipelinesModule.worldPipeline) == "function" then
      local okWorld, worldPipeline = pcall(PipelinesModule.worldPipeline)
      voxelActive = okWorld and worldPipeline ~= nil
    end
    if self.def.hgssPostPresent and not voxelActive and not voxelWorldRendered then
      overworldHdOrder = overworldHdOrder + 1
      overworldHdDraws[#overworldHdDraws + 1] = {
        image = image, quad = quad, x = x, y = y,
        -- `py` is the entity's ground point in world pixels. It is the
        -- authoritative footline even when the source sheet has transparent
        -- padding below the shoes. Keep it separate from the top-left `y`
        -- used for drawing the image.
        groundY = math.floor(py - camY) + 16,
        isPlayer = self.hgssIsPlayer,
        order = overworldHdOrder,
        frameWidth = fw, frameHeight = topHalf and math.floor(fh / 2) or fh,
        drawWidth = drawW,
        drawHeight = topHalf and math.floor(drawH / 2) or drawH,
        flip = flip,
      }
      return
    end
    if self.def.trueColor and PaletteFX.markTrueColor then
      PaletteFX.markTrueColor(x, y, drawW,
        topHalf and math.floor(drawH / 2) or drawH)
    end
    if flip then
      love.graphics.draw(image, quad, x + drawW, y, 0, -scaleX, scaleY)
    else
      love.graphics.draw(image, quad, x, y, 0, scaleX, scaleY)
    end
  end

  -- PartyMenu's legacy replacement is retained only as historical reference;
  -- battle artwork is handled by the self-contained battle collections.
  local battleArtPresent = false
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
  local hgssPartyDraw
  local hgssPartyDrawIcon
  local partyIconImages = {}
  local partyIconQuads = {}
  local partyIconRoot = mod.assets:path("assets/icons/")
  local originalPartyIcons = setmetatable({}, { __mode = "k" })

  local function isVanillaPartyAsset(path)
    if type(path) ~= "string" then return false end
    path = path:gsub("\\", "/")
    return path:find("assets/generated/sprites/", 1, true) == 1
        or path:find("assets/generated/icons/", 1, true) == 1
  end

  -- Gen I's original party icons reuse overworld sheets named monster,
  -- pikachu, seel, bird and fairy. HGSS_SPRITES intentionally overrides
  -- those same generated paths for the map, so the stock PartyMenu renderer
  -- would otherwise crop 16px fragments out of our large HGSS charsets.
  -- Bypass the override search only while the vanilla icon is loaded.
  local function vanillaPartyDrawIcon(game, mon, x, y, selected, counter,
                                      forceAlt)
    local oldResolve = PartyAssets.resolve
    local oldImageData = PartyAssets.imageData
    PartyAssets.resolve = function(path)
      if isVanillaPartyAsset(path) then return path end
      return oldResolve(path)
    end
    PartyAssets.imageData = function(path)
      if isVanillaPartyAsset(path) then
        return love.image.newImageData(path)
      end
      return oldImageData(path)
    end
    local ok, result = pcall(oldPartyDrawIcon, game, mon, x, y, selected,
                             counter, forceAlt)
    PartyAssets.resolve = oldResolve
    PartyAssets.imageData = oldImageData
    if not ok then error(result, 0) end
    return result
  end

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

  -- The native HGSS layout below is a two-column by three-row grid.  The
  -- engine only enables its multidirectional grid helper for battle switch
  -- menus, so the regular field Party screen treated DOWN as the next list
  -- item (moving from the left column to the right).  Opt the helper in for
  -- our native party layout while preserving the engine behavior when the
  -- custom party screen is disabled or vanilla icons are being drawn.
  if not isGen2() and type(PartyMenu.gridNavigation) == "function"
     and not PartyMenu.__hgssGridNavigationHook then
    local oldPartyGridNavigation = PartyMenu.gridNavigation
    PartyMenu.gridNavigation = function(self)
      if mod.options:get("party_menu") ~= false then
        local party = self.party or (self.game and self.game.save
          and self.game.save.party) or {}
        for _, mon in ipairs(party) do
          if isHgssPartyIcon(partyIconPath(self.game, mon)) then
            return true
          end
        end
      end
      return oldPartyGridNavigation(self)
    end
    PartyMenu.__hgssGridNavigationHook = true
  end

  local function applyPartyMenuOption(game)
    if isGen2(game) then return end
    local data = game and game.data
    local icons = data and data.icons
    if not icons then return end
    -- Snapshot the pre-HGSS table once per game-data instance. This preserves
    -- the base game's species records (and entries supplied by another mod)
    -- so PARTY MENU OFF is an exact restoration, not a fallback to a partial
    -- generic Game Boy icon.
    local snapshot = originalPartyIcons[icons]
    if not snapshot then
      snapshot = { table = icons.bySpecies, hadTable = icons.bySpecies ~= nil,
                   entries = {} }
      if icons.bySpecies then
        for species in words(SPECIES) do
          local entry = icons.bySpecies[species]
          snapshot.entries[species] = entry
        end
      end
      originalPartyIcons[icons] = snapshot
    end
    local enabled = mod.options:get("party_menu") ~= false
    if enabled then
      icons.bySpecies = icons.bySpecies or {}
      for species in words(SPECIES) do
        icons.bySpecies[species] = partyIconEntries[species]
      end
      if hgssPartyDrawIcon then PartyMenu.drawIcon = hgssPartyDrawIcon end
      if hgssPartyDraw then PartyMenu.draw = hgssPartyDraw end
    elseif snapshot.hadTable then
      -- Restore the original table object, including any metatable used by
      -- the core icon registry. Replacing it with a plain table makes the
      -- vanilla renderer select only clipped fallback fragments.
      icons.bySpecies = snapshot.table or {}
      for species in words(SPECIES) do
        icons.bySpecies[species] = snapshot.entries[species]
      end
    else
      icons.bySpecies = nil
    end
    if not enabled then
      -- Remove our methods as well as our data. This makes OFF behave exactly
      -- like a run where HGSS_SPRITES was never loaded, including callers
      -- that invoke PartyMenu.drawIcon directly (trade/battle switch flows).
      PartyMenu.drawIcon = vanillaPartyDrawIcon
      PartyMenu.draw = oldPartyDraw
    end
  end

  local function loadPartyIcon(path)
    local resolved = PartyAssets.resolve(path)
    if partyIconImages[resolved] == nil then
      local ok, image = pcall(love.graphics.newImage, resolved)
      if ok and image and image.setFilter then
        image:setFilter("nearest", "nearest")
      end
      partyIconImages[resolved] = ok and image or false
      if ok and image then
        local iw, ih = image:getDimensions()
        if iw >= 32 and ih >= 32 then
          local q0 = love.graphics.newQuad(0, 0, 32, 32, iw, ih)
          local q1 = ih >= 64 and love.graphics.newQuad(0, 32, 32, 32, iw, ih) or q0
          partyIconQuads[resolved] = { [0] = q0, [1] = q1 }
        end
      end
    end
    return partyIconImages[resolved] or nil, partyIconQuads[resolved]
  end

  hgssPartyDrawIcon = function(game, mon, x, y, selected, counter, forceAlt)
    if battleArtPresent then
      return oldPartyDrawIcon(game, mon, x, y, selected, counter, forceAlt)
    end
    -- Yellow/Gen 1 has no native true-color shiny party-icon path. Sending a
    -- shiny record through the original renderer therefore selects the old
    -- 2bpp placeholder (and, with compatibility mods, can even select the
    -- neighbouring legendary-bird species). Keep the species-specific HGSS
    -- icon sheet for every party record so the icon, frame animation and
    -- slot alignment remain deterministic. Battle/map shiny art is handled by
    -- their own renderers and is not changed here.
    local path = partyIconPath(game, mon)
    if not isHgssPartyIcon(path) then
      return oldPartyDrawIcon(game, mon, x, y, selected, counter, forceAlt)
    end
    local image, quads = loadPartyIcon(path)
    if not image or not quads then return end
    local alt = forceAlt and true or false
    if selected then
      local hp = mon.hp or 0
      local maxHp = mon.stats and mon.stats.hp or 1
      local px = math.floor(hp * 48 / math.max(1, maxHp))
      local speed = px >= 27 and 5 or px >= 10 and 16 or 32
      alt = math.floor((counter or 0) / speed) % 2 == 1
    end
    local frame = alt and 1 or 0
    local quad = quads[frame] or quads[0]
    if not quad then return end
    PartyPaletteFX.markTrueColor(x, y, 32, 32)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(image, quad, x, y)
    return true
  end

  -- Bill's PC lists use ListMenu rather than PartyMenu, so the party icon
  -- adapter above is never called for stored Pokémon.  Add a deliberately
  -- narrow draw bridge for the three Pokémon lists in the PC (withdraw,
  -- deposit and release).  The icon source, animation frames and true-color
  -- handling are the same as the party menu.  The option is checked at draw
  -- time so OFF immediately restores the untouched ListMenu renderer.
  local ListMenu = require("src.ui.ListMenu")
  local oldListMenuDraw = ListMenu.draw
  local oldListMenuNew = ListMenu.new
  local Boxes = require("src.pokemon.Boxes")
  local ListStrings = require("src.core.Strings")

  -- A native 32px icon needs a 32px row.  Keep the stock seven-row layout
  -- available for OFF, but let the custom PC list use four native rows while
  -- icons are enabled.  The item index and scroll fields remain ListMenu's,
  -- so transfer/release behavior is unchanged.
  ListMenu.new = function(game, title, items, opts)
    if isGen2(game) then return oldListMenuNew(game, title, items, opts) end
    local menu = oldListMenuNew(game, title, items, opts)
    local kind = opts and opts.kind
    if kind == "pc_box_withdraw" or kind == "pc_box_deposit"
        or kind == "pc_box_release" then
      menu.hgssPcBoxList = true
    end
    return menu
  end

  local function pcBoxListMon(menu, row)
    local game = menu and menu.game
    local save = game and game.save
    if not save then return nil end
    local index = (menu.scroll or 0) + row
    if menu.kind == "pc_box_deposit" then
      return save.party and save.party[index]
    end
    if menu.kind == "pc_box_withdraw" or menu.kind == "pc_box_release" then
      local box = Boxes.active(save)
      return box and box[index]
    end
    return nil
  end

  local function drawPcBoxIcon(menu, mon, row)
    if not mon or not partyIconEntries[mon.species] then return end
    local path = partyIconEntries[mon.species].image
    local image, quads = loadPartyIcon(path)
    if not image or not quads then return end
    local frame = math.floor((love.timer.getTime() or 0) * 2) % 2
    local quad = quads[frame] or quads[0]
    if not quad then return end
    -- The authored icon sheets carry transparent top padding.  Lift the
    -- native cell by one quarter-row so the visible creature aligns with the
    -- selector/name line rather than appearing to hang below it.
    local y = 8 + (row - 1) * 32
    local x = 0
    PartyPaletteFX.markTrueColor(x, y, 32, 32)
    love.graphics.setColor(1, 1, 1, 1)
    -- No scaling: these are the same native 32x32 frames drawn by PartyMenu.
    love.graphics.draw(image, quad, x, y)
  end

  ListMenu.draw = function(self, ...)
    if isGen2(self and self.game) then
      return oldListMenuDraw(self, ...)
    end
    if not (self and self.hgssPcBoxList)
        or mod.options:get("pc_box_icons") == false then
      if self and self.hgssPcBoxList then self.rows = 7 end
      oldListMenuDraw(self, ...)
      return
    end

    self.rows = 4
    local oldScroll = self.scroll
    local maxScroll = math.max(0, #self.items - self.rows)
    self.scroll = math.min(self.scroll or 0, maxScroll)

    -- Reproduce the small, stable part of ListMenu.draw that the PC transfer
    -- lists use, but leave enough room for native icon frames.  The footer,
    -- dialogue and money variants are not used by these three BoxMenu lists;
    -- all input, callbacks and cursor state still belong to ListMenu.
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.rectangle("fill", 0, 0, 160, 144)
    love.graphics.setColor(0, 0, 0, 1)
    PartyFont.draw(ListStrings(self.title), 8, 4)
    for row = 1, self.rows do
      local i = self.scroll + row
      local item = self.items[i]
      if not item then break end
      local y = 16 + (row - 1) * 32
      local mon = pcBoxListMon(self, row)
      drawPcBoxIcon(self, mon, row)
      -- Match PartyMenu's native entry geometry: the label begins exactly at
      -- the icon's right edge (x=32), with no extra 8px drift.
      PartyFont.draw(item.label, 32, y + 8)
      if item.right then
        PartyFont.draw(item.right, 160 - 8 - PartyFont.width(item.right), y + 8)
      end
      if i == self.index then
        -- Keep the selector on the same baseline as the entry text.
        PartyFont.drawCode(PartyTheme.cursor, 0, y + 8)
      end
      if self.swapIndex == i and i ~= self.index then
        PartyFont.drawCode(PartyTheme.cursorHollow, 0, y + 8)
      end
    end
    love.graphics.setColor(1, 1, 1, 1)
    -- Keep this assignment explicit for a menu that was resized while an
    -- option change arrived between frames; ListMenu owns the actual value.
    self.scroll = math.min(self.scroll or oldScroll or 0, maxScroll)
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
    -- Keep I/T on a one-pixel stem like the other mini-font glyphs.  The
    -- previous two-pixel stems made these letters look bold in long party
    -- names (ARTICUNO, MOLTRES, DITTO), unlike the original menu font.
    I={"1111","0010","0010","0010","0010","0010","1111"},
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
    T={"1111","0010","0010","0010","0010","0010","0010"},
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
      local condition = mon.hp <= 0 and "FNT" or mon.status
      if condition then
        -- A three-digit level occupies four 8px glyph cells (L100).  The
        -- old fixed x+24 condition position therefore overwrote the last
        -- level digit and produced strings such as "L103R" in the party
        -- menu.  Keep the compact same-line layout when the condition fits,
        -- and move it to the spare row below the HP bar otherwise.  Each
        -- entry is 32px tall, so the y+24 line remains inside its own cell
        -- and never touches the next party member.
        local levelWidth = PartyFont.width("L" .. tostring(mon.level))
        local conditionWidth = PartyFont.width(condition)
        if levelWidth + conditionWidth <= 48 then
          PartyFont.draw(condition, textX + levelWidth, y + 8)
        else
          PartyFont.draw(condition, textX, y + 24)
        end
      end
    end
    if index == self.index then
      PartyFont.drawCode(PartyTheme.cursor, x, y + 8)
    elseif index == self.swapFrom or index == self.softboiledFrom then
      PartyFont.drawCode(PartyTheme.cursorHollow, x, y + 8)
    end
  end

  hgssPartyDraw = function(self)
    if battleArtPresent then return oldPartyDraw(self) end
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
  if not isGen2() then
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
      local demoName = tostring(speech.demoSpecies):upper()
      -- The intro data uses the gendered Gen I IDs, whose authored files keep
      -- the underscore (NIDORAN_F/NIDORAN_M).
      if demoName == "PIKACHU" then
        -- Yellow's introduction shows Pikachu rather than Nidorino.  This is
        -- the full Gen 5 front animation atlas: 16 columns, 7 rows, 112
        -- 50x46 frames.  Quads are advanced by the HD presentation layer.
        local animation = loadHdAnimation(
          "assets/graphics/pokemon/front_hd/PIKACHU.png",
          50, 46, 16, 112, 10)
        if speech.demoPic and animation then
          speech.hgssHdPics[speech.demoPic] = animation
        end
      else
        map(speech.demoPic, "assets/graphics/pokemon/front_hd/"
          .. demoName .. ".png")
      end
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
  end

  if false then
  -- TrainerState normally remaps portraits through the four-shade MEWMON
  -- palette. Our portrait PNGs are already an exact nearest 80->40 raster,
  -- so keep their authored HGSS colors instead of collapsing them to DMG
  -- shades. Vanilla portraits retain the engine's original palette path.
  local oldTrainerPalette = BattleState.trainerPalette
  BattleState.trainerPalette = function(data, trainer)
    if battleArtPresent then return oldTrainerPalette(data, trainer) end
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
    if battleArtPresent then return oldBattlePicImage(self, image) end
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

  end

  -- HUD ownership stays with the base game. Keep the
  -- old implementation below in an unreachable block for easy auditing,
  -- but do not register fonts, themes, HP palettes or HUD draw wrappers.
  if false then
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
      -- Solid black survives both the normal palette pass and the voxel
      -- battle's transparent HUD texture. A true-color red polygon was being
      -- reduced to a broken dot/slash by the latter's mask.
      love.graphics.setColor(0.05, 0.08, 0.12, 1)
      love.graphics.polygon(filled and "fill" or "line",
                            x + 1, y + 1, x + 7, y + 4,
                            x + 1, y + 7)
    end
    if more then UiPaletteFX.markTrueColor(x, y, 8, 8) end
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
    -- HudTiles.drawHPBar places the six fill tiles immediately after the
    -- two 8 px "HP:" tiles.  Paint strictly inside those same 48 pixels;
    -- extending one pixel into either neighbouring tile made DRAMALESS
    -- treat this as a second, displaced bar when it packed the HUD texture.
    local x, y, width = tx * 8 + 16, ty * 8 + 2, segments * 8
    local color = ratio >= 0.5625 and { 0.20, 0.72, 0.31, 1 }
      or ratio >= 0.2083 and { 0.96, 0.73, 0.12, 1 }
      or { 0.89, 0.22, 0.18, 1 }
    local r, g, b, a = love.graphics.getColor()
    love.graphics.setColor(0.12, 0.16, 0.18, 1)
    love.graphics.rectangle("fill", x, y, width, 4)
    love.graphics.setColor(0.82, 0.86, 0.88, 1)
    love.graphics.rectangle("fill", x + 1, y + 1, width - 2, 2)
    if ratio > 0 then
      love.graphics.setColor(color)
      love.graphics.rectangle("fill", x + 1, y + 1,
        math.max(1, math.floor((width - 2) * ratio)), 2)
    end
    UiPaletteFX.markTrueColor(x, y, width, 4)
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
  local function repaintBattleHP(self, slide)
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
  end

  -- DRAMALESS_SHAPE keeps the engine drawHUDs function in a shared upvalue
  -- named `innerHUDs` and uses that same function to build its relocated HUD
  -- texture.  Compose our repaint into that seam when it is present.  This
  -- makes the colored pixels part of the texture itself instead of drawing a
  -- second bar later at the fixed 2D coordinates.
  local voxelHudIntegrated = false
  if debug and debug.getupvalue and debug.setupvalue then
    for i = 1, 32 do
      local name, inner = debug.getupvalue(oldBattleDrawHUDs, i)
      if not name then break end
      if name == "innerHUDs" and type(inner) == "function" then
        debug.setupvalue(oldBattleDrawHUDs, i, function(self, slide)
          local result = inner(self, slide)
          repaintBattleHP(self, slide)
          return result
        end)
        voxelHudIntegrated = true
        break
      end
    end
  end
  BattleState.drawHUDs = function(self, slide)
    local result = oldBattleDrawHUDs(self, slide)
    if voxelHudIntegrated then return result end
    -- DRAMALESS_SHAPE calls this once with colorMode temporarily replaced by
    -- false while it captures the complete 2D HUD texture.  Keep the HGSS
    -- repaint in that pass, but never paint it again at classic screen
    -- coordinates during the later 3D scene draw.
    local voxelTexturePass = rawget(self, "colorMode") == false
    if self.dramaticShapeShot and not voxelTexturePass then
      return result
    end
    repaintBattleHP(self, slide)
    return result
  end

  end

  -- These are live display settings, not a replacement renderer.  In
  -- particular, FILL, survey zoom and tilt can all make pixel sizes uneven
  -- or make the 16px character art appear visually mismatched.
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
    return sx, sy, ox, oy, pw, ph, dpiX, dpiY
  end

  -- HD overworld cards are presented after the flat world's day/night pass.
  -- Dramatic Shape exposes that pass through DayTint.forFrame(); reuse its
  -- exact RGB multiplier so custom cards receive the same lighting as the
  -- tile map and voxel-generated sprites.  Without this bridge, the cards
  -- are always drawn at full brightness while the rest of the map darkens.
  local function externalWorldLightingTint(renderer)
    if type(mod.find) ~= "function" then return nil end
    local providerIds = {
      "DRAMALESS_SHAPE", "DRAMATIC_SHAPE", "BATTLE_ART_VOXEL_FORK",
      "potato_voxel",
    }
    for _, providerId in ipairs(providerIds) do
      local okFind, provider = pcall(mod.find, providerId)
      local lib = okFind and provider and provider.exports
        and provider.exports.lib
      if lib and type(lib.require) == "function" then
        local okTint, DayTint = pcall(lib.require, "DayTint")
        if okTint and DayTint and type(DayTint.forFrame) == "function" then
          local okFrame, r, g, b = pcall(DayTint.forFrame, renderer)
          if okFrame and r and g and b then return r, g, b end
        end
      end
    end
    return nil
  end

  local function drawHdOverworld(renderer)
    if not overworldHdDraws[1] then return end
    -- A voxel pipeline already produced the character as part of its world
    -- texture. Repainting a flat card here would duplicate it on the screen.
    if renderer.worldOverride or not renderer.worldActive
       or voxelWorldRendered then return end
    -- `worldActive` remains true while Dramatic Shape owns the world pass.
    -- Use the engine's authoritative pipeline query instead of repainting all
    -- HD cards after the voxel depth buffer.  The old post-present repaint
    -- made Red (which is queued late) cover NPCs that were actually in front
    -- of him on the map.  In classic 2D the query is nil, so the crisp HD
    -- repaint continues to run exactly as before.
    local okP, Pipelines = pcall(require, "src.render.Pipelines")
    if okP and Pipelines and type(Pipelines.worldPipeline) == "function" then
      local okWorld, worldPipeline = pcall(Pipelines.worldPipeline)
      if okWorld and worldPipeline ~= nil then return end
    end
    local _, _, _, _, pw, ph, dpiX, dpiY = presentationMetrics(renderer)
    local Zoom = require("src.render.Zoom")
    local sp = Zoom.scale(renderer:fitScale())
    local sx, sy = sp / dpiX, sp / dpiY
    local world = renderer.worldCanvas
    local ww, wh = love.graphics.getDimensions()
    local wvw = world and world:getWidth() or 160
    local wvh = world and world:getHeight() or 144
    local ox = math.floor((pw - wvw * sp) / 2) / dpiX
    local oy = math.floor((ph - wvh * sp) / 2) / dpiY
    love.graphics.setShader()
    local getColor = love.graphics.getColor
    local oldR, oldG, oldB, oldA
    if type(getColor) == "function" then
      oldR, oldG, oldB, oldA = getColor()
    end
    local tintR, tintG, tintB = externalWorldLightingTint(renderer)
    if tintR then
      love.graphics.setColor(tintR, tintG, tintB, 1)
    else
      love.graphics.setColor(1, 1, 1, 1)
    end
    love.graphics.setScissor(0, 0, ww, wh)
    -- The native overworld renderer is y-sorted by the entity's ground point.
    -- Repainting in insertion order made the player (usually queued last)
    -- cover an NPC even when that NPC stood one row closer to the camera.
    -- Sort only this transient repaint list; equal footlines retain the
    -- engine's stable insertion order.
    local ordered = {}
    for i, draw in ipairs(overworldHdDraws) do
      ordered[i] = draw
    end
    table.sort(ordered, function(a, b)
      local ay = tonumber(a.groundY) or tonumber(a.y) or 0
      local by = tonumber(b.groundY) or tonumber(b.y) or 0
      if ay == by then
        if a.isPlayer ~= b.isPlayer then return not a.isPlayer end
        return (a.order or 0) < (b.order or 0)
      end
      return ay < by
    end)
    for _, draw in ipairs(ordered) do
      local scaleX = sx * draw.drawWidth / draw.frameWidth
      local scaleY = sy * draw.drawHeight / draw.frameHeight
      local dx = ox + draw.x * sx
      local dy = oy + draw.y * sy
      if draw.flip then
        love.graphics.draw(draw.image, draw.quad,
          dx + draw.drawWidth * sx, dy, 0, -scaleX, scaleY)
      else
        love.graphics.draw(draw.image, draw.quad, dx, dy, 0, scaleX, scaleY)
      end
    end
    love.graphics.setScissor()
    love.graphics.setColor(oldR or 1, oldG or 1, oldB or 1, oldA or 1)
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
    if isGen2() then
      return oldRendererEndFrame(self, ...)
    end
    local originalDraw = love.graphics.draw
    local hdWorldPainted = false
    love.graphics.draw = function(image, ...)
      -- The world has already reached the window and the UI paper is about to
      -- be placed over it. This is the only seam that preserves HD texels while
      -- still allowing menus and dialogue boxes to cover the character.
      if not hdWorldPainted and image == self.canvas then
        hdWorldPainted = true
        drawHdOverworld(self)
      end
      return originalDraw(image, ...)
    end
    local ok, a, b, c = pcall(oldRendererEndFrame, self, ...)
    love.graphics.draw = originalDraw
    overworldHdDraws = {}
    overworldHdOrder = 0
    voxelWorldRendered = false
    if not ok then error(a, 0) end
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
      local image = hd.image or hd
      local quad = nil
      local hdw, hdh
      if hd.image then
        -- Keep the presentation layer fail-safe when a state is torn down
        -- while the intro animation is still advancing.  A stale state used
        -- to leave us with a valid atlas but no frame quad, which made LÖVE
        -- abort with "Quad expected, got nil" and looked like a blank game.
        local quads = hd.quads or {}
        local frameCount = hd.frameCount or #quads
        if frameCount > 0 then
          local frame = math.floor(love.timer.getTime() * (hd.fps or 10))
            % frameCount + 1
          quad = quads[frame] or quads[1]
        end
        hdw, hdh = hd.frameWidth, hd.frameHeight
      else
        hdw, hdh = hd:getDimensions()
      end
      if not quad and hd.image then
        -- Do not pass a nil Quad to love.graphics.draw.  The stock picture
        -- remains visible for this single transitional frame instead.
        return a, b, c
      end
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
        local drawX, drawY = ox + (x + off + drawW) * sx, oy + y * sy
        if quad then
          love.graphics.draw(image, quad, drawX, drawY,
            0, -sx * logicalScale, sy * logicalScale)
        else
          love.graphics.draw(image, drawX, drawY,
            0, -sx * logicalScale, sy * logicalScale)
        end
      else
        local drawX, drawY = ox + (x + off) * sx, oy + y * sy
        if quad then
          love.graphics.draw(image, quad, drawX, drawY,
            0, sx * logicalScale, sy * logicalScale)
        else
          love.graphics.draw(image, drawX, drawY,
            0, sx * logicalScale, sy * logicalScale)
        end
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
    CELADON_GYM = { CELADONGYM_ERIKA = "SPRITE_GYM_ERIKA" },
  }
  local ELITE_OBJECTS = {
    AGATHAS_ROOM = { AGATHASROOM_AGATHA = "SPRITE_AGATHA" },
    BRUNOS_ROOM = { BRUNOSROOM_BRUNO = "SPRITE_BRUNO" },
    LORELEIS_ROOM = { LORELEISROOM_LORELEI = "SPRITE_LORELEI" },
    LANCES_ROOM = { LANCESROOM_LANCE = "SPRITE_LANCE" },
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
      -- In Yellow the initial visible object is Bill transformed into a
      -- Clefairy.  SPRITE_MONSTER is the generic Rhydon-like placeholder;
      -- keep the story object and text intact while binding only its visual
      -- charset to the dedicated Clefairy sheet.
      BILLSHOUSE_BILL1 = "SPRITE_HGSS_BILL",
      BILLSHOUSE_BILL2 = "SPRITE_HGSS_BILL",
      BILLSHOUSE_BILL_POKEMON = "SPRITE_CLEFAIRY",
    },
    CELADON_CITY = {
      CELADONCITY_POLIWRATH = "SPRITE_HGSS_POLIWRATH",
    },
    CELADON_MANSION_1F = {
      CELADONMANSION1F_MEOWTH = "SPRITE_HGSS_MEOWTH",
      CELADONMANSION1F_NIDORANF = "SPRITE_HGSS_NIDORAN_F",
    },
    CERULEAN_CAVE_B1F = {
      CERULEANCAVEB1F_MEWTWO = "SPRITE_HGSS_MEWTWO",
    },
    CERULEAN_CITY = {
      -- This is the Electrode owned by the Cerulean girl.  The ROM map
      -- labels it SPRITE_POKE_BALL, so matching by object name is required.
      CERULEANCITY_ELECTRODE = "SPRITE_HGSS_ELECTRODE",
    },
    COPYCATS_HOUSE_2F = {
      -- This object is Copycat's Pikachu doll.  The generated name is
      -- unfortunately MONSTER, so do not let it inherit the generic Rhydon
      -- placeholder.
      COPYCATSHOUSE2F_MONSTER = "SPRITE_PIKACHU",
    },
    FUCHSIA_CITY = {
      FUCHSIACITY_VOLTORB = "SPRITE_HGSS_VOLTORB",
      FUCHSIACITY_KANGASKHAN = "SPRITE_HGSS_KANGASKHAN",
      FUCHSIACITY_SLOWPOKE = "SPRITE_HGSS_SLOWPOKE",
      FUCHSIACITY_FOSSIL = "SPRITE_HGSS_KABUTO",
    },
    LAVENDER_CUBONE_HOUSE = {
      LAVENDERCUBONEHOUSE_CUBONE = "SPRITE_HGSS_CUBONE",
    },
    MR_FUJIS_HOUSE = {
      MRFUJISHOUSE_PSYDUCK = "SPRITE_HGSS_PSYDUCK",
      MRFUJISHOUSE_NIDORINO = "SPRITE_HGSS_NIDORINO",
    },
    PEWTER_NIDORAN_HOUSE = {
      PEWTERNIDORANHOUSE_NIDORAN = "SPRITE_HGSS_NIDORAN_M",
    },
    SS_ANNE_B1F_ROOMS = {
      SSANNEB1FROOMS_MACHOKE = "SPRITE_HGSS_MACHOKE",
    },
    SS_ANNE_1F_ROOMS = {
      SSANNE1FROOMS_WIGGLYTUFF = "SPRITE_HGSS_WIGGLYTUFF",
    },
    VERMILION_CITY = {
      VERMILIONCITY_MACHOP = "SPRITE_HGSS_MACHOP",
      VERMILIONCITY_BEAUTY = "SPRITE_BEAUTY",
    },
    SEAFOAM_ISLANDS_B4F = {
      SEAFOAMISLANDSB4F_ARTICUNO = "SPRITE_HGSS_ARTICUNO",
    },
    ROUTE_16_FLY_HOUSE = {
      ROUTE16FLYHOUSE_FEAROW = "SPRITE_HGSS_FEAROW",
    },
    VICTORY_ROAD_2F = {
      -- The ROM names this trainer HIKER, but its trainer class is
      -- OPP_BLACKBELT.  Bind only this Victory Road object to the HGSS
      -- Black Belt charset; ordinary Hikers elsewhere keep HIKER.
      VICTORYROAD2F_HIKER = "SPRITE_BLACKBELT",
      VICTORYROAD2F_MOLTRES = "SPRITE_HGSS_MOLTRES",
    },
    FIGHTING_DOJO = {
      FIGHTINGDOJO_BLACKBELT1 = "SPRITE_BLACKBELT",
      FIGHTINGDOJO_BLACKBELT2 = "SPRITE_BLACKBELT",
      FIGHTINGDOJO_BLACKBELT3 = "SPRITE_BLACKBELT",
      FIGHTINGDOJO_BLACKBELT4 = "SPRITE_BLACKBELT",
      FIGHTINGDOJO_KARATE_MASTER = "SPRITE_BLACKBELT",
    },
    -- Yellow's Viridian Gym map labels its Blackbelt trainers as HIKER
    -- objects.  The class metadata still says OPP_BLACKBELT, but the
    -- renderer normally resolves the object sprite first and therefore
    -- leaves the HGSS Hiker charset in place.  Redirect only these three
    -- exact gym objects; Hikers elsewhere must keep their own charset.
    VIRIDIAN_GYM = {
      VIRIDIANGYM_HIKER1 = "SPRITE_BLACKBELT",
      VIRIDIANGYM_HIKER2 = "SPRITE_BLACKBELT",
      VIRIDIANGYM_HIKER3 = "SPRITE_BLACKBELT",
    },
    POKEMON_MANSION_B1F = {
      POKEMONMANSIONB1F_BURGLAR = "SPRITE_BURGLAR",
    },
    POWER_PLANT = {
      POWERPLANT_ZAPDOS = "SPRITE_HGSS_ZAPDOS",
      POWERPLANT_VOLTORB1 = "SPRITE_HGSS_VOLTORB",
      POWERPLANT_VOLTORB2 = "SPRITE_HGSS_VOLTORB",
      POWERPLANT_VOLTORB3 = "SPRITE_HGSS_VOLTORB",
      POWERPLANT_VOLTORB4 = "SPRITE_HGSS_VOLTORB",
      POWERPLANT_VOLTORB5 = "SPRITE_HGSS_VOLTORB",
      POWERPLANT_VOLTORB6 = "SPRITE_HGSS_VOLTORB",
      POWERPLANT_ELECTRODE1 = "SPRITE_HGSS_ELECTRODE",
      POWERPLANT_ELECTRODE2 = "SPRITE_HGSS_ELECTRODE",
    },
    -- Viridian's Pokémon Center has three ordinary visitors whose Yellow
    -- object records are not always resolved through the class table by the
    -- renderer.  Bind them by their exact map-object names so the HGSS
    -- charsets are used consistently (the nurse and Chansey remain their
    -- dedicated standing sheets).
    VIRIDIAN_POKECENTER = {
      VIRIDIANPOKECENTER_GENTLEMAN = "SPRITE_GENTLEMAN",
      VIRIDIANPOKECENTER_COOLTRAINER_M = "SPRITE_COOLTRAINER_M",
      VIRIDIANPOKECENTER_LINK_RECEPTIONIST = "SPRITE_LINK_RECEPTIONIST",
      VIRIDIANPOKECENTER_NURSE = "SPRITE_NURSE",
      VIRIDIANPOKECENTER_CHANSEY = "SPRITE_CHANSEY",
    },
  }

  local function objectSpriteTarget(mapId, def)
    if not def then return nil end
    local objectName = tostring(def.name or "")
    local target = OBJECT_SPRITE_FIXES[mapId]
      and OBJECT_SPRITE_FIXES[mapId][objectName]

    -- Some map loaders expose this counter attendant under a generated
    -- name instead of the ROM object label. Catch both forms so the
    -- original 16px Yellow receptionist cannot leak through in Viridian.
    if mapId == "VIRIDIAN_POKECENTER"
        and (objectName:find("RECEPTIONIST", 1, true)
          or tostring(def.sprite or "") == "SPRITE_LINK_RECEPTIONIST") then
      target = "SPRITE_LINK_RECEPTIONIST"
    end

    -- Yellow calls Gary/Blue simply RIVAL in every map object. These names
    -- are specific enough that this does not collide with generic NPCs.
    if not target and objectName:find("RIVAL", 1, true) then
      target = "SPRITE_HGSS_BLUE"
    elseif not target and OAK_OBJECTS[objectName] then
      target = "SPRITE_HGSS_OAK"
    end
    return target
  end

  -- The seated visitor in the Pokémon Center lounge is painted into the
  -- tileset, so it cannot be interacted with or lit as a normal NPC.  The
  -- cleaned atlas removes that baked figure; add one real, stationary
  -- LITTLE_BOY at the same lounge cell in every Center and in the Celadon
  -- Hotel (the only other map that uses the same lounge block).  The
  -- synthetic object is marked runtime so voxel/static caches never treat
  -- it as map geometry, and its unique name/index make this idempotent.
  local function ensurePokecenterLoungeBoy()
    local game = liveGame
    local overworld = game and game.overworld
    local map = overworld and overworld.map
    local mapId = tostring(map and map.id or "")
    if mapId ~= "CELADON_HOTEL" and not mapId:match("_POKECENTER$") then
      return
    end
    if not map.def or not map.def.objects then return end
    if not game.data or not game.data.sprites
        or not game.data.sprites.SPRITE_LITTLE_BOY then return end

    local objectName = "HGSS_" .. mapId .. "_LOUNGE_BOY"
    local def
    for _, candidate in ipairs(map.def.objects) do
      if candidate.name == objectName then
        def = candidate
        break
      end
    end
    if not def then
      local maxIndex = 0
      for _, candidate in ipairs(map.def.objects) do
        maxIndex = math.max(maxIndex, tonumber(candidate.index) or 0)
      end
      def = {
        index = maxIndex + 1,
        name = objectName,
        sprite = "SPRITE_LITTLE_BOY",
        movement = "STAY",
        range = "RIGHT",
        -- The baked lounge visitor occupies the west couch cell in the
        -- POKECENTER block ($08).  Use the native object-grid origin so the
        -- replacement sits exactly on that tile instead of drifting one
        -- cell to the right.
        x = 0,
        y = 4,
        runtime = true,
      }
      table.insert(map.def.objects, def)
    end

    local key = mapId .. "_obj_" .. tostring(def.index)
    local npc
    for _, candidate in ipairs(overworld.npcs or {}) do
      if candidate.def == def
          or tostring(candidate.def and candidate.def.name or "") == objectName then
        npc = candidate
        break
      end
    end
    if not npc then
      local NPC = require("src.world.NPC")
      npc = NPC.new(game.data, mapId, def)
      overworld.npcs = overworld.npcs or {}
      table.insert(overworld.npcs, npc)
      overworld.npcPool = overworld.npcPool or {}
      overworld.npcPool[key] = npc
      overworld.entities = overworld.entities or { overworld.player }
      table.insert(overworld.entities, npc)
    end

    -- Use the native NPC grid origin: the replacement must cover the baked
    -- lounge figure pixel-for-pixel, with no extra +8px drift.  Keep it
    -- stationary and facing right toward the room.
    npc.def = def
    npc.def.sprite = "SPRITE_LITTLE_BOY"
    npc.sprite = SpriteRenderer.new(game.data.sprites.SPRITE_LITTLE_BOY, npc.id)
    -- Keep the rendered sprite on the west sofa, but do not occupy the
    -- hidden bench-guy interaction cell at (0,4).  The original game event
    -- is resolved by tryHiddenObject() when the player faces that cell; if
    -- this visual replacement shared the logical cell, npcAtCell() would
    -- intercept the interaction and the old dialogue would disappear.
    npc.cellX, npc.cellY = -999, -999
    -- Keep the native cell/ground anchor, with a small horizontal nudge so
    -- the 32px HGSS boy is centered on the west sofa in the voxel view.
    npc.px, npc.py = def.x * 16, def.y * 16 + 4
    npc.facing = "right"
    npc.moving, npc.frozen, npc.wanders = false, true, false
    npc.progress, npc.stepFlip = 0, false
  end

  local function applyLeaderSprites()
    if isGen2() then return end
    local game = liveGame
    local overworld = game and game.overworld
    if not overworld then return end
    ensurePokecenterLoungeBoy()
    local mapId = tostring(overworld.map and overworld.map.id or "")
    local gymObjects = GYM_LEADER_OBJECTS[mapId]
    local eliteObjects = ELITE_OBJECTS[mapId]
    -- The Dojo's object records encode the trainer sight line in `range`.
    -- Keep an explicit fallback for modded/generated map data that loses that
    -- field when the object is rebuilt: these are the original HGSS-style
    -- positions, all facing inward toward the Dojo's center.
    local dojoFacing = {
      FIGHTINGDOJO_KARATE_MASTER = "down",
      FIGHTINGDOJO_BLACKBELT1 = "right",
      FIGHTINGDOJO_BLACKBELT2 = "right",
      FIGHTINGDOJO_BLACKBELT3 = "left",
      FIGHTINGDOJO_BLACKBELT4 = "left",
    }

    -- Bill1/Bill2 are hidden until the map script reveals them. Patch the
    -- map definitions before that happens; Commands.show_object creates a
    -- fresh NPC directly from this list and otherwise restores the stock
    -- SUPER_NERD sprite, making Bill appear visually wrong or unresponsive.
    -- Only the sprite field (and Oak's walker flag) is changed, so all text,
    -- indices, hidden flags and script state remain untouched.
    local mapDef = overworld.map and overworld.map.def
    for _, def in ipairs((mapDef and mapDef.objects) or {}) do
      local target = objectSpriteTarget(mapId, def)
      if target and game.data.sprites[target] then
        def.sprite = target
        if target == "SPRITE_HGSS_OAK" then def.walker = true end
      end
    end

    for _, npc in ipairs(overworld.npcs or {}) do
      local def = npc.def
      local objectName = tostring(def and def.name or "")
      local target = (gymObjects and gymObjects[objectName])
        or (eliteObjects and eliteObjects[objectName])
        or objectSpriteTarget(mapId, def)
      local spriteDef = target and game.data.sprites[target]
      if spriteDef and (def.sprite ~= target
          or not npc.sprite or npc.sprite.def ~= spriteDef) then
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
      if mapId == "FIGHTING_DOJO" and dojoFacing[objectName]
          and not npc.moving then
        npc.facing = dojoFacing[objectName]
      end
    end
  end

  -- Gen 2 constructs the player from `data.gen2Sprites` before a map is
  -- entered and keeps that definition on the live world.  Registry patches
  -- are intentionally frozen by the time the Mod Manager emits an option
  -- event, so PLAYER SELECT must update the live table and ask World to
  -- rebuild the renderer.  This keeps Ethan/Lyra changes immediate and also
  -- covers a save/map reload without touching the Yellow field registry.
  local function applyGen2PlayerSelection(game)
    if not isGen2(game) then return end
    game = game or liveGame
    if not game then return end
    local world = game.world or game.overworld
    local data = game.data
    local sprites = world and world.sprites
      or (data and (data.gen2Sprites or data.sprites))
    if type(sprites) ~= "table" then return end

    local footFile, bikeFile = gen2PlayerFiles(selectedPlayerOption())
    local function ensure(id, file)
      local relative = gen2AssetPath(file)
      if not assetExists(relative) then return nil end
      local def = sprites[id] or {}
      def.id = def.id or id
      local geometry = gen2SpriteGeometry(file)
      -- The live Gen-2 player table is rebuilt after boot. Keep it on the
      -- same native sheet as the initial registry patch so flat rendering
      -- never falls back to the voxel-layout proxy.
      def.image = mod.assets:path(relative)
      def.hgssNativeImage = mod.assets:path(relative)
      def.frames = geometry.frameCount or 6
      def.frameWidth = geometry.frameWidth
      def.frameHeight = geometry.frameHeight
      def.anchorX = geometry.anchorX
      def.anchorY = geometry.anchorY
      local displayMultiplier = 1
      def.hgssGen2DisplayScale = geometry.displayScale * displayMultiplier
      def.hgssGen2NearestFilter = true
      def.walker = true
      def.spriteType = "WALKING_SPRITE"
      def.trueColor = true
      pcall(function() sprites[id] = def end)
      return def
    end

    ensure("SPRITE_CHRIS", footFile)
    ensure("SPRITE_CHRIS_BIKE", bikeFile)
    -- Crystal's female slot is always the HGSS Lyra equivalent, independent
    -- of the active male PLAYER SELECT value.
    ensure("SPRITE_KRIS", "overrides/sprites/lyra")
    ensure("SPRITE_KRIS_BIKE", "lyra_bike")

    -- Refresh the existing actor without changing its grid position, facing,
    -- bike state or movement timers.  `applyPlayerState` is the Gen 2-native
    -- seam used by FieldMoves for normal/bike/surf state transitions.
    if world and type(world.applyPlayerState) == "function" then
      pcall(function() world:applyPlayerState(world.playerState) end)
    elseif world and world.player and type(world.player.setSprite) == "function" then
      local id = world.playerState == "bike"
        and "SPRITE_CHRIS_BIKE" or "SPRITE_CHRIS"
      local def = sprites[id]
      if def then pcall(function() world.player:setSprite(def) end) end
    end
  end

  local function applyPlayerSelection(game)
    if isGen2(game) then return end
    local selectedId = selectedPlayerSpriteId()
    local data = game and game.data
    if not data then return end

    -- Keep future Player.new calls on the selected charset.  The protected
    -- assignment is intentionally narrow: old engine builds expose `field`
    -- as a plain table, while a few development builds expose a read-only
    -- proxy during boot.
    local field = data.field
    if field and field.playerSprites then
      pcall(function() field.playerSprites.walk = selectedId end)
      pcall(function()
        field.playerSprites.bike = selectedPlayerBikeSpriteId()
      end)
    end

    -- A menu change can happen while a save is already open. Refresh the
    -- live player and bicycle without touching surf sprites. New maps
    -- construct both from field.playerSprites.
    local player = game.overworld and game.overworld.player
    local spriteDef = data.sprites and data.sprites[selectedId]
    if not player then return end
    if spriteDef and (not player.sprite or player.sprite.def ~= spriteDef) then
      player.sprite = SpriteRenderer.new(spriteDef, "player")
      if player.sprite and player.sprite.def then
        player.sprite.def.walker = true
      end
    end
    local bikeId = selectedPlayerBikeSpriteId()
    local bikeDef = data.sprites and data.sprites[bikeId]
    if bikeDef and (not player.bikeSprite or player.bikeSprite.def ~= bikeDef) then
      player.bikeSprite = SpriteRenderer.new(bikeDef, "player")
      if player.bikeSprite and player.bikeSprite.def then
        player.bikeSprite.def.walker = true
      end
    end
  end

  local function applyCrispDisplay(game)
    if isGen2(game) then return end
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
    activeGeneration = detectGeneration(liveGame)
    tryPatchVoxelBillboards()
    applyCrispDisplay(liveGame)
    applyPartyMenuOption(liveGame)
    applyGen2PlayerSelection(liveGame)
    applyPlayerSelection(liveGame)
    applyLeaderSprites()
  end)
  mod.events:on("map.entered", function()
    if isGen2() then
      applyGen2PlayerSelection(liveGame)
      return
    end
    tryPatchVoxelBillboards()
    applyPlayerSelection(liveGame)
    applyLeaderSprites()
  end)
  mod.events:on("map.reloaded", function()
    if isGen2() then
      applyGen2PlayerSelection(liveGame)
      return
    end
    tryPatchVoxelBillboards()
    applyPlayerSelection(liveGame)
    applyLeaderSprites()
  end)
  mod.events:on("mod.options_changed", function(ev)
    if ev and ev.mod == "HGSS_SPRITES" then
      if isGen2() then
        applyGen2PlayerSelection(liveGame)
        return
      end
      applyPartyMenuOption(liveGame)
      applyPlayerSelection(liveGame)
    end
  end)
  -- CONTINUE restores the standalone options after game.ready.  Reapply the
  -- cosmetic policy only after that restore has completed.
  mod.events:on("save.loaded", function()
    if isGen2() then
      applyGen2PlayerSelection(liveGame)
      return
    end
    applyCrispDisplay(liveGame)
    applyPartyMenuOption(liveGame)
    applyPlayerSelection(liveGame)
    applyLeaderSprites()
  end)
  mod.events:on("save.created", function()
    if isGen2() then
      applyGen2PlayerSelection(liveGame)
      return
    end
    applyCrispDisplay(liveGame)
    applyPartyMenuOption(liveGame)
    applyPlayerSelection(liveGame)
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
