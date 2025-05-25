mtext = require("/monitor/text")
mrender = require("/monitor/render")

monitor = peripheral.find("monitor")
monitor.clear()
monitor.setBackgroundColor(colors.black)
monitor.setTextColor(colors.white)

function drawButtons()
    monitor.setBackgroundColor(colors.white)
    monitor.setTextColor(colors.red)
    monitor.setCursorPos(1, 8)
    monitor.write(" /\\ ")
    monitor.setCursorPos(1, 9)
    monitor.write("<  >")
    monitor.setCursorPos(1, 10)
    monitor.write(" \\/ ")
end

-- local mx, my = monitor.getSize()
-- for y = 1, my do
--     monitor.setCursorPos(1, y)
--     for i = 1, mx do
--         monitor.write((i - 1) % 10)
--     end
-- end

-- mtext.writeCenter("Teste", {y = 2, bc = colors.green})
-- mtext.writeCenter("Test", {y = 3, tc = colors.pink, bc = colors.yellow})
-- mtext.writeCenter("Batata Frita", {y = 4, tc = colors.red, bc = colors.white})


mrender.setTextChar(1, 6, colors.white, colors.black, "T")
mrender.setTextChar(2, 6, colors.white, colors.black, "E")
mrender.setTextChar(3, 6, colors.white, colors.black, "S")
mrender.setTextChar(4, 6, colors.white, colors.black, "T")

mrender.setTextChar(1 + 6, 22, colors.white, colors.black, "O")
mrender.setTextChar(2 + 6, 22, colors.white, colors.black, "U")
mrender.setTextChar(3 + 6, 22, colors.white, colors.black, "T")
mrender.setTextChar(4 + 6, 22, colors.white, colors.black, " ")
mrender.setTextChar(5 + 6, 22, colors.white, colors.black, "O")
mrender.setTextChar(6 + 6, 22, colors.white, colors.black, "F")
mrender.setTextChar(7 + 6, 22, colors.white, colors.black, " ")
mrender.setTextChar(8 + 6, 22, colors.white, colors.black, "S")
mrender.setTextChar(9 + 6, 22, colors.white, colors.black, "C")
mrender.setTextChar(10 + 6, 22, colors.white, colors.black, "R")
mrender.setTextChar(11 + 6, 22, colors.white, colors.black, "E")
mrender.setTextChar(12 + 6, 22, colors.white, colors.black, "E")
mrender.setTextChar(13 + 6, 22, colors.white, colors.black, "N")
mrender.render()

drawButtons()


while true do
    local event, side, x, y = os.pullEvent("monitor_touch")
    print("The monitor on side " .. side .. " was touched at (" .. x .. ", " .. y .. ")")

    if (x >= 1 and x <= 3 and y == 8) then
        mrender.scrollY(1)
    elseif (x >= 1 and x <= 3 and y == 10) then
        mrender.scrollY(-1)
    elseif (x >= 1 and x <= 2 and y == 9) then
        mrender.scrollX(1)
    elseif (x >= 3 and x <= 4 and y == 9) then
        mrender.scrollX(-1)
    end

    mrender.render()
    drawButtons()
end

for i = 1, 10 do
    sleep(1)
    mrender.scrollY(1)
    if i % 2 == 0 then
        mrender.scrollX(1)
    end
    mrender.render()
end