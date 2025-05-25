local R = {
    __monitor = nil,
    __matrix = {},
    __x = 0,
    __y = 0,
}

local DEFAULT_NODE = {
    bc = colors.black,
    tc = colors.white,
    value = " ",
}

function R.setMonitor(monitor)
    R.__monitor = monitor
end

function R.scrollX(x)
    R.__x = R.__x + x
end

function R.scrollY(y)
    R.__y = R.__y + y
end

function R.setScroll(x, y)
    R.__x = x
    R.__y = y
end

function R.setTextChar(x, y, bc, tc, value)
    R.__matrix[x] = R.__matrix[x] or {}
    R.__matrix[x][y] = R.__matrix[x][y] or {}
    R.__matrix[x][y].bc = bc
    R.__matrix[x][y].tc = tc
    R.__matrix[x][y].value = value
end

function R.render()
    local lastBc = nil
    local lastTc = nil
    local node = nil
    local line = nil
    
    local mx, my = monitor.getSize()
    for y = 1, my do
        for x = 1, mx do
            line = R.__matrix[x + R.__x]
            if line ~= nil then 
                node = line[y + R.__y]
            else
                node = nil
            end

            if node == nil then
                node = DEFAULT_NODE
            end

            if lastBc ~= node.bc then
                monitor.setBackgroundColor(node.bc)
                lastBc = node.bc
            end
            if lastTc ~= node.tc then
                monitor.setTextColor(node.tc)
                lastTc = node.tc
            end
            monitor.setCursorPos(x, y)
            monitor.write(node.value)
        end
    end
end

R.setMonitor(peripheral.find("monitor"))

return R
