queue = require("/utils/queue")
logger = require("/utils/logger")
navigation = require("/robot/navigation")
state = require("/state/state")

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

actions = Queue:new()
errorMessage = nil

ACTION_MOVING = "moving"
ACTION_MINING = "mining"
ACTION_REFUELING = "refueling"
ACTION_STORE = "store"
ACTION_ERROR = "error"

function setError(message)
    actions:clear()
    actions:push(ACTION_ERROR)
    errorMessage = message
end

function isInsideMiningSpot()
    local miningSpot = state.get("mining.spot")

    return navigation.x <= miningSpot.x.max
        and navigation.x >= miningSpot.x.min
        and navigation.z <= miningSpot.z.max
        and navigation.z >= miningSpot.z.min
end

function isInventoryFull()
    for i = 1, 16 do
        if turtle.getItemCount(i) == 0 then
            return false
        end
    end
    return true
end

function isRefuelRequired()
    local level = turtle.getFuelLevel()
    if level == "unlimited" then
        return false
    end
    local fuelMin = state.get("fuel.min", 200)
    return level < fuelMin
end

function handleRefueling()
    logger.info("Refueling!")
    local fuelSlot = state.get("fuel.slot", 1)
    local fuelMin = state.get("fuel.min", 200)

    logger.info("Looking for coal to refuel...")
    local coalConsumed = 0
    for i = 16, 1, -1 do
        detail = turtle.getItemDetail(i)
        if detail ~= nil and detail.name == "minecraft:coal" then
            logger.info("Consuming coal from "..fuelSlot)
            turtle.select(i)
            turtle.refuel()
            coalConsumed = coalConsumed + detail.count
        end
        if coalConsumed >= 64 then
            break
        end
    end

    logger.info("Looking for coal to put in the fuel slot...")
    for i = 1, 16 do
        if turtle.getItemCount(fuelSlot) == 64 then
            break
        end
        detail = turtle.getItemDetail(i)
        if detail ~= nil and detail.name == "minecraft:coal" then
            logger.info("Moving coal to "..fuelSlot)
            turtle.select(i)
            turtle.transferTo(fuelSlot)
        end
    end

    if isRefuelRequired() then
        logger.info("Moving to base to refuel")

        handleStoreItems() -- first store all items

        local fuelChest = state.get("chests.fuel")
        fuelChest.y = fuelChest.y + 1 -- 1 block above chest

        if not navigation.goTo(fuelChest, {"y", "x", "z"}) then
            return
        end

        turtle.select(fuelSlot)
        turtle.suckDown()
        turtle.refuel()
        turtle.suckDown()
    end

    if isRefuelRequired() then
        setError("Not enoght fuel")
    end

    logger.info("Refueling done!")
end

function handleStoreItems()
    logger.info("Storing items!")

    -- TODO: check if there is a coal block and go to store it into chests.fuel

    local fuelSlot = state.get("fuel.slot", 1)
    local itemsChest = state.get("chests.items")
    itemsChest.y = itemsChest.y + 1 -- 1 block above chest

    if not navigation.goTo(itemsChest, {"y", "x", "z"}) then
        return
    end

    for i = 1, 16 do
        local detail = turtle.getItemDetail(i)
        if detail ~= nil then
            local store = true
            if i == fuelSlot then
                if detail.name == "minecraft:coal" then
                    store = false
                end
            end
            if store then
                turtle.select(i)
                ok, _ = turtle.dropDown()
                if not ok then
                    break
                end
            end
        end
    end
end

function handleMoving()
    logger.info("Moving!")

    if not isInsideMiningSpot() then
        local position = state.get("mining.spot")
        position.x = position.x.min
        position.z = position.z.min
        position.y = position.y.max
        if not navigation.goTo(position, {"x", "z", "y"}) then
            return
        end
    end

    local position = state.get("mining.position")
    if position then
        if not navigation.goTo(position, {"x", "z", "y"}) then
            return
        end
    end

    actions:push(ACTION_MINING)
end

function handleMining()
    logger.info("Mining!")

    -- TODO: check if it's inside the mining area. If not, set state moving

    local miningSpot = state.get("mining.spot")
    local miningPosition = state.get("mining.position")
    local miningDirection = state.get("mining.position.direction")

    if not isInsideMiningSpot() then
        logger.warn("Trying to mine on a invalid position!")
        logger.warn("X:", navigation.x, "Y:", navigation.y, "Z:", navigation.z)
        logger.warn("X:", miningSpot.x.min, miningSpot.x.max, "Y:", miningSpot.y.min, miningSpot.y.max, "Z:", miningSpot.z.min, miningSpot.z.max)
        actions:push(ACTION_MOVING)
        return
    end

    if miningDirection.x == "forward" then
        navigation.face("forward")
    else
        navigation.face("back")
    end

    local limitX = (miningDirection.x == "forward" and navigation.x == miningSpot.x.max)
            or (miningDirection.x == "back" and navigation.x == miningSpot.x.min)

    if not limitX then
        if isInventoryFull() then
            return
        end
        turtle.dig()
    end

    if isInventoryFull() then
        return
    end
    turtle.digDown()

    local exists, block = turtle.inspectDown()
    if exists and block.name == 'minecraft:bedrock' then
        state.set("mining.finished", true)
        actions:push(ACTION_STORE)
        return
    end

    if limitX then
        local limitZ = (miningDirection.z == "right" and navigation.z == miningSpot.z.max)
                    or (miningDirection.z == "left" and navigation.z == miningSpot.z.min)
        if limitZ then
            if miningSpot.y.min == navigation.y then
                state.set("mining.finished", true)
                actions:push(ACTION_STORE)
                return
            end

            if not navigation.down() then
                setError("Stuck!")
                return
            end

            if miningDirection.z == "right" then
                miningDirection.z = "left"
            else
                miningDirection.z = "right"
            end

            if miningDirection.x == "forward" then
                miningDirection.x = "back"
            else
                miningDirection.x = "forward"
            end

        else -- not limit z
            if miningDirection.z == "right" then
                if miningDirection.x == "forward" then
                    navigation.turnRight()
                else
                    navigation.turnLeft()
                end
            else
                if miningDirection.x == "forward" then
                    navigation.turnLeft()
                else
                    navigation.turnRight()
                end
            end

            local exists, _ = turtle.inspect()
            if exists then
                local ok = turtle.dig()
                if not ok then
                    setError("Could not break the block!")
                    return
                end
            end

            if navigation.forward() then
                if miningDirection.z == "right" then
                    if miningDirection.x == "forward" then
                        navigation.turnRight()
                    else
                        navigation.turnLeft()
                    end
                else
                    if miningDirection.x == "forward" then
                        navigation.turnLeft()
                    else
                        navigation.turnRight()
                    end
                end
                 if miningDirection.x == "forward" then
                    miningDirection.x = "back"
                else
                    miningDirection.x = "forward"
                end
            else
                setError("Stuck!")
                return
            end
        end
    else
        navigation.forward() -- TODO: implement a count to handle it. Consider gravel situation, where it will not move.
    end

    miningPosition.x = navigation.x
    miningPosition.y = navigation.y
    miningPosition.z = navigation.z

    state.set("mining.position", miningPosition)
    state.set("mining.position.direction", miningDirection)
    actions:push(ACTION_MINING)
end

function handleError()
    -- TODO: send error to controler
    logger.error(errorMessage)
    sleep(10)
    actions:push(ACTION_ERROR)
end

local function main()
    logger.info("Starting Turtle Miner!")

    local fuelChest = state.get("chests.fuel")
    if fuelChest == nil then
        logger.error("Missing \"chests.fuel\" configuration")
        return
    end

    local itemsChest = state.get("chests.items")
    if itemsChest == nil then
        logger.error("Missing \"chests.items\" configuration")
        return
    end

    sleep(2)

    while true do
        if isRefuelRequired() then
            actions:pushFront(ACTION_REFUELING)
        elseif isInventoryFull() then
            actions:pushFront(ACTION_STORE)
        end

        if not state.get("mining.finished", false) and actions:size() == 0 then
            actions:push(ACTION_MOVING) -- TODO: implement a routine to leave mining area and wait for new instructions
        end

        action = actions:pull()
        if action == nil then
            logger.info("Finished")
            sleep(10)
        elseif action == ACTION_REFUELING then
            handleRefueling()
        elseif action == ACTION_STORE then
            handleStoreItems()
        elseif action == ACTION_MOVING then
            handleMoving()
        elseif action == ACTION_MINING then
            handleMining()
        elseif action == ACTION_ERROR then
            handleError()
        end
    end
end

parallel.waitForAny(main)

