local logger = require("/utils/logger")
local Queue = require("/utils/queue")

local N = {
    x = 0,
    y = 0,
    z = 0,
    facing = nil,
}

function _debug(ok)
    if ok then
        logger.debug("X:", N.x, "Y:", N.y, "Z:", N.z)
    else
        logger.debug("Didn't move")
    end
end

function N.detectFacing()
    logger.debug("Detecting facing...")

    local x, y, z = gps.locate()
    if x == nil then
        logger.error("GPS not found!")
        return nil
    end

    local moviments = Queue:new()
    local direction = nil
    for i = 0, 2 do
        ok, _ = turtle.forward()
        if ok then
            moviments:push("forward")
            direction = "forward"
            break
        end
        
        ok, _ = turtle.back()
        if ok then
            moviments:push("back")
            direction = "back"
            break
        end
        
        ok, _ = turtle.up()
        if ok then
            moviments:push("up")
        end
    end
    
    local gx, gy, gz = gps.locate()
    if direction == "forward" then
        if gx > x then
            direction = "forward"
        elseif gx < x then
            direction = "back"
        elseif gz > z then
            direction = "right"
        else
            direction = "left"
        end
    elseif direction == "back" then
        if gx < x then
            direction = "forward"
        elseif gx > x then
            direction = "back"
        elseif gz < z then
            direction = "right"
        else
            direction = "left"
        end
    else
        direction = nil
    end

    local m = moviments:pull()
    while m ~= nil do
        if m == "forward" then
            turtle.back()
        elseif m == "up" then
            turtle.down()
        elseif m == "back" then
            turtle.forward()
        end
        m = moviments:pull()
    end

    if direction == nil then
        logger.error("Stuck, could not found facing!")
    end

    return direction
end

function N.forward()
    logger.debug("Moving: forward")

    ok, message = turtle.forward()
    if ok then
        if N.facing == "forward" then
            N.x = N.x + 1
        elseif N.facing == "left" then
            N.z = N.z - 1
        elseif N.facing == "back" then
            N.x = N.x - 1
        elseif N.facing == "right" then
            N.z = N.z + 1
        end
    end

    _debug(ok)
    return ok
end

function N.back()
    logger.debug("Moving: back")

    ok, message = turtle.back()
    if ok then
        if N.facing == "forward" then
            N.x = N.x - 1
        elseif N.facing == "left" then
            N.z = N.z + 1
        elseif N.facing == "back" then
            N.x = N.x + 1
        elseif N.facing == "right" then
            N.z = N.z - 1
        end
    end

    _debug(ok)
    return ok
end

function N.up()
    logger.debug("Moving: up")

    ok, message = turtle.up()
    if ok then
        N.y = N.y + 1
    end

    _debug(ok)
    return ok
end

function N.down()
    logger.debug("Moving: down")

    ok, message = turtle.down()
    if ok then
        N.y = N.y - 1
    end

    _debug(ok)
    return ok
end

function N.turnLeft()
    turtle.turnLeft()

    if N.facing == "forward" then
        N.facing = "left"
    elseif N.facing == "left" then
        N.facing = "back"
    elseif N.facing == "back" then
        N.facing = "right"
    elseif N.facing == "right" then
        N.facing = "forward"
    end
    -- logger.debug("Facing:", N.facing)
end

function N.turnRight()
    turtle.turnRight()

    if N.facing == "forward" then
        N.facing = "right"
    elseif N.facing == "left" then
        N.facing = "forward"
    elseif N.facing == "back" then
        N.facing = "left"
    elseif N.facing == "right" then
        N.facing = "back"
    end
    -- logger.debug("Facing:", N.facing)
end

function N.face(direction)
    if N.facing ~= direction then
        logger.debug("Facing request:", direction)
    end

    while N.facing ~= direction do
        N.turnLeft()
    end
end


function N.goTo(destination, sequence)
    logger.info(
        "Going to X:", destination.x,
        "Y:", destination.y,
        "Z:", destination.z, 
        "|", sequence[1], sequence[2], sequence[3]
    )
    logger.debug("X:", N.x, "Y:", N.y, "Z:", N.z)

    i = 1
    repeat
        if sequence[i] == 'x' then
            while N.x ~= destination.x do
                if N.x < destination.x then
                    N.face("forward")
                elseif N.x > destination.x then
                    N.face("back")
                end
                if not N.forward() then
                    if not N.up() then
                        return false, "Stuck!"
                    end
                end
            end
        elseif sequence[i] == 'y' then
            while N.y ~= destination.y do
                local ok = nil
                if N.y < destination.y then
                    ok = N.up()
                else
                    ok = N.down()
                end
                if not ok then
                    return false, "Stuck!"
                end
            end
        elseif sequence[i] == 'z' then
            while N.z ~= destination.z do
                if N.z < destination.z then
                    N.face("right")
                elseif N.z > destination.z then
                    N.face("left")
                end
                if not N.forward() then
                    if not N.up() then
                        return false, "Stuck!"
                    end
                end
            end
        end
        i = i + 1
    until sequence[i] == nil
    return true, nil
end 

logger.debug("Nav API: Loading...")

N.facing = N.detectFacing()
if N.facing == nil then
    return nil
end

N.x, N.y, N.z = gps.locate()
if N.x == nil then
    logger.error("GPS not found!")
    return nil
end

logger.debug("Nav API: X", N.x, "Y", N.y, "Z", N.z, N.facing)

return N
