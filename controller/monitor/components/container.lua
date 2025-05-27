BaseComponent = require("/monitor/components/base_component")
List = require("/utils/list")

Container = BaseComponent:new()

function Container:new()
    o = o or {}

    ci = {}
    setmetatable(ci, self)
    self.__index = self
    ci:__setDefault(o)
    return ci
end

function Container:__setDefault(o)
    BaseComponent.__setDefault(self, o)
    self.__components = {}
end

function Container:addComponent(x, y, component)
    if component == nil then
        return false
    end

    self.__components[component] = {
        x = x,
        y = y,
        component = component,
    }
    component:setParent(self)

    local w, h = component:getSize()
    w = w + x
    h = h + y
    if self.__w < w then
        self.__w = w
    end
    if self.__h < h then
        self.__h = h
    end

    return true
end

function Container:draw(fn)
    for component, node in pairs(self.__components) do
        local fn2 = function (x, y, bc, tc, value)
            fn(
                node.x + x,
                node.y + y,
                bc,
                tc,
                value
            )
        end
        component:draw(fn2)
        component:setChanged(false)
    end
end

return Container
