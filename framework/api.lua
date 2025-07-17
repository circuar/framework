local api = {}

---发送全局事件
---@param event string 事件名称
---@param data table 事件数据
function api.sendEvent(event, data)
    LuaAPI.global_send_custom_event(event, data)
end

---向对象发送事件
---@param unit Unit 对象
---@param event string 事件名称
---@param data table 事件数据
function api.sendEventToUnit(unit, event, data)
    LuaAPI.unit_send_custom_event(unit, event, data)
end

--- 设置对象属性
---@param unit Unit 对象
---@param key string 属性键
---@param value any 属性值
---@param type Enums.ValueType 属性类型
function api.setUnitProperty(unit, key, value, type)
    unit.set_kv_by_type(type, key, value)
end

---移除对象属性
---@param unit Unit 对象
---@param key string 属性键
function api.removeUnitProperty(unit, key)
    unit.remove_kv(key)
end

--- 获取对象属性值
--- @param unit Unit 对象
--- @param key string 属性键
--- @param type Enums.ValueType 属性类型
--- @return any 属性值
function api.getUnitProperty(unit, key, type)
    return unit.get_kv_by_type(key, type)
end

---添加标签
---@param unit Unit 对象
---@param tag string 标签名称
function api.addUnitTag(unit, tag)
    unit.add_tag(tag)
end

---移除标签
---@param unit Unit 对象
---@param tag string 标签名称
function api.removeUnitTag(unit, tag)
    unit.remove_tag(tag)
end

---清除所有标签
---@param unit Unit
function api.removeAllUnitTags(unit)
    unit.clear_tag()
end

--- 检查对象是否有指定标签
---@param unit Unit 对象
---@param tag string 指定标签
---@return boolean
function api.checkUnitTag(unit, tag)
    return unit.has_tag(tag)
end

---创建固定风场
---@param position Vector3 床架坐标
---@param shape Enums.WindFieldShapeType 风场形状
---@param radius number 半径
---@param duration number 持续时间
function api.createWindField(position, shape, radius, duration)
    GameAPI.create_constant_wind_field(position, shape, radius, duration)
end

---设置全局风场是否启用
---@param status boolean 是否启用
function api.setGlobalWindFieldEnabled(status)
    GameAPI.set_global_wind_enabled(status)
end

---设置全局风场频率
---@param frequency number 风场频率
function api.setGlobalWindFieldFrequency(frequency)
    GameAPI.set_global_wind_frequency(frequency)
end

---设置全局风场风向力
---@param forceX number X方向风力
---@param forceY number Y方向风力
function api.setGlobalWindFieldForce(forceX, forceY)
    GameAPI.set_global_wind_force(forceX, forceY)
end

---设置两个单位之间的碰撞状态
---@param unitA Unit 第一个单位
---@param unitB Unit 第二个单位
---@param status boolean 碰撞状态，true表示启用碰撞，false表示禁用碰撞
function api.setCollisionEnabledBetween(unitA, unitB, status)
    GameAPI.enable_collision_between_units(unitA, unitB, status)
end

---设置玩家胜利
---@param player Role 玩家对象
---@param showEndUI boolean? 是否显示胜利界面
function api.playerWin(player, showEndUI)
    if showEndUI then
        player.game_win_and_show_result_panel()
    else
        player.win()
    end
end

---设置玩家失败
---@param player Role 玩家对象
---@param showEndUI boolean? 是否显示失败界面
function api.playerLose(player, showEndUI)
    if showEndUI then
        player.game_lose_and_show_result_panel()
    else
        player.lose()
    end
end

---游戏结束
function api.gameEnd()
    GameAPI.game_end()
end

---设置菲涅尔效果
---@param effectivePlayer Role
---@param targetUnit Unit
---@param factor number
---@param color integer
---@param intensity integer
---@param duration number
function api.setFresnel(effectivePlayer, targetUnit, factor, color, intensity, duration)
    if duration then
        effectivePlayer.set_unit_fresnel(targetUnit, factor, color, intensity)
    else
        effectivePlayer.set_unit_fresnel_gradual(targetUnit, factor, color, intensity, duration)
    end
end

---关闭对象的菲涅尔效果
---@param effectivePlayer Role
---@param targetUnit Unit
function api.disableFresnel(effectivePlayer, targetUnit)
    effectivePlayer.disable_unit_fresnel(targetUnit)
end

---开启对象的描边
---@param effectivePlayer Role
---@param targetUnit Unit
---@param width integer
---@param color integer
function api.enableUnitOutline(effectivePlayer, targetUnit, width, color)
    effectivePlayer.set_unit_outline(targetUnit, width, color)
end

---关闭对象的描边
---@param effectivePlayer Role
---@param targetUnit Unit
function api.disableUnitOutline(effectivePlayer, targetUnit)
    effectivePlayer.disable_unit_mask(targetUnit)
end

---开启单位的蒙版
---@param effectivePlayer Role
---@param targetUnit Unit
---@param color integer
function api.enableUnitMask(effectivePlayer, targetUnit, color)
    effectivePlayer.set_unit_mask(targetUnit, color)
end

---关闭对象的蒙版
---@param effectivePlayer Role
---@param targetUnit Unit
function api.disableUnitMask(effectivePlayer, targetUnit)
    effectivePlayer.disable_unit_mask(targetUnit)
end

---创建组件
---@param presetId integer 组件预设ID
---@param position Vector3 组件位置
---@param rotation Quaternion 组件旋转
---@param scale Vector3 组件缩放
---@param player Role? 所属玩家
---@return Obstacle
function api.createComponent(presetId, position, rotation, scale, player)
    return GameAPI.create_obstacle(presetId, position, rotation, scale, player)
end

---创建生物
---@param presetId integer 生物预设ID
---@param position Vector3 生物位置
---@param rotation Quaternion 生物旋转
---@param scale Vector3 缩放
---@param player Role? 所属玩家
function api.createCreature(presetId, position, rotation, scale, player)
    return GameAPI.create_creature(presetId, position, rotation, scale, player)
end

---销毁对象
---@param unit Unit 对象
function api.destroyUnit(unit)
    GameAPI.destroy_unit(unit)
end

---注册全局事件监听器
---@param event string 事件名称
---@param callback fun(data:table) 回调函数，接收事件数据
---@return integer listenerId 监听器ID
function api.registerEventListener(event, callback)
    return LuaAPI.global_register_custom_event(event, callback)
end

---注册单位事件监听器
---@param unit Unit 对象
---@param event string 事件名称
---@param callback fun(data:table) 回调函数，接收事件数据
---@return integer listenerId 监听器ID
function api.registerUnitEventListener(unit, event, callback)
    return LuaAPI.unit_register_custom_event(unit, event, callback)
end

---取消全局事件监听器
---@param listenerId integer 监听器ID
function api.unregisterEventListener(listenerId)
    LuaAPI.global_unregister_custom_event(listenerId)
end

---取消单位事件监听器
---@param unit Unit 对象
---@param listenerId integer 监听器ID
function api.unregisterUnitEventListener(unit, listenerId)
    LuaAPI.unit_unregister_custom_event(unit, listenerId)
end
