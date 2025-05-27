List = require("/utils/list")
BaseLayer = require("/monitor/layers/base_layer")

OverlayLayers = BaseLayer:new()

function OverlayLayers:new()
    bci = {}
    setmetatable(bci, self)
    self.__index = self
    bci:__setDefault()
    return bci
end

function OverlayLayers:__setDefault(o)
    BaseLayer.__setDefault(self, o)
    self.__layers = List:new()
end

function OverlayLayers:add(layer)
    self.__layers:add(layer)
end

function OverlayLayers:processChanges()
    local changed = false
    for i = 1, self.__layers:size() do
        if self.__layers:get(i):processChanges() then
            changed = true
        end
    end
    return changed
end

function OverlayLayers:onClick(x, y)
    for i = self.__layers:size(), 1, -1 do
        if self.__layers:get(i):onClick(x, y) then
            return true
        end
    end
    return false
end

function OverlayLayers:get(x, y)
    for i = self.__layers:size(), 1, -1 do
        local node = self.__layers:get(i):get(x, y)
        if node ~= nil then
            return node
        end
    end
    return nil
end

return OverlayLayers
