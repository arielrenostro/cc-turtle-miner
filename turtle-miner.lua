-- List = {
--   __size = 0,
--   __array = {},
-- }

-- function List:new(o)
--   o = o or {}
--   setmetatable(o, self)
--   self.__index = self
--   self.__array = {}
--   self.__size = 0
--   return o
-- end

-- function List:size()
--   return self.__size
-- end

-- function List:add(elem)
--   self.__array[self.__size] = elem
--   self.__size = self.__size + 1
-- end

-- function List:get(idx)
--   return self.__array[idx]
-- end

-- function List:array()
--   return self.__array
-- end

-- print("Starting rednet")

-- rednet.open("left")
-- rednet.host("mining", "turtle")

-- local queue = List:new()

-- local function messageReceiver()
--     while true do
--         local sender, message, protocol = rednet.receive()
--         queue:add(textutils.serialiseJSON({ sender = sender, message = message, protocol = protocol }))
--     end
-- end

-- local function printer()
--     while true do 
--         print(queue:size())
--         if queue:size() > 0 then
--             for i=0, queue:size() - 1, 1 do
--                 print(queue:get(i))
--             end
--         end
--         sleep(1)
--     end
-- end

-- parallel.waitForAny(messageReceiver, printer)

function isInventoryFull()
    for i = 1, 16 do
        if turtle.getItemCount(i) == 0 then
            return false
        end
    end
    return true
end

function isPossibleDig(side)
    local exists, block = nil
    if side == "down" then
        exists, block = turtle.inspectDown()
    elseif side == "up" then
        exists, block = turtle.inspectUp()
    else
        exists, block = turtle.inspect()
    end

    if not exists then
        return false
    end

    for i = 1, 16 do
        local detail = turtle.getItemDetail(i)
        if detail == nil then
            return true
        end
        if detail.name == block.name and detail.count < 64 then
            return true
        end
    end

    return false
end


position = { 
    x = 10, 
    y = 2, 
    z = 0, 
    facing = "forward"
}
miningPosition = {
    x = 10,
    y = 0,
    z = 0,
    direction = {
        x = "forward",
        z = "right"
    },
    finished = false
}
miningLimits = {
    x = {
        s = 10,
        e = 100
    },
    y = nil,
    z = {
        s = 0,
        e = 100
    }
}
fuelChest = {
    x = -2,
    y = 0,
    z = 0
}
dropChest = {
    x = -2,
    y = 0,
    z = 3
}

fuelSlot = 1
fuelMin = 200
state = "mining"

function move(direction)
    print("Moving:", direction)
    sleep(2)
    local ok, message = nil
    
    if direction == "forward" then
        ok, message = turtle.forward()
        if ok then
            if position.facing == "forward" then
                position.x = position.x + 1
            elseif position.facing == "left" then
                position.z = position.z - 1
            elseif position.facing == "back" then
                position.x = position.x - 1
            elseif position.facing == "right" then
                position.z = position.z + 1
            end
        end

    elseif direction == "back" then
        ok, message = turtle.back()
        if ok then
            if position.facing == "forward" then
                position.x = position.x - 1
            elseif position.facing == "left" then
                position.z = position.z + 1
            elseif position.facing == "back" then
                position.x = position.x + 1
            elseif position.facing == "right" then
                position.z = position.z - 1
            end
        end

    elseif direction == "up" then
        ok, message = turtle.up()
        if ok then
            position.y = position.y + 1
        end

    elseif direction == "down" then
        ok, message = turtle.down()
        if ok then
            position.y = position.y - 1
        end
    end

    print("X:", position.x, "Y:", position.y, "Z:", position.z)
    if ok then
        print("Didn't moved")
    end

    return ok
end

function turnLeft()
    turtle.turnLeft()

    if position.facing == "forward" then
        position.facing = "left"
    elseif position.facing == "left" then
        position.facing = "back"
    elseif position.facing == "back" then
        position.facing = "right"
    elseif position.facing == "right" then
        position.facing = "forward"
    end
end

function face(direction)
    print("Facing request:", direction)

    while position.facing ~= direction do
        turnLeft()
        print("Facing:", position.facing)
    end
end

function goTo(destination, sequence)
    print("Going to X:", destination.x, "Y:", destination.y, "Z:", destination.z, "|", sequence[0], sequence[1], sequence[2])

    i = 0
    repeat
        if sequence[i] == 'x':
            while position.x ~= destination.x do
                if position.x < destination.x then
                    face("forward")
                elseif position.x > destination.x then
                    face("back")
                end
                if not move("forward") then
                    if not move("up") then
                        errorMessage = "Stuck!"
                        state = "error"
                        return false
                    end
                end
            end
        elseif sequence[i] == 'y':
            while position.y ~= destination.y do
                local ok = nil
                if position.y < destination.y then
                    ok = move("up")
                else
                    ok = move("down")
                end
                if not ok then
                    errorMessage = "Stuck!"
                    state = "error"
                    return false
                end
            end
        elseif sequence[i] == 'z':
            while position.z ~= destination.z do
                if position.z < destination.z then
                    face("right")
                elseif position.z > destination.z then
                    face("left")
                end
                if not move("forward") then
                    if not move("up") then
                        errorMessage = "Stuck!"
                        state = "error"
                        return false
                    end
                end
            end
        end
    until sequence[i]
    return true
end 

function handleRefueling()
    print("Refueling!")

    local tmpPosition = {
        x = fuelChest.x,
        y = fuelChest.y + 1, -- 1 block above chest
        z = fuelChest.z
    }
    goTo(tmpPosition, {"y", "x", "z"})

    print("Getting fuel from bottom")
    turtle.select(fuelSlot)
    turtle.suckDown()
    turtle.refuel()
    turtle.suckDown()

    print("Refuel done")
    if turtle.getFuelLevel() ~= "unlimited" and turtle.getFuelLevel() < fuelMin then
        errorMessage = "Not enoght fuel"
        state = "error"
    else
        print("Moving again")
        state = "moving"
    end
end

function handleStoreItems() {
    print("Storing items!")
    -- TODO

    if miningPosition.finished then
        print("Finished!")
        for i = 0; 5 do
            move("up")
        end
        state = "finished"
    end
}

function handleMoving()
    print("Moving!")

    local tmpPosition = {
        x = miningLimits.x.s,
        y = nil,
        z = miningLimits.z.s
    }
    if miningLimits.y ~= nil then
        tmpPosition.y = miningLimits.y.s
    end

    if not goTo(tmpPosition, {"x", "z", "y"}) then
        return
    end

    if miningPosition then
        if not goTo(miningPosition, {"x", "z", "y"}) then
            return
        end
    end

    state = "mining"
end

function handleMining()
    print("Mining!")
    sleep(1)

    print("Fuel Level:", turtle.getFuelLevel())
    if turtle.getFuelLevel() < fuelMin then
        state = "refueling"
        return
    end

    -- TODO: check if it's inside the mining area. If not, set state moving

    if miningPosition.direction.x == "forward" then
        face("forward")
    else
        face("back")
    end

    if isInventoryFull() {
        state = "storeItems"
        return
    }
    turtle.dig()

    if isInventoryFull() {
        state = "storeItems"
        return
    }
    turtle.digBottom()

    exists, block = turtle.inspectDown()
    if exists and block.name == 'minecraft:bedrock' then
        miningPosition.finished = true
        state = "storeItems"
        return
    end

    local limitXReached = (miningPosition.direction.x == "forward" and position.x == miningLimits.x.e)
                    or (miningPosition.direction.x == "back" and position.x == miningLimits.x.s)
    local limitZReached = false

    if limitXReached then
        limitZReached = (miningPosition.direction.z == "right" and position.z == miningLimits.z.e)
                    or (miningPosition.direction.z == "left" and position.z == miningLimits.z.s)
        if limitZReached then
            if not move("down") then
                errorMessage = "Stuck!"
                state = "error"
                return
            end

            if miningPosition.direction.z == "right" then
                miningPosition.direction.z = "left"
            else
                miningPosition.direction.z = "right"
            end

            if miningPosition.direction.x == "forward" then
                miningPosition.direction.x = "back"
            else
                miningPosition.direction.x = "forward"
            end

        else -- not limit z
            if miningPosition.direction.z == "right" then
                turnRight()
            else
                turnLeft()
            end
            turtle.dig() -- TODO: handle error

            if move("forward") then
                if miningPosition.direction.z == "right" then
                    turnRight()
                else
                    turnLeft()
                end
                 if miningPosition.direction.x == "forward" then
                    miningPosition.direction.x = "back"
                else
                    miningPosition.direction.x = "forward"
                end
            else
                errorMessage = "Stuck!"
                state = "error"
                return
            end
        end
    else
        if not move("forward") then
            errorMessage = "Stuck!"
            state = "error"
        end
    end

    miningPosition.x = position.x
    miningPosition.y = position.y
    miningPosition.z = position.z
end

function handleError()
-- TODO: send error to controler
    print(errorMessage)
    sleep(1)
end

function detectFacing()
-- TODO: tries to move any direction to find facing direction
    return position.facing
end 

local function main()
    position.facing = detectFacing()
    state = "mining"

    while true do
        if state == "finished" then
            sleep(1)
        elseif state == "refueling" then
            handleRefueling()
        elseif state == "storeItems" then
            handleStoreItems()
        elseif state == "moving" then
            handleMoving()
        elseif state == "mining" then
            handleMining()
        elseif state == "error" then
            handleError()
        end
    end
end

parallel.waitForAny(main)

