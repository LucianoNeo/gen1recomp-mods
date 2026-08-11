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
  -- Overworld sheets use Red's six-frame layout. Scientist remains 32x192;
  -- keeping its old 48px frame height samples adjacent cells and produces
  -- oversized/garbled sprites. Jessie and James carry the same layout at 4x.
  -- Team Rocket keeps a 4x authored sheet. It is still presented in the same
  -- 32x32 logical box as Red; the extra texels preserve the generated art
  -- instead of baking it down to a 20x24 miniature before rendering.
  local playerSheet = file == "ash" or file == "ethan"
  local hdSheet = file == "gym_sabrina" or file == "gym_erika"
    or file == "agatha" or file == "officer_jenny"
    or file == "jessie" or file == "james" or file == "lorelei"
    or playerSheet
  local highDensity = file == "jessie" or file == "james" or hdSheet
  local nativeWide = file == "jessie" or file == "james"
    or file == "lorelei" or playerSheet
  -- Jessie/James, Ash and Ethan use 256px-wide authored frames; match the
  -- source cell so the renderer samples each complete frame instead of
  -- shrinking it or cutting off the head and feet.
  local frameSize = (file == "jessie" or file == "james"
      or playerSheet) and 256
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
  -- Ash and Ethan are supplied as 28px logical cells so the optional player
  -- sprites keep exactly the same map footprint as the corrected Red sheet.
  local displaySize = playerSheet and 28 or 32
  -- The HGSS Red sheet has transparent rows below the shoe pixels.  Keep the
  -- source images untouched and lower each voxel entity relative to its
  -- ground shadow; 2D rendering and map coordinates remain unchanged.
  -- The voxel renderer's 16px ground anchor is shared by all overworld
  -- charsets.  HGSS frames leave the same transparent rows beneath the
  -- shoes, so apply the small grounding correction to every replacement
  -- character (not just the player).
  local voxelEntityYOffset = -4
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
  local voxelHeight = displaySize
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
    frames = frames,
    walker = walker,
    trueColor = true,
    hgssFrameWidth = frameSize,
    hgssFrameHeight = frameHeight,
    hgssDrawWidth = displaySize,
    hgssDrawHeight = displaySize,
    hgssLinearFilter = frameSize > 32,
    hgssPostPresent = highDensity,
    hgssVoxelWidth = voxelWidth,
    hgssVoxelHeight = voxelHeight,
    hgssVoxelEntityYOffset = voxelEntityYOffset,
  })
end

return function(mod)
  -- Battle Art Voxel Fork owns battle artwork. This companion only supplies
  -- the intro portraits and HGSS overworld charsets.

  local function isHgssTrueColorPath(path)
    if type(path) ~= "string" then return false end
    path = path:gsub("\\", "/")
    return path:find("overrides/sprites/", 1, true) ~= nil
        or path:find("overrides/title/", 1, true) ~= nil
        or path:find("assets/icons/", 1, true) ~= nil
  end

  local function loadHdImage(path)
    local ok, image = pcall(love.graphics.newImage, mod.assets:path(path))
    if not ok or not image then return nil end
    image:setFilter("linear", "linear")
    return image
  end

  mod.options:define({
    {
      key = "player_select",
      label = "PLAYER SELECT",
      type = "choice",
      default = "red",
      choices = {
        { "RED", "red" },
        { "ASH", "ash" },
        { "ETHAN", "ethan" },
      },
    },
    {
      key = "party_menu",
      label = "PARTY MENU",
      type = "toggle",
      default = true,
    },
    {
      key = "crisp_display",
      label = "CRISP DISPLAY",
      type = "toggle",
      default = false,
    },
  })

  local PLAYER_SPRITE_IDS = {
    red = "SPRITE_RED",
    ash = "SPRITE_ASH",
    ethan = "SPRITE_ETHAN",
  }

  local function selectedPlayerSpriteId()
    return PLAYER_SPRITE_IDS[mod.options:get("player_select") or "red"]
      or PLAYER_SPRITE_IDS.red
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

  -- The selector changes only the field player charset.  Battle Art Voxel
  -- Fork remains the owner of battle trainer art, while the selected native
  -- sheet is used for the overworld player and the Oak intro player slot.
  mod.content.field:patch("playerSprites", {
    walk = selectedPlayerSpriteId(),
  })

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

    -- The voxel card and its shadow share a mesh.  Moving that mesh moves
    -- both together, so it cannot correct a character that appears to float
    -- above its ground shadow.  Patch the cast's entity call instead: every
    -- replacement character is lowered, while the shadow remains anchored
    -- to the map.
    local scene
    for i = 1, 32 do
      local name, value = debug.getupvalue(voxel.drawWorld, i)
      if not name then break end
      if name == "VoxelScene" and type(value) == "table" then scene = value; break end
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
    if drawCast then
      for i = 1, 16 do
        local name, value = debug.getupvalue(drawCast, i)
        if not name then break end
        if name == "drawEntity" and type(value) == "function" then
          local oldEntity = value
          local function anchoredEntity(sprite, px, py, facing, phase, flip,
                                        gh, colors, lift)
            local def = sprite and sprite.def
            if def and def.hgssVoxelEntityYOffset and def.hgssNativeImage then
              gh = gh + (tonumber(def.hgssVoxelEntityYOffset) or 0)
            end
            return oldEntity(sprite, px, py, facing, phase, flip, gh, colors, lift)
          end
          debug.setupvalue(drawCast, i, anchoredEntity)
          break
        end
      end
    end

    voxelBillboardsPatched = true
  end

  SpriteRenderer.new = function(spriteDef, seed)
    patchVoxelBillboards()
    local self = oldNew(spriteDef, seed)
    if self and spriteDef and spriteDef.hgssNativeImage then
      self.image = SpriteAssets.image(spriteDef.hgssNativeImage)
      if spriteDef.hgssLinearFilter and self.image.setFilter then
        self.image:setFilter("linear", "linear")
      end
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
    -- Keep the same authored size and anchor as the known-good 0.0.26
    -- renderer.  Charset corrections are image replacements only; changing
    -- the runtime scale here makes every overworld character inconsistent.
    local drawW = tonumber(self.def.hgssDrawWidth) or fw
    local drawH = tonumber(self.def.hgssDrawHeight) or fh
    local scaleX, scaleY = drawW / fw, drawH / fh
    local x = math.floor(px - camX) - math.floor(drawW / 2) + 8
    local y = math.floor(py - camY) - drawH + 16
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
    -- Gen I stores one walking pose for each direction.  Consecutive
    -- vertical steps alternate the leading foot by mirroring that pose;
    -- ignoring stepFlip made Blue/Gary (and other native 32px walkers)
    -- repeat one leg and visibly slide/limp through scripted movement.
    local flip = facing == "right"
      or ((facing == "down" or facing == "up")
          and self.def.walker and walkPhase == 1 and stepFlip)
    if self.def.hgssPostPresent then
      overworldHdDraws[#overworldHdDraws + 1] = {
        image = image, quad = quad, x = x, y = y,
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
  -- battle art remains separate, while the 32px HGSS party icons stay active.
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

  local function applyPartyMenuOption(game)
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
    end
    return partyIconImages[resolved] or nil
  end

  hgssPartyDrawIcon = function(game, mon, x, y, selected, counter, forceAlt)
    if battleArtPresent then
      return oldPartyDrawIcon(game, mon, x, y, selected, counter, forceAlt)
    end
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
      local demoName = speech.demoSpecies
      -- The intro data uses the gendered Gen I IDs, whose authored files keep
      -- the underscore (NIDORAN_F/NIDORAN_M).
      map(speech.demoPic, "assets/graphics/pokemon/front_hd/"
        .. tostring(demoName):upper() .. ".png")
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

  -- HUD ownership stays with the base game/Battle Art Voxel Fork.  Keep the
  -- old implementation below in an unreachable block for easy auditing,
  -- but do not register fonts, themes, HP palettes or HUD draw wrappers.
  local liveGame
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

  local function drawHdOverworld(renderer)
    if not overworldHdDraws[1] then return end
    -- A voxel pipeline already produced the character as part of its world
    -- texture. Repainting a flat card here would duplicate it on the screen.
    if renderer.worldOverride or not renderer.worldActive then return end
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
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setScissor(0, 0, ww, wh)
    for _, draw in ipairs(overworldHdDraws) do
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

  local function applyLeaderSprites()
    local game = liveGame
    local overworld = game and game.overworld
    if not overworld or not overworld.npcs then return end
    local mapId = tostring(overworld.map and overworld.map.id or "")
    local gymObjects = GYM_LEADER_OBJECTS[mapId]
    local eliteObjects = ELITE_OBJECTS[mapId]
    local objectFixes = OBJECT_SPRITE_FIXES[mapId]
    for _, npc in ipairs(overworld.npcs) do
      local def = npc.def
      local objectName = tostring(def and def.name or "")
      local target = (gymObjects and gymObjects[objectName])
        or (eliteObjects and eliteObjects[objectName])
        or (objectFixes and objectFixes[objectName])
      -- Some map loaders expose this counter attendant under a generated
      -- name instead of the ROM object label. Catch both forms so the
      -- original 16px Yellow receptionist cannot leak through in Viridian.
      if mapId == "VIRIDIAN_POKECENTER"
          and (objectName:find("RECEPTIONIST", 1, true)
            or tostring(def and def.sprite or "") == "SPRITE_LINK_RECEPTIONIST") then
        target = "SPRITE_LINK_RECEPTIONIST"
      end
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

  local function applyPlayerSelection(game)
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
    end

    -- A menu change can happen while a save is already open. Refresh the
    -- live player without touching surf/bike sprites or Battle Art's trainer
    -- presentation. New maps will construct the same selected sprite from
    -- field.playerSprites.walk.
    local player = game.overworld and game.overworld.player
    local spriteDef = data.sprites and data.sprites[selectedId]
    if not player or not spriteDef then return end
    if player.sprite and player.sprite.def == spriteDef then return end
    player.sprite = SpriteRenderer.new(spriteDef, "player")
    if player.sprite and player.sprite.def then
      player.sprite.def.walker = true
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
    applyPartyMenuOption(liveGame)
    applyPlayerSelection(liveGame)
    applyLeaderSprites()
  end)
  mod.events:on("map.entered", function()
    applyPlayerSelection(liveGame)
    applyLeaderSprites()
  end)
  mod.events:on("map.reloaded", function()
    applyPlayerSelection(liveGame)
    applyLeaderSprites()
  end)
  mod.events:on("mod.options_changed", function(ev)
    if ev and ev.mod == "HGSS_SPRITES" then
      applyPartyMenuOption(liveGame)
      applyPlayerSelection(liveGame)
    end
  end)
  -- CONTINUE restores the standalone options after game.ready.  Reapply the
  -- cosmetic policy only after that restore has completed.
  mod.events:on("save.loaded", function()
    applyCrispDisplay(liveGame)
    applyPartyMenuOption(liveGame)
    applyPlayerSelection(liveGame)
    applyLeaderSprites()
  end)
  mod.events:on("save.created", function()
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
