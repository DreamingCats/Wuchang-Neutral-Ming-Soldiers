-- Release entry-point check in a standalone Lua runtime; not a game behavior test.
local scripts = assert(arg[1], "pass Scripts directory")
for _, name in ipairs({"main", "config", "runtime", "targets"}) do
    assert(loadfile(scripts .. "/" .. name .. ".lua"))
end
local config = assert(loadfile(scripts .. "/config.lua"))()
assert(config.enabled == true, "release default must be enabled")
local installs = 0
local originalRequire = require
require = function(name)
    if name == "config" then return config end
    if name == "runtime" then
        return {install = function() installs = installs + 1 end}
    end
    return originalRequire(name)
end
assert(loadfile(scripts .. "/main.lua"))()
assert(installs == 1, "enabled must install runtime")
config.enabled = false
assert(loadfile(scripts .. "/main.lua"))()
assert(installs == 1, "disabled must not load/install runtime")
print("PASS: four Lua files parse; default=true; enabled loads runtime; disabled skips runtime")
