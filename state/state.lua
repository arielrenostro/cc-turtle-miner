local stateLoaded = false
local SETTINGS_FILENAME = "/state/state.settings"
local STATE_SETTINGS_PREFIX = "tstate."

local S = {}

function S.get(key, default)
    if not stateLoaded then
        settings.load(SETTINGS_FILENAME)
        stateLoaded = true
    end

    local result = settings.get(STATE_SETTINGS_PREFIX..key)
    if result ~= nil then
        return result
    end

    S.set(key, default)
    return default
end

function S.set(key, value)
    settings.set(STATE_SETTINGS_PREFIX..key, value)
    settings.save(SETTINGS_FILENAME)
end

return S
