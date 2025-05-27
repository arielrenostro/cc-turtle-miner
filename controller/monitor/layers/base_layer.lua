List = require("/utils/list")

BaseLayer = {}

function BaseLayer:new()
    li = {}
    setmetatable(li, self)
    self.__index = self
    li:__setDefault()
    return li
end

function BaseLayer:__setDefault(o)
end

function BaseLayer:onClick(x, y)
    return false
end

function BaseLayer:processChanges()
    return false
end

function BaseLayer:get(x, y)
    return nil
end

return BaseLayer
