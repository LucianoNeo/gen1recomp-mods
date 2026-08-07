--[[
    HGSS Visual Overhaul — main.lua
    ================================
    Official Gen1Recomp Mod Entry Point.
    v1.2.0 — Native 32x32 DS Scale Rendering (No Downscaling!)
]]

return function(mod)
    print("========================================")
    print("  HGSS Visual Overhaul v1.2.0")
    print("  Loading Native DS 32x32 Overworld Scale...")
    print("========================================")

    local POKEMON_LIST = {
        "BULBASAUR", "IVYSAUR", "VENUSAUR",
        "CHARMANDER", "CHARMELEON", "CHARIZARD",
        "SQUIRTLE", "WARTORTLE", "BLASTOISE",
        "CATERPIE", "METAPOD", "BUTTERFREE",
        "WEEDLE", "KAKUNA", "BEEDRILL",
        "PIDGEY", "PIDGEOTTO", "PIDGEOT",
        "RATTATA", "RATICATE",
        "SPEAROW", "FEAROW",
        "EKANS", "ARBOK",
        "PIKACHU", "RAICHU",
        "SANDSHREW", "SANDSLASH",
        "NIDORAN_F", "NIDORINA", "NIDOQUEEN",
        "NIDORAN_M", "NIDORINO", "NIDOKING",
        "CLEFAIRY", "CLEFABLE",
        "VULPIX", "NINETALES",
        "JIGGLYPUFF", "WIGGLYTUFF",
        "ZUBAT", "GOLBAT",
        "ODDISH", "GLOOM", "VILEPLUME",
        "PARAS", "PARASECT",
        "VENONAT", "VENOMOTH",
        "DIGLETT", "DUGTRIO",
        "MEOWTH", "PERSIAN",
        "PSYDUCK", "GOLDUCK",
        "MANKEY", "PRIMEAPE",
        "GROWLITHE", "ARCANINE",
        "POLIWAG", "POLIWHIRL", "POLIWRATH",
        "ABRA", "KADABRA", "ALAKAZAM",
        "MACHOP", "MACHOKE", "MACHAMP",
        "BELLSPROUT", "WEEPINBELL", "VICTREEBEL",
        "TENTACOOL", "TENTACRUEL",
        "GEODUDE", "GRAVELER", "GOLEM",
        "PONYTA", "RAPIDASH",
        "SLOWPOKE", "SLOWBRO",
        "MAGNEMITE", "MAGNETON",
        "FARFETCHD",
        "DODUO", "DODRIO",
        "SEEL", "DEWGONG",
        "GRIMER", "MUK",
        "SHELLDER", "CLOYSTER",
        "GASTLY", "HAUNTER", "GENGAR",
        "ONIX",
        "DROWZEE", "HYPNO",
        "KRABBY", "KINGLER",
        "VOLTORB", "ELECTRODE",
        "EXEGGCUTE", "EXEGGUTOR",
        "CUBONE", "MAROWAK",
        "HITMONLEE", "HITMONCHAN",
        "LICKITUNG",
        "KOFFING", "WEEZING",
        "RHYHORN", "RHYDON",
        "CHANSEY",
        "TANGELA",
        "KANGASKHAN",
        "HORSEA", "SEADRA",
        "GOLDEEN", "SEAKING",
        "STARYU", "STARMIE",
        "MR_MIME",
        "SCYTHER",
        "JYNX",
        "ELECTABUZZ",
        "MAGMAR",
        "PINSIR",
        "TAUROS",
        "MAGIKARP", "GYARADOS",
        "LAPRAS",
        "DITTO",
        "EEVEE", "VAPOREON", "JOLTEON", "FLAREON",
        "PORYGON",
        "OMANYTE", "OMASTAR",
        "KABUTO", "KABUTOPS",
        "AERODACTYL",
        "SNORLAX",
        "ARTICUNO", "ZAPDOS", "MOLTRES",
        "DRATINI", "DRAGONAIR", "DRAGONITE",
        "MEWTWO",
        "MEW",
    }

    -- 1. Patch trueColor = true for all 151 Pokemon battle sprites
    if mod and mod.content and mod.content.pokemon then
        pcall(function()
            for _, species in ipairs(POKEMON_LIST) do
                local key = species:lower()
                if key == "nidoran_f" then key = "nidoranf"
                elseif key == "nidoran_m" then key = "nidoranm"
                elseif key == "mr_mime" then key = "mr.mime"
                end

                local f_path = mod.path .. "/overrides/battle/front/" .. key .. ".png"
                local b_path = mod.path .. "/overrides/battle/back/" .. key .. "b.png"

                mod.content.pokemon:patch(species, {
                    spriteFront = f_path,
                    spriteBack = b_path,
                    trueColor = true,
                })
            end
        end)
    end

    -- 2. Patch trueColor = true for replaced character overworld sprites
    if mod and mod.content and mod.content.sprites then
        pcall(function()
            mod.content.sprites:patch("SPRITE_RED",           { trueColor = true })
            mod.content.sprites:patch("SPRITE_RED_BIKE",      { trueColor = true })
            mod.content.sprites:patch("SPRITE_OAK",           { trueColor = true })
            mod.content.sprites:patch("SPRITE_BLUE",          { trueColor = true })
            mod.content.sprites:patch("SPRITE_SURFING_PIKACHU", { trueColor = true })
        end)
    end

    -- 3. Native HGSS 32x32 Scale Overworld Renderer (100% Crisp DS Scale, 1x 1:1 Pixel Ratio)
    --    Format: 32px wide x 192px tall = 6 frames of 32x32
    pcall(function()
        local SpriteRenderer = require("src.render.SpriteRenderer")
        local PaletteFX = require("src.render.PaletteFX")

        local oldNew = SpriteRenderer.new
        function SpriteRenderer.new(spriteDef, seed)
            local self = oldNew(spriteDef, seed)
            if self and self.image then
                local iw, ih = self.image:getDimensions()
                if iw == 32 and ih == 192 then
                    self.frames = {}
                    for f = 0, 5 do
                        self.frames[f] = love.graphics.newQuad(0, f * 32, 32, 32, 32, 192)
                    end
                    self.isHgssStrip = true
                    print("[HGSS] Registered 1:1 Native DS 32x32 overworld sprite: " .. tostring(spriteDef and spriteDef.id or "?"))
                end
            end
            return self
        end

        local oldDraw = SpriteRenderer.draw
        function SpriteRenderer:draw(px, py, camX, camY, facing, walkPhase, stepFlip, topHalf)
            if self.isHgssStrip then
                local x = math.floor(px - camX)
                local y = math.floor(py - camY)

                -- Draw at full 1x native DS scale (32x32 pixels per frame)
                local sx = 1.0
                local sy = 1.0
                local drawW = 32
                local drawH = 32

                -- Frame mapping:
                -- 0=StandDown, 1=WalkDown, 2=StandUp, 3=WalkUp, 4=StandLeft, 5=WalkLeft
                local STAND = { down = 0, up = 2, left = 4, right = 4 }
                local WALK  = { down = 1, up = 3, left = 5, right = 5 }

                local isWalking = self.def and self.def.walker and (walkPhase == 1)
                local frameIdx = isWalking and WALK[facing] or STAND[facing]
                local quad = self.frames[frameIdx] or self.frames[0]

                local flip = (facing == "right")

                -- Center horizontally over 16px tile (x - 8), bottom-align (y - 16)
                local drawX = x - 8
                local drawY = y - 16

                if self.def and self.def.trueColor and PaletteFX and PaletteFX.markTrueColor then
                    PaletteFX.markTrueColor(math.floor(drawX), math.floor(drawY), 32, 32)
                end

                if flip then
                    -- Mirror: draw at x + 24 (drawX + 32) and scale x by -1.0
                    love.graphics.draw(self.image, quad,
                        math.floor(drawX + 32), math.floor(drawY),
                        0, -sx, sy)
                else
                    love.graphics.draw(self.image, quad,
                        math.floor(drawX), math.floor(drawY),
                        0, sx, sy)
                end
                return
            end
            return oldDraw(self, px, py, camX, camY, facing, walkPhase, stepFlip, topHalf)
        end
    end)

    -- 4. Install Runtime Hooks to enforce trueColor = true on runtime loads
    if mod and mod.hooks then
        pcall(function()
            mod.hooks:wrap("pokemon.sprite", function(next, samePath, path, ctx)
                if ctx then ctx.trueColor = true end
                local species = ctx and ctx.species
                local side = ctx and ctx.side
                if species then
                    local key = tostring(species):lower()
                    if key == "nidoran_f" then key = "nidoranf"
                    elseif key == "nidoran_m" then key = "nidoranm"
                    elseif key == "mr_mime" then key = "mr.mime"
                    end

                    if side == "back" then
                        local cand = mod.path .. "/overrides/battle/back/" .. key .. "b.png"
                        if love.filesystem and love.filesystem.getInfo and love.filesystem.getInfo(cand) then
                            return cand
                        end
                    else
                        local cand = mod.path .. "/overrides/battle/front/" .. key .. ".png"
                        if love.filesystem and love.filesystem.getInfo and love.filesystem.getInfo(cand) then
                            return cand
                        end
                    end
                end
                return next(samePath, path, ctx)
            end)
        end)

        pcall(function()
            mod.hooks:wrap("player.sprite", function(next, samePath, path, ctx)
                if ctx then ctx.trueColor = true end
                local side = ctx and ctx.side
                if side == "back" then
                    return mod.path .. "/overrides/battle/redb.png"
                end
                return next(samePath, path, ctx)
            end)
        end)
    end

    print("[HGSS] v1.2.0 initialized — 1:1 Native DS 32x32 overworld renderer active!")
end
