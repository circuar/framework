local tests = require("test.test")

for index, value in ipairs(tests) do
    value()
end

