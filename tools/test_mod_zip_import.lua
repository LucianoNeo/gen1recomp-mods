return function()
  local LauncherMods = require("src.mods.LauncherMods")
  local source = assert(os.getenv("HGSS_IMPORT_ZIP"),
    "HGSS_IMPORT_ZIP is required")
  local report = assert(os.getenv("HGSS_IMPORT_REPORT"),
    "HGSS_IMPORT_REPORT is required")
  local ok, result = LauncherMods.installZip(source, {
    replace = true,
    expectId = "HGSS_SPRITES",
  })
  local file = assert(io.open(report, "wb"))
  file:write(ok and ("OK " .. tostring(result))
    or ("ERROR " .. tostring(result)))
  file:close()
  for _ = 1, 10 do coroutine.yield() end
  love.event.quit()
end
