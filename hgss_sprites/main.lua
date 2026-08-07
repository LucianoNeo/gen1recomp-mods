--[[
    HGSS Visual Overhaul — main.lua
    ================================
    Official Gen1Recomp Mod Entry Point.
]]

return function(mod)
    print("========================================")
    print("  HGSS Visual Overhaul v1.0.2")
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

    local SPRITE_IDS = {
        "SPRITE_RED", "SPRITE_BLUE", "SPRITE_OAK", "SPRITE_YOUNGSTER",
        "SPRITE_MONSTER", "SPRITE_COOLTRAINER_F", "SPRITE_COOLTRAINER_M",
        "SPRITE_LITTLE_GIRL", "SPRITE_BIRD", "SPRITE_MIDDLE_AGED_MAN",
        "SPRITE_GAMBLER", "SPRITE_SUPER_NERD", "SPRITE_GIRL", "SPRITE_HIKER",
        "SPRITE_BEAUTY", "SPRITE_GENTLEMAN", "SPRITE_DAISY", "SPRITE_BIKER",
        "SPRITE_SAILOR", "SPRITE_COOK", "SPRITE_BIKE_SHOP_CLERK",
        "SPRITE_MR_FUJI", "SPRITE_GIOVANNI", "SPRITE_ROCKET", "SPRITE_CHANNELER",
        "SPRITE_WAITER", "SPRITE_SILPH_WORKER_F", "SPRITE_MIDDLE_AGED_WOMAN",
        "SPRITE_BRUNETTE_GIRL", "SPRITE_LANCE", "SPRITE_UNUSED_SCIENTIST",
        "SPRITE_SCIENTIST", "SPRITE_ROCKER", "SPRITE_SWIMMER",
        "SPRITE_SAFARI_ZONE_WORKER", "SPRITE_GYM_GUIDE", "SPRITE_GRAMPS",
        "SPRITE_CLERK", "SPRITE_FISHING_GURU", "SPRITE_GRANNY", "SPRITE_NURSE",
        "SPRITE_LINK_RECEPTIONIST", "SPRITE_SILPH_PRESIDENT", "SPRITE_SILPH_WORKER_M",
        "SPRITE_WARDEN", "SPRITE_CAPTAIN", "SPRITE_FISHER", "SPRITE_KOGA",
        "SPRITE_GUARD", "SPRITE_UNUSED_GUARD", "SPRITE_MOM", "SPRITE_BALDING_GUY",
        "SPRITE_LITTLE_BOY", "SPRITE_UNUSED_GAMEBOY_KID", "SPRITE_GAMEBOY_KID",
        "SPRITE_FAIRY", "SPRITE_AGATHA", "SPRITE_BRUNO", "SPRITE_LORELEI",
        "SPRITE_SEEL", "SPRITE_POKE_BALL", "SPRITE_FOSSIL", "SPRITE_BOULDER",
        "SPRITE_PAPER", "SPRITE_POKEDEX", "SPRITE_CLIPBOARD", "SPRITE_SNORLAX",
        "SPRITE_UNUSED_OLD_AMBER", "SPRITE_OLD_AMBER", "SPRITE_RED_BIKE",
        "SPRITE_SURFING_PIKACHU",
    }

    -- 1. Patch trueColor = true for all 151 Pokémon
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

    -- 2. Patch trueColor = true for all 72 Overworld Sprites (Player, Followers, NPCs)
    if mod and mod.content and mod.content.sprites then
        pcall(function()
            for _, sid in ipairs(SPRITE_IDS) do
                mod.content.sprites:patch(sid, {
                    trueColor = true,
                })
            end
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

    print("[HGSS] HGSS Visual Overhaul initialized with full trueColor support!")
end
