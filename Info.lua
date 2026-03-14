return {
    LrSdkVersion = 13.0,
    LrToolkitIdentifier = 'com.shawnrain.heicexport',
    LrPluginName = 'HEIC Export',
    LrPluginInfoUrl = 'https://github.com/shawnrain/Lrplugin',
    LrPluginInfoText = 'Exports images as HEIF (HEIC) with HDR support using macOS sips.',
    
    LrExportServiceProvider = {
        title = "HEIC 导出 (HDR)",
        file = "HEICExportService.lua",
        id = "com.shawnrain.heicexport"
    },
    
    VERSION = { major=1, minor=1, revision=0, build=2, date="2026-03-14" },
}
