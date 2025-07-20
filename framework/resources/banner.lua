local api = require("framework.api")
local info = require("framework.resources.info")

local emojiPool = {
    "  ٩꒰｡•◡•｡꒱۶         ",
    "  ฅ՞••՞ฅ             ",
    "  ₍^_ _^₎zᶻ          ",
    "  /ᐠ .⸝⸝⸝. ྀིﾏ         "
}

print(api.base.rand())
local selectEmoji = emojiPool[math.tointeger(api.base.gameRand(1, #emojiPool))]

local banner = "starting ...\n" ..
    "\n" ..
    selectEmoji .. "\n" ..
    "●┬────────────◆ https://github.com/circuar\n" ..
    " ├─◆ version: " .. info.version .. "\n" ..
    " ├─◆ date:    " .. info.date .. "\n" ..
    " └─◆ author:  " .. info.author .. "\n"
return banner
