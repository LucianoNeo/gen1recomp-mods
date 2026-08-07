--[[
    HGSS Visual Overhaul — main.lua
    ================================
    Official Gen1Recomp Mod Entry Point.
    v1.4.0 — Fixed Pokemon Back/Front Battle Scaling (80x80 NDS -> 0.7x = 56px)
]]

return function(mod)
    print("========================================")
    print("  HGSS Visual Overhaul v1.4.0")
    print("  Loading 32-bit TrueColor & 0.7x Scaled Battle Sprites...")
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

    -- 1. Patch trueColor = true & battleScale (0.7x = 56px) for all 151 Pokemon
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
                    battleScaleFront = 0.7,
                    battleScaleBack = 0.7,
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
                local drawW = 32
                local drawH = 32

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

    -- 4. BATTLE TRAINER SPRITES: 32-bit RGBA TrueColor & Correct 56px Battle Scale
    pcall(function()
        local BattleState = require("src.battle.BattleState")
        local PaletteFX = require("src.render.PaletteFX")

        local oldDrawPicsLayer = BattleState.drawPicsLayer
        function BattleState:drawPicsLayer(slide, sx, sy, onlySide, skipMenuClip)
            local g = love.graphics

            -- Enemy Trainer Front Sprite (e.g., Gary / Blue / Oak / Brock)
            if onlySide ~= "player" and self.showEnemyTrainer and self.trainerPic then
                local img = self:picImage(self.trainerPic)
                if img then
                    local w, h = img:getWidth(), img:getHeight()
                    local s = (w > 56) and (56 / w) or 1.0
                    local tw = math.min(7, math.max(1, math.floor(w / 8)))
                    local th = math.min(7, math.max(1, math.floor(h / 8)))
                    local hPad = math.floor((8 - tw) / 2)
                    local vPad = 7 - th
                    local ex = 96 + 8 * hPad - slide + sx
                    local ey = 8 * vPad + sy

                    local dx = ex + w * (1 - s) / 2
                    local dy = ey + h * (1 - s)

                    if PaletteFX and PaletteFX.markTrueColor then
                        PaletteFX.markTrueColor(math.floor(dx), math.floor(dy), math.ceil(w * s), math.ceil(h * s))
                    end

                    g.setColor(1, 1, 1, 1)
                    g.draw(img, math.floor(dx + self:picOffset("foe")), math.floor(dy), 0, s, s)
                end
            end

            -- Player Trainer Back Sprite (Red back view)
            if onlySide ~= "enemy" and self.showPlayerBack and self.playerBackPic then
                local img = self:picImage(self.playerBackPic)
                if img then
                    local w, h = img:getWidth(), img:getHeight()
                    local s = (w > 56) and (56 / w) or 1.0
                    local dx = 8 + slide + sx + self:picOffset("back")
                    local dy = 96 - (h * s) + sy

                    if PaletteFX and PaletteFX.markTrueColor then
                        PaletteFX.markTrueColor(math.floor(dx), math.floor(dy), math.ceil(w * s), math.ceil(h * s))
                    end

                    g.setColor(1, 1, 1, 1)
                    g.draw(img, math.floor(dx), math.floor(dy), 0, s, s)
                end
            end

            local saveShowEnemy = self.showEnemyTrainer
            local saveShowBack = self.showPlayerBack
            self.showEnemyTrainer = false
            self.showPlayerBack = false

            oldDrawPicsLayer(self, slide, sx, sy, onlySide, skipMenuClip)

            self.showEnemyTrainer = saveShowEnemy
            self.showPlayerBack = saveShowBack
        end
    end)

    -- 5. Install Runtime Hooks to enforce trueColor & 0.7x scale on runtime loads
    if mod and mod.hooks then
        pcall(function()
            mod.hooks:wrap("pokemon.sprite", function(next, samePath, path, ctx)
                if ctx then
                    ctx.trueColor = true
                end
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

    print("[HGSS] v1.4.0 initialized — Pokemon Battle Scale 0.7x (80x80 NDS -> 56px) Active!")
end
