local LrView = import 'LrView'
local LrTasks = import 'LrTasks'
local LrFileUtils = import 'LrFileUtils'
local LrPathUtils = import 'LrPathUtils'
local LrDialogs = import 'LrDialogs'
local LrErrors = import 'LrErrors'
local LrLogger = import 'LrLogger'
local LrApplication = import 'LrApplication'

local MacSipsConverter = require 'MacSipsConverter'

local myLogger = LrLogger('HEICExport')
myLogger:enable("logfile")

local ExportServiceProvider = {}

-- Define which sections to hide for a seamless experience
ExportServiceProvider.hideSections = { 'exportLocation', 'fileSettings', 'imageSize' }

-- Default settings and forced pipeline values
function ExportServiceProvider.updateExportSettings(exportSettings)
    -- Forced pipeline for maximum HDR fidelity (16-bit TIFF with HDR metadata)
    exportSettings.LR_format = "TIFF"
    exportSettings.LR_export_bitDepth = 16
    exportSettings.LR_export_colorSpace = "Display P3"
    exportSettings.LR_export_compressionMethod = "None"
    exportSettings.LR_export_hdrOutput = true -- Enable HDR by default if using this plugin
    
    -- Custom plugin defaults
    if exportSettings.heicCompressionQuality == nil then
        exportSettings.heicCompressionQuality = 85
    end
end

-- Custom UI at the top of the dialog
function ExportServiceProvider.sectionsForTopOfDialog(f, propertyTable)
    return {
        {
            title = "HEIC HDR 导出管线",
            f:row {
                f:static_text {
                    title = "此插件采用高精度 HDR 转换管线，确保色彩与亮度完美转换。",
                    text_color = import 'LrColor'(0.2, 0.6, 0.2),
                    font = "<system/bold>",
                }
            },
            f:row {
                f:static_text {
                    title = "设置:",
                    alignment = "right",
                    width = LrView.share "label_width",
                },
                f:edit_field {
                    value = LrView.bind {
                        bind_to = propertyTable,
                        key = 'heicCompressionQuality',
                    },
                    max = 100,
                    min = 0,
                    width_in_digits = 4,
                    precision = 0,
                },
                f:static_text {
                    title = "HEIC 压缩质量 (0-100)",
                },
            },
        }
    }
end

-- Main processing loop
function ExportServiceProvider.processRenderedPhotos(functionContext, exportContext)
    local exportSettings = exportContext.propertyTable
    local nPhotos = exportContext.exportSession:countRenditions()
    
    local function logMsg(msg)
        myLogger:info(msg)
        local f = io.open("/tmp/heic_export.log", "a")
        if f then
            f:write(string.format("[%s] %s\n", os.date("%H:%M:%S"), msg))
            f:close()
        end
    end

    logMsg("--- New HEIC Export Service Session ---")
    
    local progressScope = exportContext:configureProgress {
        title = nPhotos > 1 
                and string.format("正在将 %d 张照片导出为 HEIC", nPhotos)
                or "正在将照片导出为 HEIC",
    }
    
    -- Get the target folder (since we hide exportLocation, we might want to ask or use a default)
    -- Actually, if we hide exportLocation, we might want to let the user pick in our own UI or 
    -- handle it differently. But the document says hiding it triggers auto-GC.
    -- Wait, if we hide exportLocation, where does the FINAL file go?
    -- "Lightroom 渲染引擎会自动将中间文件输出至系统的隐蔽临时目录" 
    -- We still need to know where the user wants the .heic file.
    
    -- Let's check how other plugins handle this. Usually if exportLocation is hidden,
    -- the plugin must provide its own way to choose the destination or it's a "Publish" service.
    
    -- Actually, if this is a regular Export Service, the user EXPECTS to pick a folder.
    -- If I hide exportLocation, I must provide a folder picker.
    
    local targetFolder = LrDialogs.runOpenPanel({
        title = "选择 HEIC 导出的目标文件夹",
        canChooseFiles = false,
        canChooseDirectories = true,
        canCreateDirectories = true,
        allowsMultipleSelection = false,
    })
    
    if not targetFolder or #targetFolder == 0 then
        logMsg("User canceled folder selection")
        return
    end
    targetFolder = targetFolder[1]

    local i = 0
    for _, rendition in exportContext:renditions() do
        i = i + 1
        local photo = rendition.photo
        local name = photo:getFormattedMetadata('fileName')
        
        progressScope:setPortionComplete(i - 1, nPhotos)
        progressScope:setCaption("正在渲染: " .. name)
        
        local success, pathOrMessage = rendition:waitForRender()
        
        if progressScope:isCanceled() then break end

        if success then
            progressScope:setPortionComplete(i - 0.5, nPhotos)
            local intermediateFile = pathOrMessage
            logMsg("Rendered: " .. intermediateFile)
            
            progressScope:setCaption("正在转码为 HEIC: " .. name)
            
            local baseName = LrPathUtils.removeExtension(name)
            local targetFile = LrPathUtils.child(targetFolder, baseName .. ".heic")
            
            local sipsSuccess, errMsg = MacSipsConverter.convertToHeic(
                intermediateFile, 
                targetFile, 
                exportSettings.heicCompressionQuality
            )
            
            if sipsSuccess then
                logMsg("Converted to: " .. targetFile)
                -- No need to delete intermediateFile if Lightroom's GC works as promised
                -- when exportLocation is hidden.
                rendition:renditionIsDone(true)
            else
                logMsg("SIPS Error: " .. tostring(errMsg))
                rendition:renditionIsDone(false, errMsg)
            end
        else
            logMsg("Render Error: " .. tostring(pathOrMessage))
            rendition:renditionIsDone(false, pathOrMessage)
        end
        
        progressScope:setPortionComplete(i, nPhotos)
    end
    
    logMsg("Export Session Finished")
end

-- Preset fields
function ExportServiceProvider.exportPresetFields()
    return {
        { key = 'heicCompressionQuality', default = 85 },
    }
end

return ExportServiceProvider
