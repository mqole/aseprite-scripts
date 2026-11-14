--[[
============================================
DITHER MAP
by mqole (maths by widgetbeck)
============================================

A tool which allows you to create a gradient map of dither patterns for a mask layer.

In developing this script I borrowed and modified code from:
- Aseprite Sprite Sheet Preview by CanadianBoy
- Edge Dither for Aseprite by SourLemon / avenger001
- Heos Gradient Map by Heosphorus
- Prismap by Catkin Tales
Please go check them out!

]] --

-- ============================================
-- ERROR MESSAGES
-- ============================================

local error_sprite   = "No sprite open!"
local error_RGB      = { "Dither Map only works on RGB sprites.",
    "Convert via Sprite \226\150\184 Color Mode \226\150\184 RGB Color, then run it again." }
local error_mapLayer = "Could not find the selected layer!"

-- ============================================
-- CLAMPING
-- ============================================

local function clampValue(x, min, max)
            if x < min then return min end
            if x > max then return max end
            return x
        end

-- ============================================
-- GRADIENT PRESETS (by Heosphorus)
-- ============================================

local presets  = {
    { name = "B&W",       data = { { 0, { 0, 0, 0, 255 } }, { 1, { 255, 255, 255, 255 } } } },
    { name = "Copper",    data = { { 0, { 0, 0, 0, 255 } }, { 0.4, { 140, 60, 20, 255 } }, { 0.7, { 210, 140, 60, 255 } }, { 1, { 255, 220, 160, 255 } } } },
    { name = "Sepia",     data = { { 0, { 30, 20, 10, 255 } }, { 1, { 240, 210, 170, 255 } } } },
    { name = "Fire",      data = { { 0, { 0, 0, 0, 255 } }, { 0.33, { 180, 0, 0, 255 } }, { 0.66, { 255, 120, 0, 255 } }, { 1, { 255, 240, 50, 255 } } } },
    { name = "Ocean",     data = { { 0, { 0, 10, 50, 255 } }, { 0.5, { 0, 120, 180, 255 } }, { 1, { 200, 240, 255, 255 } } } },
    { name = "Sunset",    data = { { 0, { 20, 0, 40, 255 } }, { 0.35, { 160, 0, 80, 255 } }, { 0.65, { 255, 80, 0, 255 } }, { 1, { 255, 220, 100, 255 } } } },
    { name = "Neon",      data = { { 0, { 0, 0, 0, 255 } }, { 0.4, { 180, 0, 255, 255 } }, { 0.7, { 0, 200, 255, 255 } }, { 1, { 200, 255, 100, 255 } } } },
    { name = "Heatmap",   data = { { 0, { 0, 0, 128, 255 } }, { 0.25, { 0, 128, 255, 255 } }, { 0.5, { 0, 220, 0, 255 } }, { 0.75, { 255, 255, 0, 255 } }, { 1, { 255, 0, 0, 255 } } } },
    { name = "Poison",    data = { { 0, { 10, 0, 20, 255 } }, { 0.5, { 80, 0, 160, 255 } }, { 1, { 0, 255, 80, 255 } } } },
    { name = "Ice",       data = { { 0, { 0, 20, 60, 255 } }, { 0.5, { 80, 180, 255, 255 } }, { 1, { 220, 245, 255, 255 } } } },
    { name = "Forest",    data = { { 0, { 5, 20, 5, 255 } }, { 0.5, { 30, 100, 20, 255 } }, { 1, { 160, 220, 80, 255 } } } },
    { name = "Lavender",  data = { { 0, { 20, 10, 40, 255 } }, { 0.5, { 120, 80, 200, 255 } }, { 1, { 220, 200, 255, 255 } } } },
    { name = "Infrared",  data = { { 0, { 0, 60, 0, 255 } }, { 0.4, { 0, 180, 0, 255 } }, { 0.7, { 255, 255, 0, 255 } }, { 1, { 255, 0, 0, 255 } } } },
    { name = "Gold",      data = { { 0, { 40, 25, 0, 255 } }, { 0.5, { 180, 130, 0, 255 } }, { 1, { 255, 240, 100, 255 } } } },
    { name = "Blood",     data = { { 0, { 0, 0, 0, 255 } }, { 0.5, { 120, 0, 0, 255 } }, { 0.85, { 220, 20, 20, 255 } }, { 1, { 255, 80, 80, 255 } } } },
    { name = "Midnight",  data = { { 0, { 0, 0, 20, 255 } }, { 0.5, { 10, 30, 120, 255 } }, { 1, { 80, 120, 255, 255 } } } },
    { name = "Rose",      data = { { 0, { 30, 5, 15, 255 } }, { 0.5, { 180, 40, 100, 255 } }, { 1, { 255, 180, 200, 255 } } } },
    { name = "Toxic",     data = { { 0, { 0, 20, 0, 255 } }, { 0.5, { 80, 200, 0, 255 } }, { 1, { 220, 255, 0, 255 } } } },
    { name = "Vintage",   data = { { 0, { 40, 30, 20, 255 } }, { 0.5, { 160, 130, 90, 255 } }, { 1, { 230, 210, 170, 255 } } } },
    { name = "Electric",  data = { { 0, { 0, 0, 30, 255 } }, { 0.4, { 0, 50, 200, 255 } }, { 0.75, { 0, 200, 255, 255 } }, { 1, { 180, 255, 255, 255 } } } },
    { name = "Cyberpunk", data = { { 0, { 10, 0, 30, 255 } }, { 0.33, { 150, 0, 255, 255 } }, { 0.66, { 0, 255, 255, 255 } }, { 1, { 255, 255, 0, 255 } } } },
    { name = "Desert",    data = { { 0, { 40, 20, 10, 255 } }, { 0.5, { 180, 110, 60, 255 } }, { 1, { 250, 210, 140, 255 } } } },
    { name = "Abyss",     data = { { 0, { 0, 5, 15, 255 } }, { 0.5, { 0, 60, 100, 255 } }, { 1, { 0, 180, 180, 255 } } } },
    { name = "Crimson",   data = { { 0, { 20, 0, 0, 255 } }, { 0.5, { 150, 10, 30, 255 } }, { 1, { 255, 60, 60, 255 } } } },
    { name = "Moss",      data = { { 0, { 10, 20, 5, 255 } }, { 0.5, { 60, 120, 40, 255 } }, { 1, { 140, 200, 90, 255 } } } },
    { name = "Emerald",   data = { { 0, { 0, 20, 10, 255 } }, { 0.5, { 10, 100, 60, 255 } }, { 1, { 120, 245, 180, 255 } } } },
    { name = "Amethyst",  data = { { 0, { 20, 0, 30, 255 } }, { 0.4, { 90, 30, 120, 255 } }, { 0.75, { 180, 100, 220, 255 } }, { 1, { 240, 220, 255, 255 } } } },
    { name = "Sakura",    data = { { 0, { 40, 30, 50, 255 } }, { 0.4, { 180, 100, 140, 255 } }, { 0.8, { 240, 180, 200, 255 } }, { 1, { 255, 245, 245, 255 } } } },
    { name = "Twilight",  data = { { 0, { 15, 10, 40, 255 } }, { 0.5, { 100, 30, 120, 255 } }, { 1, { 255, 140, 80, 255 } } } },
    { name = "Starlight", data = { { 0, { 5, 10, 25, 255 } }, { 0.4, { 30, 60, 120, 255 } }, { 0.8, { 100, 180, 240, 255 } }, { 1, { 255, 255, 255, 255 } } } },
    { name = "Skin Pale", data = { { 0, { 60, 30, 30, 255 } }, { 0.5, { 200, 140, 120, 255 } }, { 1, { 255, 230, 210, 255 } } } },
    { name = "Skin Tan",  data = { { 0, { 50, 25, 15, 255 } }, { 0.5, { 170, 100, 60, 255 } }, { 1, { 245, 200, 150, 255 } } } },
    { name = "Skin Deep", data = { { 0, { 25, 12, 8, 255 } }, { 0.5, { 110, 60, 35, 255 } }, { 1, { 200, 140, 95, 255 } } } },
    { name = "Rust",      data = { { 0, { 30, 10, 5, 255 } }, { 0.5, { 140, 60, 25, 255 } }, { 1, { 230, 150, 90, 255 } } } },
    { name = "Bronze",    data = { { 0, { 35, 20, 5, 255 } }, { 0.5, { 150, 95, 40, 255 } }, { 1, { 240, 200, 130, 255 } } } },
    { name = "Silver",    data = { { 0, { 25, 28, 35, 255 } }, { 0.5, { 130, 138, 150, 255 } }, { 1, { 240, 244, 250, 255 } } } },
    { name = "Slate",     data = { { 0, { 15, 20, 30, 255 } }, { 0.5, { 70, 85, 105, 255 } }, { 1, { 170, 185, 200, 255 } } } },
    { name = "Clay",      data = { { 0, { 40, 20, 15, 255 } }, { 0.5, { 160, 90, 70, 255 } }, { 1, { 235, 180, 150, 255 } } } },
    { name = "Peach",     data = { { 0, { 60, 25, 30, 255 } }, { 0.5, { 230, 130, 110, 255 } }, { 1, { 255, 225, 190, 255 } } } },
    { name = "Mint",      data = { { 0, { 10, 40, 35, 255 } }, { 0.5, { 70, 180, 140, 255 } }, { 1, { 210, 255, 230, 255 } } } },
    { name = "Teal",      data = { { 0, { 0, 25, 30, 255 } }, { 0.5, { 20, 130, 130, 255 } }, { 1, { 150, 230, 215, 255 } } } },
    { name = "Coral",     data = { { 0, { 50, 10, 20, 255 } }, { 0.5, { 230, 90, 80, 255 } }, { 1, { 255, 200, 170, 255 } } } },
    { name = "Plum",      data = { { 0, { 25, 5, 25, 255 } }, { 0.5, { 110, 40, 100, 255 } }, { 1, { 220, 150, 200, 255 } } } },
    { name = "Wine",      data = { { 0, { 20, 0, 10, 255 } }, { 0.5, { 110, 15, 45, 255 } }, { 1, { 210, 90, 110, 255 } } } },
    { name = "Olive",     data = { { 0, { 20, 20, 5, 255 } }, { 0.5, { 110, 110, 40, 255 } }, { 1, { 210, 210, 130, 255 } } } },
    { name = "Sand",      data = { { 0, { 60, 45, 25, 255 } }, { 0.5, { 190, 160, 110, 255 } }, { 1, { 250, 235, 200, 255 } } } },
    { name = "Lime",      data = { { 0, { 10, 35, 0, 255 } }, { 0.5, { 120, 200, 20, 255 } }, { 1, { 230, 255, 150, 255 } } } },
    { name = "Cobalt",    data = { { 0, { 0, 10, 40, 255 } }, { 0.5, { 20, 70, 190, 255 } }, { 1, { 140, 190, 255, 255 } } } },
    { name = "Magma",     data = { { 0, { 10, 0, 0, 255 } }, { 0.3, { 90, 0, 20, 255 } }, { 0.65, { 230, 70, 0, 255 } }, { 1, { 255, 230, 120, 255 } } } },
    { name = "Bubblegum", data = { { 0, { 60, 10, 50, 255 } }, { 0.5, { 240, 100, 180, 255 } }, { 1, { 255, 220, 240, 255 } } } },
    { name = "Aqua",      data = { { 0, { 0, 30, 50, 255 } }, { 0.5, { 0, 170, 210, 255 } }, { 1, { 190, 250, 255, 255 } } } },
    { name = "Mustard",   data = { { 0, { 40, 30, 0, 255 } }, { 0.5, { 190, 150, 20, 255 } }, { 1, { 250, 235, 140, 255 } } } },
    { name = "Chocolate", data = { { 0, { 20, 10, 5, 255 } }, { 0.5, { 95, 55, 30, 255 } }, { 1, { 190, 140, 100, 255 } } } },
    { name = "Jade",      data = { { 0, { 0, 25, 15, 255 } }, { 0.5, { 40, 140, 90, 255 } }, { 1, { 180, 235, 200, 255 } } } },
    { name = "Orchid",    data = { { 0, { 30, 10, 40, 255 } }, { 0.5, { 170, 90, 200, 255 } }, { 1, { 245, 210, 255, 255 } } } },
    { name = "Steel",     data = { { 0, { 10, 15, 25, 255 } }, { 0.4, { 60, 80, 100, 255 } }, { 0.8, { 150, 170, 190, 255 } }, { 1, { 230, 240, 250, 255 } } } },
    { name = "Autumn",    data = { { 0, { 30, 10, 0, 255 } }, { 0.4, { 150, 50, 10, 255 } }, { 0.75, { 220, 140, 30, 255 } }, { 1, { 255, 230, 150, 255 } } } },
    { name = "Glacier",   data = { { 0, { 10, 30, 50, 255 } }, { 0.5, { 120, 180, 210, 255 } }, { 1, { 245, 252, 255, 255 } } } },
    { name = "Swamp",     data = { { 0, { 10, 15, 5, 255 } }, { 0.5, { 70, 80, 30, 255 } }, { 1, { 170, 170, 90, 255 } } } },
    { name = "Royal",     data = { { 0, { 10, 0, 30, 255 } }, { 0.4, { 60, 20, 140, 255 } }, { 0.8, { 200, 160, 40, 255 } }, { 1, { 255, 240, 160, 255 } } } },
}

-- ============================================
-- DITHERING (by Heosphorus)
-- ============================================

local bayer4x4 = {
    { 0,  8,  2,  10 },
    { 12, 4,  14, 6 },
    { 3,  11, 1,  9 },
    { 15, 7,  13, 5 },
}

-- ============================================
-- DIALOG
-- ============================================

local function showMainDialog()
    -- the active sprite
    local sprite = app.sprite

    if not sprite then
        app.alert(error_sprite)
        return
    end
    if sprite.colorMode ~= ColorMode.RGB then
        app.alert { text = error_RGB }
        return
    end

    -- pop-out preview window
    local previewDlg = nil
    -- pop-out preset window
    local presetDlg = nil

    -- event listener, only active when dialog is open
    local onSpriteChange = nil

    local dlg = Dialog {
        title = "Dither Machine",
        onclose = function()
            -- ensure we unsubscribe!
            -- this might not be needed, idk how this api works.
            if onSpriteChange then
                if app.events then app.events:off(onSpriteChange) end
                if sprite.events then sprite.events:off(onSpriteChange) end
            end
            onSpriteChange = nil
            pcall(function()
                if previewDlg then previewDlg:close() end
                if presetDlg then presetDlg:close() end
            end)
        end
    }

    -- DONT CALL REPAINT ON MAIN DIALOG
    -- calling this function will ensure preview is also updated.
    -- this will NOT repaint the bar. call repaintBar() for that.
    local function repaintAll()
        dlg:repaint()
        if previewDlg then previewDlg:repaint() end
    end

    -- ============================================
    -- STOP HELPERS
    -- ============================================

    -- instructions
    -- these have to be seperate elements because no newline support
    dlg:label {
        label = "",
        text = "Left click on the bar to add a new marker."
    }
    dlg:label {
        label = "",
        text = "Right click a marker to delete it."
    }
    dlg:label {
        label = "",
        text = "Click and drag a marker to change its position."
    }

    -- list of stops
    local stops = {}

    local stopCounter = 0
    local function makeStop(pos, color)
        stopCounter = stopCounter + 1
        return { id = stopCounter, pos = pos, color = color }
    end

    local defaultStops = function()
        return {
            makeStop(0, Color { r = 0, g = 0, b = 0, a = 255 }),
            makeStop(255, Color { r = 255, g = 255, b = 255, a = 255 }),
        }
    end
    stops = defaultStops()

    -- selected stop id
    local selectedStop = stops[1].id

    -- resets stop counter
    -- optionally returns the value of a specified stop.
    local function sortStops(returnStop)
        stopCounter = 0
        local newStops = {}
        local out = nil
        table.sort(stops, function(a, b) return a.pos < b.pos end)

        for _, s in ipairs(stops) do
            local stop = makeStop(s.pos, s.color)
            table.insert(newStops, stop)
            if returnStop and returnStop.id == s.id then
                out = stop
            end
        end
        stops = newStops
        return out
    end

    local function addStop(pos, color)
        local stop = makeStop(pos, color)
        table.insert(stops, stop)
        local sortedId = sortStops(stop)
        return sortedId
    end

    local function removeStop(id)
        local uid = selectedStop
        table.remove(stops, id)
        sortStops(nil)

        if selectedStop == uid then
            -- change selected stop to the latest one.
            selectedStop = stops[math.min(id, #stops)].id
        end
    end

    local function loadPreset(preset)
        stops = {}
        for _, d in ipairs(preset.data) do
            addStop(d[1] * 255, Color { r = d[2][1], g = d[2][2], b = d[2][3], a = d[2][4] or 255 })
        end
        selectedStop = stops[1].id
    end

    -- ============================================
    -- GRADIENT MATHS (by widgetbeck)
    -- ============================================

    -- calculate pixel luminosity
    local function lum(r, g, b)
        return math.floor(0.299 * r + 0.587 * g + 0.114 * b + 0.5)
    end

    local ditherStrength = 1.0
    local contrast = 1.0
    local offset = 0.0
    local depth = 1
    local ditherSize = 1

    -- adjust existing luminosity for contrast, offset, and bit depth
    local function lumContrast(lumi)
        -- adjust with contrast and offset parameters
        lumi = (lumi - 0.5 + offset * 255) * contrast + 0.5
        lumi = clampValue(lumi, 0, 255)

        -- reduce luminosity bit depth to give a more banded visual if desired	
        lumi = math.floor(lumi * depth) / depth
        return math.max(lumi - 0.00001, 0.0)
    end

    local function ditherTexture(x, y)
        local b = bayer4x4[(y % 4) + 1][(x % 4) + 1]
        return (b / 16 - 0.5) * ditherStrength
    end

    -- ============================================
    -- MAKE THE DANG GRADIENT
    -- ============================================

    -- if true, don't lerp
    local useHardStops = false
    -- if true, use a dither pattern to smooth
    local useDither = false

    local function lerp(a, b, f)
        return Color {
            r = math.floor(a.red + f * (b.red - a.red) + 0.5),
            g = math.floor(a.green + f * (b.green - a.green) + 0.5),
            b = math.floor(a.blue + f * (b.blue - a.blue) + 0.5),
            a = math.floor(a.alpha + f * (b.alpha - a.alpha) + 0.5),
        }
    end

    local function sampleGradient(pos, dither)
        -- banding:
        -- to support multicolour palettes, we want to lerp between the two colours on the palette which are adjacent to the current pixel luminosity. to do this, we need to determine which 'band' lum falls into, and calculate the upper and lower bound of that band.
        -- if dithering, we will use the dither texture to pick either the upper or lower colour.

        if #stops == 1 then return stops[1].color end
        if pos <= stops[1].pos then return stops[1].color end
        if pos >= stops[#stops].pos then return stops[#stops].color end

        for i = 1, #stops - 1 do
            -- get position of this stop against next stop, as a %
            local s0, s1 = stops[i], stops[i + 1]
            if pos >= s0.pos and pos <= s1.pos then
                -- use previous colour if we arent lerping
                if useHardStops then return s0.color end

                local f = (pos - s0.pos) / (s1.pos - s0.pos)

                if useDither and dither then
                    if f + dither >= 0.5 then
                        return s1.color
                    else
                        return s0.color
                    end
                end

                return lerp(s0.color, s1.color, f)
            end
        end
    end

    -- used for preset previews
    -- these are formatted a little different!
    local function sampleFromData(data, pos)
        if #data == 1 or pos <= data[1][1] or pos >= data[#data][1] then
            local d = data[1][2]
            return Color { r = d[1], g = d[2], b = d[3], a = d[4] or 255 }
        end

        for i = 1, #data - 1 do
            local pos0, c0 = data[i][1], data[i][2]
            local pos1, c1 = data[i + 1][1], data[i + 1][2]

            if pos >= pos0 and pos <= pos1 then
                local f = (pos - pos0) / (pos1 - pos0)
                return Color {
                    r = math.floor(c0[1] + f * (c1[1] - c0[1]) + 0.5),
                    g = math.floor(c0[2] + f * (c1[2] - c0[2]) + 0.5),
                    b = math.floor(c0[3] + f * (c1[3] - c0[3]) + 0.5),
                    a = math.floor((c0[4] or 255) + f * ((c1[4] or 255) - (c0[4] or 255)) + 0.5)
                }
            end
        end

        local d = data[#data][2]
        return Color { r = d[1], g = d[2], b = d[3], a = d[4] or 255 }
    end

    local function applyGradient(image)
        local w, h = image.width, image.height
        local outImg = Image(w, h, ColorMode.RGB)
        for py = 0, h - 1 do
            for px = 0, w - 1 do
                local pixel = image:getPixel(px, py)
                local a = app.pixelColor.rgbaA(pixel)

                if a > 0 then
                    local r = app.pixelColor.rgbaR(pixel)
                    local g = app.pixelColor.rgbaG(pixel)
                    local b = app.pixelColor.rgbaB(pixel)

                    local lumi = lum(r, g, b)
                    local c
                    if useDither then
                        c = sampleGradient(lumContrast(lumi), ditherTexture(px, py))
                    else
                        c = sampleGradient(lumi, nil)
                    end
                    outImg:drawPixel(px, py, app.pixelColor.rgba(c.red, c.green, c.blue, a))
                else
                    outImg:drawPixel(px, py, app.pixelColor.rgba(0, 0, 0, 0))
                end
            end
        end
        return outImg
    end

    -- ============================================
    -- GRADIENT BAR BUILDERS
    -- ============================================

    -- building a greyscale bar with dimensions of 256 x 24
    local barWidth, barHeight = 256, 24

    -- creates a greyscale bar (black -> white)
    local function buildGrayscaleBar(height)
        local barImage = Image(barWidth, height, ColorMode.RGB)
        for bx = 0, barWidth - 1 do
            for by = 0, height - 1 do
                barImage:putPixel(bx, by, app.pixelColor.rgba(bx, bx, bx, 255))
            end
        end
        return barImage
    end

    local barImageCache = nil
    local barDirty = true

    -- creates a bar of gradient from stops
    local function buildGradientBar(height)
        if not barDirty and barImageCache then return barImageCache end
        barImageCache = Image(barWidth, barHeight, ColorMode.RGB)

        for x = 0, barWidth - 1 do
            for y = 0, height - 1 do
                local c
                if useDither then
                    c = sampleGradient(x, ditherTexture(x, y))
                else
                    c = sampleGradient(x, nil)
                end

                -- create checkered BG for transparent colours
                if c.alpha < 255 then
                    local checkSize = 4
                    local isCheck = (math.floor(x / checkSize) + math.floor(y / checkSize)) % 2 == 0
                    local bgV = isCheck and 180 or 120
                    local f = c.alpha / 255
                    c = Color {
                        r = math.floor(c.red * f + bgV * (1 - f)),
                        g = math.floor(c.green * f + bgV * (1 - f)),
                        b = math.floor(c.blue * f + bgV * (1 - f)),
                    }
                end
                barImageCache:drawPixel(x, y, app.pixelColor.rgba(c.red, c.green, c.blue, 255))
            end
        end

        barDirty = false
        return barImageCache
    end

    local function repaintBar()
        barDirty = true
        repaintAll()
    end

    local function clampPos(pos)
        return math.max(0, math.min(255, pos))
    end

    -- find the marker that matches position clicked at
    local function findStopAtPos(x, mouseOnBar)
        local hit = nil
        -- more mouse tolerance if we're clicking inside the marker area
        local tolerance = mouseOnBar and 5 or 10
        for _, stop in ipairs(stops) do
            local mx = clampPos(stop.pos)
            if math.abs(x - mx) <= tolerance then
                hit = stop.id
                break
            end
        end
        return hit
    end

    -- ensure that colour selector reflects the selected marker
    local function dirtyColor()
        if stops[selectedStop] then
            dlg:modify {
                id = "stopColour",
                color = stops[selectedStop].color
            }
        end
    end

    -- dirties colour selector and repaints bar.
    local function dirtyUI()
        dirtyColor()
        repaintBar()
    end

    -- ============================================
    -- GRADIENT BAR
    -- ============================================

    -- making a smaller bar on top for preview purposes
    local smallBarHeight = 4

    dlg:canvas {
        id = "smallBar",
        width = barWidth,
        height = smallBarHeight,
        onpaint = function(ev)
            -- grabbing our graphics context
            local gc = ev.context

            -- draw grayscale bar and border around
            gc:drawImage(buildGrayscaleBar(smallBarHeight), 0, 0)
            gc:strokeRect(Rectangle(0, 0, barWidth, smallBarHeight))
        end
    }

    dlg:newrow {}

    -- margin of space to use for colour markers
    local markerZoneHeight = 22
    -- are we currently dragging a marker?
    local dragging = false

    dlg:canvas {
        id = "bar",
        width = barWidth,
        height = barHeight + markerZoneHeight,
        onpaint = function(ev)
            -- grabbing our graphics context
            local gc = ev.context

            -- draw bar and border around
            gc:drawImage(buildGradientBar(barHeight), 0, 0)
            gc:strokeRect(Rectangle(0, 0, barWidth, barHeight))

            -- draw stop markers
            for _, stop in ipairs(stops) do
                local pos = clampPos(stop.pos)
                local isSelected = (stop.id == selectedStop)

                -- thin line on bar showing position
                gc.color = isSelected
                    and Color { r = 255, g = 255, b = 255, a = 255 }
                    or Color { r = 180, g = 180, b = 180, a = 160 }
                gc:fillRect(Rectangle(pos, 0, 1, barHeight))

                -- swatch below bar
                local sw_x = pos - 6
                local sw_y = barHeight + 4
                local sw_s = 13

                -- selection ring (drawn first, slightly larger)
                if isSelected then
                    gc.color = Color { r = 255, g = 255, b = 255, a = 255 }
                    gc:fillRect(Rectangle(sw_x - 2, sw_y - 2, sw_s + 4, sw_s + 4))
                end

                -- dark border for all swatches
                gc:fillRect(Rectangle(sw_x - 1, sw_y - 1, sw_s + 2, sw_s + 2))

                -- the actual color swatch
                gc.color = stop.color
                gc:fillRect(Rectangle(sw_x, sw_y, sw_s, sw_s))
            end
        end,

        onmousedown = function(ev)
            local mouseX = ev.x
            local mouseBelowBar = ev.y <= barHeight

            -- right click: remove marker
            if ev.button == MouseButton.RIGHT then
                -- get the marker we're hitting, if any
                local hit = findStopAtPos(mouseX, mouseBelowBar)
                if not hit then return end

                -- can have 2 stops minimum.
                if #stops > 2 then
                    removeStop(hit)
                    dirtyUI()
                end
                return
            end

            -- left click: add marker
            if ev.button == MouseButton.LEFT then
                -- get the marker we're hitting, if any
                local hit = findStopAtPos(mouseX, mouseBelowBar)

                if hit then
                    -- start dragging the marker
                    selectedStop = stops[hit].id
                else
                    -- create new marker
                    local pos = clampPos(mouseX)
                    local newStop = addStop(pos, sampleGradient(pos))
                    if newStop then selectedStop = newStop.id end
                end

                dirtyUI()
                dragging = true
            end
        end,

        -- remove 'dragging' status
        onmouseup = function()
            if not dragging then return end
            dragging = false
            selectedStop = sortStops(stops[selectedStop]).id
            dirtyUI()
        end,

        -- drag a marker if in 'dragging' status
        onmousemove = function(ev)
            if not dragging then return end
            if stops[selectedStop] then
                stops[selectedStop].pos = ev.x
                repaintAll()
            end
        end
    }

    -- colour picker for selected stop
    dlg:color {
        id = "stopColour",
        color = stops[1].color,
        onchange = function()
            local c = dlg.data.stopColour
            stops[selectedStop].color = c
            repaintBar()
        end
    }

    dlg:label {
        label = "",
        text = "Release left click to reload the gradient preview."
    }

    dlg:separator {}

    -- ============================================
    -- PREVIEW
    -- ============================================

    -- cached layer list
    local layers = {}

    local function updateLayers()
        layers = {}
        if not sprite then return end
        for _, layer in ipairs(sprite.layers) do
            table.insert(layers, 1, layer.name)
        end
    end

    updateLayers()

    local findLayer = function(name)
        if not sprite then return end
        for _, layer in ipairs(sprite.layers) do
            if layer.name == name then
                return layer
            end
        end
        return nil
    end

    local function openPreview()
        if previewDlg then
            previewDlg:repaint()
            return
        end

        previewDlg = Dialog {
            title = "Gradient Preview",
            onclose = function()
                previewDlg = nil
            end
        }

        -- level of zoom on preview
        local zoomLevel = 4
        -- size of preview
        local tileWidth = 32
        local tileHeight = 32

        local function getSpriteRatio()
            local width = sprite.width / tileWidth
            local height = sprite.height / tileHeight
            return width, height
        end
        -- ratio of canvas sprite
        local ratioWidth, ratioHeight = getSpriteRatio()
        -- dimensions of preview canvas
        local prevWidth, prevHeight = 0, 0

        local function updatePreviewDimensions()
            ratioWidth, ratioHeight = getSpriteRatio()
            local width = (tileWidth * zoomLevel) * ratioWidth / ratioHeight
            local height = tileHeight * zoomLevel
            prevWidth, prevHeight = width, height
        end

        -- change zoom level
        local function changeZoomLevel(value)
            zoomLevel = clampValue(value, 0.5, 100);
            updatePreviewDimensions()

            previewDlg:repaint()
            previewDlg:modify { id = "zoomLevel", value = math.floor(value) }
        end

        -- update on sprite change
        onSpriteChange = function()
            sprite = app.sprite
            updateLayers()
            if previewDlg then previewDlg:repaint() end
        end
        if app.events then app.events:on('sitechange', onSpriteChange) end
        if sprite.events then sprite.events:on('change', onSpriteChange) end

        previewDlg:canvas {
            id = "preview",
            width = tileWidth * zoomLevel * 1.5,
            height = tileHeight * zoomLevel * 1,
            hexpand = true,
            vexpand = true,
            autoscaling = true,
            onwheel = function(ev)
                local zoomSpeed = 1;
                if zoomLevel >= 10 then
                    zoomSpeed = zoomLevel / 10;
                end
                local value = math.floor(zoomLevel + ev.deltaY * (-zoomSpeed))
                changeZoomLevel(value)
            end,
            onpaint = function(ev)
                -- grabbing our graphics context, the map layer, and our current cels
                local gc = ev.context

                local map_layer = findLayer(dlg.data["mapSelect"])
                if not map_layer then
                    -- first, try updating our combobox with cached layers
                    dlg:modify { id = "mapSelect", options = layers }

                    -- if we still cant find it... give up!
                    map_layer = findLayer(dlg.data["mapSelect"])
                    if not map_layer then
                        app.alert(error_mapLayer)
                        return
                    end
                end

                local active_cel = app.cel
                local active_image = active_cel.image
                local map_cel = map_layer:cel(active_cel.frameNumber)

                -- ensure we have the correct ratio, in the event a sprite has changed
                updatePreviewDimensions()

                -- offset to draw tile in center of canvas
                local xCenter = (gc.width - prevWidth) / 2
                local yCenter = (gc.height - prevHeight) / 2

                -- source rect and dist rect
                local srcRect = Rectangle(0, 0, active_image.width, active_image.height)
                local distRect = Rectangle(xCenter, yCenter, prevWidth, prevHeight)

                local gradientImage = applyGradient(active_image)

                -- draw our image & a nice border
                gc:drawImage(gradientImage, srcRect, distRect)
                gc:strokeRect(Rectangle(0, 0, gc.width, gc.height))
            end
        }

        previewDlg:slider {
            id = "zoomLevel",
            label = "Zoom: ",
            min = 0,
            max = 100,
            value = 4,
            onchange = function()
                local value = previewDlg.data["zoomLevel"]
                changeZoomLevel(value)
            end,
            onrelease = function()
            end
        }

        previewDlg:label {
            label = "",
            text = "On larger canvases, closing this window can improve performance."
        }

        previewDlg:show {
            wait = false,
            -- show offset from main window
            bounds = Rectangle(previewDlg.bounds.x + 175, previewDlg.bounds.y, previewDlg.bounds.width, previewDlg.bounds.height)
        }
    end

    -- ============================================
    -- GRADIENT PRESETS (by Heosphorus)
    -- ============================================

    local function openPresets()
        if presetDlg then
            presetDlg:repaint()
            return
        end

        local presetWidth, presetHeight = 72, 24
        presetDlg = Dialog {
            title = "Gradient Presets",
            onclose = function()
                presetDlg = nil
            end
        }

        local function addPresetCanvas(preset, index)
            if not preset then return end
            presetDlg:canvas {
                id = "preset_" .. index,
                width = presetWidth,
                height = presetHeight,
                onpaint = function(ev)
                    -- grabbing our graphics context
                    local gc = ev.context

                    for x = 0, presetWidth - 1 do
                        local c = sampleFromData(preset.data, x / (presetWidth - 1))
                        gc.color = c
                        gc:fillRect(Rectangle(x, 0, 1, presetHeight))
                    end
                    gc:strokeRect(Rectangle(0, 0, presetWidth, presetHeight))

                    pcall(function()
                        gc.color = Color { r = 0, g = 0, b = 0, a = 180 }
                        gc:fillText(preset.name, 5, 6)
                        gc.color = Color { r = 255, g = 255, b = 255, a = 255 }
                        gc:fillText(preset.name, 4, 5)
                    end)
                end,
                onmousedown = function()
                    loadPreset(preset)
                    -- set to smooth
                    useHardStops = false
                    useDither = false
                    dlg:modify {
                        id = "linearButton",
                        selected = true
                    }
                    dirtyUI()
                end
            }
        end

        local columns = 5
        for pi = 1, #presets, columns do
            for j = 0, columns - 1 do
                addPresetCanvas(presets[pi + j], pi + j)
            end
            presetDlg:newrow()
        end

        presetDlg:show { wait = false }
    end

    -- ============================================
    -- UI
    -- ============================================

    dlg:radio {
        id = "linearButton",
        label = "Interpolation:",
        text = "Linear",
        onclick = function()
            useHardStops = false
            useDither = false
            repaintBar()
        end
    }
    dlg:radio {
        text = "Constant",
        onclick = function()
            useHardStops = true
            useDither = false
            repaintBar()
        end
    }
    dlg:radio {
        text = "Dithered",
        onclick = function()
            useHardStops = false
            useDither = true
            repaintBar()
        end
    }

    dlg:separator {}

    dlg:label {
        label = "",
        text = "Dither Controls:"
    }

    local function changeBitDepth(value)
        depth = clampValue(value, 0.5, 100);
        repaintBar()
        dlg:modify { id = "bitDepth", value = math.floor(value) }
    end

    dlg:slider {
        id = "bitDepth",
        label = "Bit Depth",
        min = 0,
        max = 100,
        value = 1,
        onchange = function()
            local value = dlg.data["bitDepth"]
            changeBitDepth(value)
        end,
        onrelease = function()
        end
    }

    local function changeContrast(value)
        contrast = clampValue(value / 100, 0.0, 1);
        repaintBar()
        dlg:modify { id = "contrast", value = math.floor(value) }
    end

    dlg:slider {
        id = "contrast",
        label = "Contrast",
        min = 0,
        max = 100,
        value = 100,
        onchange = function()
            local value = dlg.data["contrast"]
            changeContrast(value)
        end,
        onrelease = function()
        end
    }

    local function changeOffset(value)
        offset = clampValue(value / 100, 0.0, 1);
        repaintBar()
        dlg:modify { id = "offset", value = math.floor(value) }
    end

    dlg:slider {
        id = "offset",
        label = "Offset",
        min = 0,
        max = 100,
        value = 0,
        onchange = function()
            local value = dlg.data["offset"]
            changeOffset(value)
        end,
        onrelease = function()
        end
    }

    local function changeDitherStrength(value)
        ditherStrength = clampValue(value / 100, 0.0, 1);
        repaintBar()
        dlg:modify { id = "ditherStrength", value = math.floor(value) }
    end


    dlg:slider {
        id = "ditherStrength",
        label = "Dither Strength",
        min = 0,
        max = 100,
        value = 100,
        onchange = function()
            local value = dlg.data["ditherStrength"]
            changeDitherStrength(value)
        end,
        onrelease = function()
        end
    }

    dlg:separator {}

    dlg:button {
        text = "Presets",
        onclick = openPresets
    }

    dlg:combobox {
        id = "mapSelect",
        label = "Gradient layer",
        options = layers,
        onchange = function()
            repaintAll()
        end
    }

    dlg:separator {}

    dlg:button {
        text = "Preview",
        onclick = openPreview
    }

    dlg:button {
        text = "Apply Gradient",
        onclick = function()
            local image = app.cel.image
            app.transaction("Gradient Map", function()
                app.cel.image = applyGradient(image)
            end)
            app.refresh()
            dlg:close()
        end
    }

    openPreview()

    dlg:show {
        wait = false,
        -- show offset from preview window
        bounds = Rectangle(dlg.bounds.x - 175, dlg.bounds.y, dlg.bounds.width, dlg.bounds.height)
    }

    -- look. dont ask me why this exists.
    -- all i know is that the bar HATES loading on open unless we manually repaint it.
    repaintAll()
end

showMainDialog()
