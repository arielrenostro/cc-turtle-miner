local T = {
    __monitor = peripheral.find("monitor")
}

function T.setMonitor(monitor)
    T.__monitor = monitor
end

function T.__setOpts(opts)
    opts = opts or {}

    local x, y = T.__monitor.getCursorPos()
    opts.x = opts.x or x
    opts.y = opts.y or y
    opts.bc = opts.bc or colors.black
    opts.tc = opts.tc or colors.white

    T.__monitor.setCursorPos(opts.x, opts.y)
    T.__monitor.setBackgroundColor(opts.bc)
    T.__monitor.setTextColor(opts.tc)
end

function T.writeCenter(text, opts)
    local x, _ = T.__monitor.getSize()
    local txtSize = #text
    local padding = (txtSize < x) and (x - txtSize) / 2 or 1
    opts.x = padding
    T.write(text, opts)
end

function T.write(text, opts)
    T.__setOpts(opts)
    T.__monitor.write(text)
end

return T
