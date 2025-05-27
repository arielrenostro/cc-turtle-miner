List = require("/utils/list")
BaseLayer = require("/monitor/layers/base_layer")

Layer = BaseLayer:new()

function Layer:new()
    li = {}
    setmetatable(li, self)
    self.__index = self
    li:__setDefault()
    return li
end

function Layer:__setDefault(o)
    BaseLayer.__setDefault(self, o)
    self.__matrix = {}
    self.__components = {}
    self.__offset = { x = 0, y = 0 }
end

function Layer:scrollX(x)
    self.__offset.x = self.__offset.x + x
end

function Layer:scrollY(y)
    self.__offset.y = self.__offset.y + y
end

function Layer:setScroll(x, y)
    self.__offset.x = x
    self.__offset.y = y
end

function Layer:addComponent(x, y, component)
    local node = {
        x = x,
        y = y,
        component = component,
    }
    if self:__isComponentOverlap(node) then
        return false, "Component overlap"
    end
    self.__components[component] = node
    component:setParent(self)
    return true
end

function Layer:onClick(x, y)
    x = x - self.__offset.x
    y = y - self.__offset.y
    for component, node in pairs(self.__components) do
        local xc, yc = node.x, node.y
        local wc, hc = component:getSize()
        if x >= xc
            and y >= yc
            and x <= xc + wc - 1
            and y <= yc + hc - 1 then
            component:onClick()
            return true
        end
    end
    return false
end

function Layer:processChanges()
    local changed = false

    for component, node in pairs(self.__components) do
        if component:isChanged() then
            local fn = function (x, y, bc, tc, value)
                x = x or 0
                y = y or 0
                self:__setMatrix(
                    node.x + x,
                    node.y + y,
                    bc,
                    tc,
                    value
                )
            end
            component:draw(fn)
            component:setChanged(false)
            changed = true
        end
    end

    return changed
end

function BaseLayer:get(x, y)
    local node = nil
    local line = self.__matrix[x - self.__offset.x]
    if line ~= nil then 
        node = line[y - self.__offset.y]
    end
    return node
end

function BaseLayer:__setMatrix(x, y, bc, tc, value)
    self.__matrix[x] = self.__matrix[x] or {}
    self.__matrix[x][y] = self.__matrix[x][y] or {}
    self.__matrix[x][y].bc = bc
    self.__matrix[x][y].tc = tc
    self.__matrix[x][y].value = value
end

function Layer:__isComponentOverlap(nodeA)
    local aw, ah = nodeA.component:getSize()

    for componentB, nodeB in pairs(self.__components) do
        local bw, bh = componentB:getSize()

        if not (nodeA.x + aw <= nodeB.x -- a totally left from b
            or nodeB.x + bw <= nodeA.x  -- b totally left from a
            or nodeA.y + ah <= nodeB.y  -- a totally above from b
            or nodeB.y + bh <= nodeA.y  -- b totally above from a
        ) then
            return true
        end
    end

    return false
end

return Layer
