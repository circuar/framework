local PlayerManager = require "framework.core.PlayerManager"
local api           = require "framework.api"


---@class Player
---@field private playersCache table<Player> 玩家对象缓存
---@field private rawPlayer Role 原始玩家对象
---@field private playerIndex integer 玩家索引
---@field private associateRole Character 关联角色
local Player = {
    playersCache = {}
}
Player.__index = Player

function Player.getPlayer(playerIndex)
    if Player.playersCache[playerIndex] then
        return Player.playersCache[playerIndex]
    end

    local rawPlayer = PlayerManager.getRawPlayer(playerIndex)
    local self = setmetatable({
        rawPlayer = rawPlayer,
        playerIndex = playerIndex,
        associateRole = api.base.getPlayerCtrlRole(rawPlayer)
    }, Player)
    Player.playersCache[playerIndex] = self
    return self
end

function Player:getRawPlayer()
    return self.rawPlayer
end

function Player:getRawRole()
    return self.associateRole
end

function Player.getPlayerCount()
    return PlayerManager.getPlayerCount()
end

return Player
