Render = require("/monitor/render")
Text = require("/monitor/components/text")
Button = require("/monitor/components/button")
Layer = require("/monitor/layers/layer")
OverlayLayers = require("/monitor/layers/overlay_layers")

monitor = peripheral.find("monitor")
monitor.clear()
monitor.setBackgroundColor(colors.black)
monitor.setTextColor(colors.white)


local render = nil

local backgroundLayer = Layer:new()
backgroundLayer:addComponent(1, 6, Text:new({ value = "TEST", bc = colors.white, tc = colors.black }))
backgroundLayer:addComponent(6, 22, Text:new({ value = "OUT OF SCREEN", bc = colors.white, tc = colors.black }))
backgroundLayer:addComponent(10, 10, Button:new({ value = "Button", onClick = function() print("Click button") end }))

local buttonLayer = Layer:new()
buttonLayer:addComponent(3, 1, Button:new({ value = "^", onClick = function() backgroundLayer:scrollY(-1); render:render() end }))
buttonLayer:addComponent(1, 4, Button:new({ value = "<", onClick = function() backgroundLayer:scrollX(-1); render:render() end }))
buttonLayer:addComponent(5, 4, Button:new({ value = ">", onClick = function() backgroundLayer:scrollX(1); render:render() end }))
buttonLayer:addComponent(3, 7, Button:new({ value = "v", onClick = function() backgroundLayer:scrollY(1); render:render() end }))
buttonLayer:setScroll(1, 5)

local overlayLayers = OverlayLayers:new()
overlayLayers:add(backgroundLayer)
overlayLayers:add(buttonLayer)

render = Render:new({
    redirect = peripheral.find("monitor"),
    layer = overlayLayers,
})
render:render()

while true do
    local event, side, x, y = os.pullEvent("monitor_touch")
    print("The monitor on side " .. side .. " was touched at (" .. x .. ", " .. y .. ")")

    render:onClick(x, y)
end
