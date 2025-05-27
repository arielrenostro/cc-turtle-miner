local DEFAULT_NODE = {
    bc = colors.black,
    tc = colors.white,
    value = " ",
}

Render = {}

function Render:new(o)
    o = o or {}
    if o.redirect == nil then
        return "\"redirect\" not defined"
    end
    if o.layer == nil then
        return "\"layer\" not defined"
    end

    render = {}
    setmetatable(render, self)
    self.__index = self
    render:__setDefault(o)
    return render
end

function Render:__setDefault(o)
    self.__redirect = o.redirect
    self.__layer = o.layer
    self.__offset = { x = 0, y = 0 }
end

function Render:scrollX(x)
    self.__offset.x = self.__offset.x + x
end

function Render:scrollY(y)
    self.__offset.y = self.__offset.y + y
end

function Render:setScroll(x, y)
    self.__offset.x = x
    self.__offset.y = y
end

function Render:render()
    self.__layer:processChanges()

    local lastBc = nil
    local lastTc = nil
    local node = nil
    
    local mx, my = self.__redirect.getSize()
    for y = 1, my do
        for x = 1, mx do
            node = self.__layer:get(
                x - self.__offset.x,
                y - self.__offset.y
            ) or DEFAULT_NODE

            if lastBc ~= node.bc then
                self.__redirect.setBackgroundColor(node.bc)
                lastBc = node.bc
            end
            if lastTc ~= node.tc then
                self.__redirect.setTextColor(node.tc)
                lastTc = node.tc
            end
            self.__redirect.setCursorPos(x, y)
            self.__redirect.write(node.value)
        end
    end
end

function Render:onClick(x, y)
    self.__layer:onClick(
        x - self.__offset.x,
        y - self.__offset.y
    )
end

return Render
