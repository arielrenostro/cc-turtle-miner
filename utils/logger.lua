local state = require("/state/state")

local ERROR = 1
local WARN = 2
local INFO = 3
local DEBUG = 4
local LOG_LEVELS = {
    ["error"] = ERROR,
    ["warn"] = WARN,
    ["info"] = INFO,
    ["debug"] = DEBUG,
}

local LOG_LEVEL = LOG_LEVELS[state.get("logger.loglevel", "info")]

local L = {}

function L.info(...)
    if LOG_LEVEL >= INFO then
        print("I:", ...)
    end
end

function L.warn(...)
    if LOG_LEVEL >= WARN then
        print("W:", ...)
    end
end

function L.error(...)
    if LOG_LEVEL >= ERROR then
        print("E:", ...)
    end
end

function L.debug(...)
    if LOG_LEVEL >= DEBUG then
        print("D:", ...)
    end
end

return L
