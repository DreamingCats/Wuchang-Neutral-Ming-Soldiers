-- Configuration is read once when the game starts. Restart after editing it.
local config = require("config")
if config.enabled ~= true then
    print("[NeutralHumansDemo] v0.3.0 disabled by Scripts/config.lua; no hooks or polling installed\n")
    return
end
require("runtime").install()
