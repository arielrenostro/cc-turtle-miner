BaseComponent = {}

function BaseComponent:new(o)
    o = o or {}

    bci = {}
    setmetatable(bci, self)
    self.__index = self
    bci:__setDefault(o)
    return bci
end

function BaseComponent:__setDefault(o)
    self.__parent = o.parent
    self.__onClick = o.onClick
    self.__w = 0
    self.__h = 0
    self.__changed = true
end

function BaseComponent:getSize()
    return self.__w, self.__h
end

function BaseComponent:draw(fn)
end

function BaseComponent:setParent(parent)
    self.__parent = parent
end

function BaseComponent:isChanged()
    return self.__changed
end

function BaseComponent:setChanged(value)
    self.__changed = value

    if self.__parent ~= nil and value then
        self.__parent:setChanged(value)
    end
end

function BaseComponent:onClick()
    if self.__onClick ~= nil then
        self.__onClick()
    end
end

return BaseComponent
