Container = require("/monitor/components/container")
Text = require("/monitor/components/text")

Button = Container:new()

function Button:new(o)
    o = o or {}
    if o.value == nil then
        return "\"value\" not defined"
    end
    if o.value:find("\n") then
        return "Text contains break line"
    end
    if o.onClick == nil then
        return "\"onClick\" not defined"
    end

    bi = {}
    setmetatable(bi, self)
    self.__index = self
    bi:__setDefault(o)
    return bi
end

function Button:__setDefault(o)
    Container.__setDefault(self, o)
    self.__bc = o.bc or colors.white
    self.__tc = o.tc or colors.black
    self:addComponent(1, 1, Text:new({ value = o.value, bc = self.__bc, tc = self.__tc }))
    self.__w = self.__w + 1
    self.__h = self.__h + 1
end

function Button:draw(fn)
    for i = 0, self.__w - 1 do
        fn(i, y, self.__bc, colors.white, " ")
        fn(i, self.__h - 1, self.__bc, colors.white, " ")
    end

    for i = 0, self.__h - 3 do
        fn(0, i + 1, self.__bc, colors.white, " ")
        fn(self.__w - 1, i + 1, self.__bc, colors.white, " ")
    end

    Container.draw(self, fn)
end

return Button