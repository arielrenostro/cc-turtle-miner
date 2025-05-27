BaseComponent = require("/monitor/components/base_component")

Text = BaseComponent:new()

function Text:new(o)
    o = o or {}
    if o.value == nil then
        return "\"value\" not defined"
    end
    if o.value:find("\n") then
        return "Text contains break line"
    end

    ti = {}
    setmetatable(ti, self)
    self.__index = self
    ti:__setDefault(o)
    return ti
end

function Text:__setDefault(o)
    BaseComponent.__setDefault(self, o)
    self.__value = o.value
    self.__w = #o.value
    self.__h = 1
    self.__bc = o.bc or colors.black
    self.__tc = o.tc or colors.white
end

function Text:setValue(value)
    if self.__value ~= value then
        self.__value = value
        self:setChanged(true)
    end
end

function Text:draw(fn)
    for i = 1, #self.__value do
        local c = self.__value:sub(i, i)
        fn(
            i - 1,
            0,
            self.__bc,
            self.__tc,
            c
        )
    end
end

return Text
