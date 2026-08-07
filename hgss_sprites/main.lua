--[[
    HGSS Visual Overhaul — main.lua
    ================================
    Official Gen1Recomp Mod Entry Point.
    v1.7.0 — Original Full-Quality DS Assets with Code-Based 0.65x Proportional Scale
]]

return function(mod)
    print("========================================")
    print("  HGSS Visual Overhaul v1.7.0")
    print("  Applying Code-Based Proportional Scaling (0.65x) to Full-Quality DS Assets...")
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
        "TANGELA", "KANGASKHAN",
        "HORSEA", "SEADRA",
        "GOLDEEN", "SEAKING",
        "STARYU", "STARMIE",
        "MR_MIME", "SCYTHER", "JYNX",
        "ELECTABUZZ", "MAGMAR", "PINSIR", "TAUROS",
        "MAGIKARP", "GYARADOS", "LAPRAS", "DITTO",
        "EEVEE", "VAPOREON", "JOLTEON", "FLAREON",
        "PORYGON", "OMANYTE", "OMASTAR",
        "KABUTO", "KABUTOPS", "AERODACTYL",
        "SNORLAX", "ARTICUNO", "ZAPDOS", "MOLTRES",
        "DRATINI", "DRAGONAIR", "DRAGONITE",
        "MEWTWO", "MEW",
    }

    -- 1. Patch trueColor = true & battleScale (0.65x) for all 151 Pokemon
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
                    battleScaleFront = 0.65,
                    battleScaleBack = 0.65,
                    trueColor = true,
                })
            end
        end)
    end

    -- 2. Patch trueColor = true for overworld sprites
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
                end
            end
            return self
        end

        local oldDraw = SpriteRenderer.draw
        function SpriteRenderer:draw(px, py, camX, camY, facing, walkPhase, stepFlip, topHalf)
            if self.isHgssStrip then
                local x = math.floor(px - camX)
                local y = math.floor(py - camY)

                local sx = 1.0
                local sy = 1.0

                local STAND = { down = 0, up = 2, left = 4, right = 4 }
                local WALK  = { down = 1, up = 3, left = 5, right = 5 }

                local isWalking = self.def and self.def.walker and (walkPhase == 1)
                local frameIdx = isWalking and WALK[facing] or STAND[facing]
                local quad = self.frames[frameIdx] or self.frames[0]

                local flip = (facing == "right")

                local drawX = x - 8
                local drawY = y - 16

                if self.def and self.def.trueColor and PaletteFX and PaletteFX.markTrueColor then
                    PaletteFX.markTrueColor(math.floor(drawX), math.floor(drawY), 32, 32)
                end

                if flip then
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

    -- 4. BATTLE RESOLUTION & SCALING HOOKS (0.65x Scale + Pure 32-bit RGBA)
    pcall(function()
        local Sprites = require("src.pokemon.Sprites")
        local BattleState = require("src.battle.BattleState")
        local PaletteFX = require("src.render.PaletteFX")

        if BattleState.invalidate then
            BattleState.invalidate()
        end

        -- Force battle scale to 0.65x for all 80x80 battle sprites (trainers, player back, pokemon)
        local oldResolveBattleScale = BattleState.resolveBattleScale
        function BattleState.resolveBattleScale(data, side, path, species)
            if path and (path:find("redb") or path:find("trainers") or path:find("battle") or path:find("overrides")) then
                return 0.65
            end
            return 0.65
        end

        -- Ensure player back pic returns trueColor = true
        local oldPlayerPath = Sprites.playerPath
        function Sprites.playerPath(data, side, opts)
            local path, _ = oldPlayerPath(data, side, opts)
            if side == "back" then
                return mod.path .. "/overrides/battle/redb.png", true
            end
            return path, true
        end

        -- Return NIL for trainer palettes so getImage does NOT run id:mapPixel (prevents 2bpp DMG color corruption)
        local oldTrainerPalette = BattleState.trainerPalette
        function BattleState.trainerPalette(data, trainer)
            return nil
        end

        -- Ensure trainerPicPath resolves mod trainer images
        local oldTrainerPicPath = BattleState.trainerPicPath
        function BattleState.trainerPicPath(data, trainer, oppClass, partyIndex)
            if trainer and trainer.pic then
                local p1 = mod.path .. "/overrides/" .. tostring(trainer.pic)
                local p2 = mod.path .. "/overrides/battle/trainers/" .. tostring(trainer.pic)
                if love.filesystem and love.filesystem.getInfo then
                    if love.filesystem.getInfo(p1) then return p1 end
                    if love.filesystem.getInfo(p2) then return p2 end
                end
            end
            return oldTrainerPicPath(data, trainer, oppClass, partyIndex)
        end

        -- Wrap BattleState:drawPicsLayer to force PaletteFX.setPass("ui") and markTrueColor for both sides
        local oldDrawPicsLayer = BattleState.drawPicsLayer
        function BattleState:drawPicsLayer(slide, sx, sy, onlySide, skipMenuClip)
            if PaletteFX and PaletteFX.setPass then
                PaletteFX.setPass("ui")
            end

            local s = 0.65

            -- Mark TrueColor zone for enemy trainer pic
            if onlySide ~= "player" and self.showEnemyTrainer and self.trainerPic then
                local img = self:picImage(self.trainerPic)
                if img then
                    local w, h = img:getWidth(), img:getHeight()
                    local ex = 96 - slide + sx
                    local ey = sy
                    local dx, dy = ex + w * (1 - s) / 2, ey + h * (1 - s)
                    if PaletteFX and PaletteFX.markTrueColor then
                        PaletteFX.markTrueColor(math.floor(dx), math.floor(dy), math.ceil(w * s), math.ceil(h * s))
                    end
                end
            end

            -- Mark TrueColor zone for player back pic (Red back)
            if onlySide ~= "enemy" and self.showPlayerBack and self.playerBackPic then
                local img = self:picImage(self.playerBackPic)
                if img then
                    local w, h = img:getWidth(), img:getHeight()
                    local dx = 8 + slide + sx + self:picOffset("back")
                    local dy = 96 - (h * s) + sy
                    if PaletteFX and PaletteFX.markTrueColor then
                        PaletteFX.markTrueColor(math.floor(dx), math.floor(dy), math.ceil(w * s), math.ceil(h * s))
                    end
                end
            end

            return oldDrawPicsLayer(self, slide, sx, sy, onlySide, skipMenuClip)
        end
    end)

    print("[HGSS] v1.7.0 initialized — 0.65x Code-Based Battle Scaling & Full-Quality 32-bit Assets Active!")
end
