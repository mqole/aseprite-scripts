-- ============================================
-- ERROR MESSAGES
-- ============================================

local error_sprite = "No sprite open!"
local error_layer  = "Could not find the selected layer!"
local error_cel    = "No cel found in the selected layer!"

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

    -- event listener, only active when dialog is open
    local onSpriteChange = nil

    local dlg = Dialog {
        title = "Sprite Preview",
        onclose = function()
            -- ensure we unsubscribe!
            -- this might not be needed, idk how this api works.
            if onSpriteChange then
                if app.events then app.events:off(onSpriteChange) end
                if sprite.events then sprite.events:off(onSpriteChange) end
            end
            onSpriteChange = nil
        end
    }

    -- ============================================
    -- PREVIEW PANEL
    -- ============================================

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
        for i, layer in ipairs(sprite.layers) do
            if layer.name == name then
                return layer
            end
        end
        return nil
    end

    local function clampValue(x, min, max)
        if x < min then return min end
        if x > max then return max end
        return x
    end

    -- change zoom level
    local function changeZoomLevel(value)
        zoomLevel = clampValue(value, 0.5, 100);
        updatePreviewDimensions()

        dlg:repaint()
        dlg:modify { id = "zoomLevel", value = math.floor(value) }
    end

    -- update on sprite change
    onSpriteChange = function()
        sprite = app.sprite
        updateLayers()
        dlg:repaint()
    end
    if app.events then app.events:on('sitechange', onSpriteChange) end
    if sprite.events then sprite.events:on('change', onSpriteChange) end


    dlg:canvas {
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

            local layer = findLayer(dlg.data["layerSelect"])
            if not layer then
                -- first, try updating our combobox with cached layers
                dlg:modify { id = "layerSelect", options = layers }

                -- if we still cant find it... give up!
                layer = findLayer(dlg.data["layerSelect"])
                if not layer then
                    app.alert(error_layer)
                    return
                end
            end

            local active_cel = layer:cel(app.cel.frameNumber)
            if not active_cel then
                app.alert(error_cel)
                return
            end
            local active_image = active_cel.image

            -- ensure we have the correct ratio, in the event a sprite has changed
            updatePreviewDimensions()

            -- offset to draw tile in center of canvas
            local xCenter = (gc.width - prevWidth) / 2
            local yCenter = (gc.height - prevHeight) / 2

            -- source rect annd dist rect
            local srcRect = Rectangle(0, 0, active_image.width, active_image.height)
            local distRect = Rectangle(xCenter, yCenter, prevWidth, prevHeight)

            -- draw our image
            gc:drawImage(active_image, srcRect, distRect)
        end
    }

    dlg:slider {
        id = "zoomLevel",
        label = "Zoom",
        min = 0,
        max = 100,
        value = 4,
        onchange = function()
            local value = dlg.data["zoomLevel"]
            changeZoomLevel(value)
        end,
        onrelease = function()
        end
    }

    dlg:combobox {
        id = "layerSelect",
        label = "Select Layer",
        options = layers,
        onchange = function()
            dlg:repaint()
        end
    }

    dlg:show { wait = false }
end

showMainDialog()
