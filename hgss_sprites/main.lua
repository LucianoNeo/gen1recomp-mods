--[[
    HGSS Visual Overhaul — main.lua
    ================================
    Official Gen1Recomp Mod Entry Point.
]]

return function(mod)
    print("========================================")
    print("  HGSS Visual Overhaul v1.0.5")
    print("  Loading HeartGold/SoulSilver sprites...")
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

    -- 1. Patch trueColor = true for all 151 Pokémon battle sprites
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

    -- 2. Patch trueColor = true for replaced character overworld sprites (Red, Oak, Blue)
    if mod and mod.content and mod.content.sprites then
        pcall(function()
            mod.content.sprites:patch("SPRITE_RED", { trueColor = true })
            mod.content.sprites:patch("SPRITE_RED_BIKE", { trueColor = true })
            mod.content.sprites:patch("SPRITE_OAK", { trueColor = true })
            mod.content.sprites:patch("SPRITE_BLUE", { trueColor = true })
            mod.content.sprites:patch("SPRITE_SURFING_PIKACHU", { trueColor = true })
        end)
    end

    -- 3. Install Runtime Hooks to enforce trueColor = true on runtime loads
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

    print("[HGSS] HGSS Visual Overhaul initialized with trueColor for Red, Oak, Blue & Pokémon!")
end
