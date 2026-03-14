local MacSipsConverter = {}

local LrTasks = import 'LrTasks'
local LrPathUtils = import 'LrPathUtils'

-- Escape path for command line
local function escapeCmdArg(path)
    return '"' .. path:gsub('"', '\\"') .. '"'
end

function MacSipsConverter.convertToHeic(sourcePath, targetPath, quality)
    -- Default quality to 85 if not provided
    quality = quality or 85
    
    local logFile = "/tmp/heic_export.log"
    -- Command to convert using macOS sips
    -- Example: sips -s format heic -s formatOptions 85 source.tif --out target.heic
    -- We redirect output to a log file to prevent pipe blocking and help with debugging.
    local cmd = string.format(
        '/usr/bin/sips -s format heic -s formatOptions %d %s --out %s >> %s 2>&1',
        quality,
        escapeCmdArg(sourcePath),
        escapeCmdArg(targetPath),
        escapeCmdArg(logFile)
    )
    
    -- Execute using LrTask (must be run within an async task, which postProcessRenderedPhotos provides)
    local status = LrTasks.execute(cmd)
    
    if status == 0 then
        return true, nil
    else
        return false, string.format("sips 转码失败 (状态码: %s)。请检查 %s 了解详情。", tostring(status), logFile)
    end
end

return MacSipsConverter
