local api = require "framework.api"
local PlayerManager = {
    rawPlayers = {},
    playerCount = 0,
}

---初始化玩家服务
function PlayerManager.init()
    local players = api.base.getGamePlayers()
    PlayerManager.playerCount = #players
    for index, value in ipairs(players) do
        PlayerManager.rawPlayers[index] = value
    end
end

function PlayerManager.getRawPlayer(index)
    return PlayerManager.rawPlayers[index]
end

function PlayerManager.getAllRawPlayers()
    return PlayerManager.rawPlayers
end

function PlayerManager.getPlayerCount()
    return PlayerManager.playerCount
end

return PlayerManager
