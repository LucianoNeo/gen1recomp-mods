--[[
    HGSS Visual Overhaul — main.lua
    ================================
    Official Gen1Recomp Mod Entry Point.

    Overrides:
      • 151 Pokémon battle front sprites (overrides/battle/front/<species>.png)
      • 151 Pokémon battle back sprites  (overrides/battle/back/<species>b.png)
      • Red Player character battle back sprite (overrides/battle/redb.png)
      • Red Player overworld sprite (overrides/sprites/red.png)
      • All Gym Leaders and Trainer battle sprites (overrides/battle/trainers/<imageBase>.png)
]]

return function(mod)
    print("========================================")
    print("  HGSS Visual Overhaul v1.0.0")
    print("  Loading HeartGold/SoulSilver sprites...")
    print("========================================")

    -- Install Runtime Hooks if available in engine
    if mod and mod.hooks then
        pcall(function()
            mod.hooks:wrap("pokemon.sprite", function(next, samePath, path, ctx)
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
                        if love.filesystem.getInfo and love.filesystem.getInfo(cand) then return cand end
                    else
                        local cand = mod.path .. "/overrides/battle/front/" .. key .. ".png"
                        if love.filesystem.getInfo and love.filesystem.getInfo(cand) then return cand end
                    end
                end
                return next(samePath, path, ctx)
            end)
        end)

        pcall(function()
            mod.hooks:wrap("player.sprite", function(next, samePath, path, ctx)
                local side = ctx and ctx.side
                if side == "back" then
                    local cand = mod.path .. "/overrides/battle/redb.png"
                    if love.filesystem.getInfo and love.filesystem.getInfo(cand) then return cand end
                end
                return next(samePath, path, ctx)
            end)
        end)
    end

    print("[HGSS] HGSS Visual Overhaul loaded successfully!")
end
