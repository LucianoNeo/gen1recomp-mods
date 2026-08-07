--[[
    HGSS Visual Overhaul — transforms.lua
    ======================================
    Programmatic asset transforms applied at load time.

    This script processes the extracted ROM sprite cache to adapt
    original Gen 1 graphics when custom HGSS sprites are not yet
    available for a specific asset.

    Transforms include:
      • Palette enhancement (richer colors to match HGSS aesthetic)
      • Upscaling fallback sprites using nearest-neighbor
      • Color depth improvements for Gen 1 4-color sprites
]]

-- ============================================================
-- Palette Enhancement
-- ============================================================
-- HGSS uses a richer color palette compared to the original
-- Game Boy 4-color palette. This transform enhances any
-- remaining original sprites that haven't been replaced with
-- HGSS versions to look more consistent with the mod's style.

local function enhancePalette(imageData, species)
    -- Gen 1 original palette (approximate GB colors)
    local gb_palette = {
        { 0.93, 0.93, 0.85 },  -- lightest
        { 0.60, 0.65, 0.55 },  -- light
        { 0.30, 0.35, 0.25 },  -- dark
        { 0.05, 0.05, 0.05 },  -- darkest
    }

    -- Enhanced HGSS-style palette mapping (warmer, more vibrant)
    local enhanced_palette = {
        { 0.96, 0.96, 0.93 },  -- lightest (slightly warmer white)
        { 0.65, 0.70, 0.62 },  -- light (richer midtone)
        { 0.28, 0.32, 0.22 },  -- dark (deeper shadow)
        { 0.02, 0.02, 0.02 },  -- darkest (near black)
    }

    -- Apply palette swap if imageData is available
    if imageData and imageData.mapPixel then
        imageData:mapPixel(function(x, y, r, g, b, a)
            if a < 0.01 then return r, g, b, a end

            -- Find closest palette color and map
            local bestDist = math.huge
            local bestIdx = 1

            for i, color in ipairs(gb_palette) do
                local dist = (r - color[1])^2 + (g - color[2])^2 + (b - color[3])^2
                if dist < bestDist then
                    bestDist = dist
                    bestIdx = i
                end
            end

            local newColor = enhanced_palette[bestIdx]
            return newColor[1], newColor[2], newColor[3], a
        end)
    end

    return imageData
end

-- ============================================================
-- Sprite Upscaling (Nearest-Neighbor)
-- ============================================================
-- Upscales small Gen 1 sprites (56x56) to match HGSS dimensions
-- (80x80) using nearest-neighbor interpolation to preserve
-- pixel art sharpness.

local function upscaleSprite(imageData, targetWidth, targetHeight)
    if not imageData then return nil end

    local srcW = imageData:getWidth()
    local srcH = imageData:getHeight()

    if srcW >= targetWidth and srcH >= targetHeight then
        return imageData  -- Already large enough
    end

    local newData = love.image.newImageData(targetWidth, targetHeight)
    local scaleX = srcW / targetWidth
    local scaleY = srcH / targetHeight

    newData:mapPixel(function(x, y)
        local srcX = math.floor(x * scaleX)
        local srcY = math.floor(y * scaleY)
        srcX = math.min(srcX, srcW - 1)
        srcY = math.min(srcY, srcH - 1)
        return imageData:getPixel(srcX, srcY)
    end)

    return newData
end

-- ============================================================
-- Export transforms for the engine
-- ============================================================

return {
    enhancePalette = enhancePalette,
    upscaleSprite  = upscaleSprite,
}
