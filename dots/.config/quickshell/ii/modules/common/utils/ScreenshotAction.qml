pragma ComponentBehavior: Bound
pragma Singleton
import qs.modules.common
import qs.modules.common.utils
import qs.modules.common.functions
import qs.modules.common.widgets
import qs.services
import QtQuick
import QtQuick.Controls
import Qt.labs.synchronizer
import Quickshell

Singleton {
    id: root

    enum Action {
        Copy,
        Edit,
        Search,
        CharRecognition,
        Record,
        RecordWithSound
    }

    property string imageSearchEngineBaseUrl: Config.options.search.imageSearch.imageSearchEngineBaseUrl
    property string fileUploadApiEndpoint: "https://uguu.se/upload"

    function getCommand(x, y, width, height, screenshotPath, action, saveDir = "", windowTitle = "") {
        // Set command for action
        const rx = Math.round(x);
        const ry = Math.round(y);
        const rw = Math.round(width);
        const rh = Math.round(height);
        const cropBase = `magick ${StringUtils.shellSingleQuoteEscape(screenshotPath)} `
            + `-crop ${rw}x${rh}+${rx}+${ry} +repage`
        const cropToStdout = `${cropBase} -`
        const cropInPlace = `${cropBase} '${StringUtils.shellSingleQuoteEscape(screenshotPath)}'`
        const cleanup = `rm '${StringUtils.shellSingleQuoteEscape(screenshotPath)}'`
        const slurpRegion = `${rx},${ry} ${rw}x${rh}`
        const uploadAndGetUrl = (filePath) => {
            return `curl -sF files[]=@'${StringUtils.shellSingleQuoteEscape(filePath)}' ${root.fileUploadApiEndpoint} | jq -r '.files[0].url'`
        }
        const annotationCommand = `${Config.options.regionSelector.annotation.useSatty ? "satty" : "swappy"} -f -`;

        // ShareX-like folder structure (YYYY-MM) and filename ([Sanitized_Window_Title]_[YYYY-MM-DD_HH.MM.SS].png)
        function sanitizeFilename(title) {
            if (!title) return "Screenshot";
            let clean = title.replace(/[\/\\*?"<>|:\$;$]/g, "_");
            clean = clean.replace(/\s+/g, "_");
            clean = clean.trim();
            if (clean.length > 50) {
                clean = clean.substring(0, 50);
            }
            return clean;
        }

        const date = new Date();
        const year = date.getFullYear();
        const month = String(date.getMonth() + 1).padStart(2, '0');
        const day = String(date.getDate()).padStart(2, '0');
        const hour = String(date.getHours()).padStart(2, '0');
        const min = String(date.getMinutes()).padStart(2, '0');
        const sec = String(date.getSeconds()).padStart(2, '0');

        const monthFolder = `${year}-${month}`;
        const baseSaveDir = saveDir !== "" ? saveDir : `${Directories.pictures.replace("file://","")}/Screenshots`;
        const finalSaveDir = `${baseSaveDir}/${monthFolder}`;

        const cleanTitle = windowTitle ? sanitizeFilename(windowTitle) : "Screenshot";
        const saveFileName = `${cleanTitle}_${year}-${month}-${day}_${hour}.${min}.${sec}.png`;
        const savePath = `${finalSaveDir}/${saveFileName}`;

        switch (action) {
            case ScreenshotAction.Action.Copy:
                return [
                    "bash", "-c",
                    `mkdir -p '${StringUtils.shellSingleQuoteEscape(finalSaveDir)}' && \
                    ${cropToStdout} | tee >(wl-copy) > '${StringUtils.shellSingleQuoteEscape(savePath)}' && \
                    ${cleanup} && \
                    action=\$(notify-send -i '${StringUtils.shellSingleQuoteEscape(savePath)}' -a 'Screenshot' 'Скриншот сохранен' 'Сохранено в ${StringUtils.shellSingleQuoteEscape(savePath)} и скопировано в буфер' --action='open=Открыть папку') && \
                    if [ "\$action" = "open" ]; then \
                        xdg-open '${StringUtils.shellSingleQuoteEscape(finalSaveDir)}'; \
                    fi`
                ]
                break;
            case ScreenshotAction.Action.Edit:
                if (Config.options.regionSelector.annotation.useSatty) {
                    return [
                        "bash", "-c",
                        `mkdir -p '${StringUtils.shellSingleQuoteEscape(finalSaveDir)}' && \
                        ${cropToStdout} | satty -f - -o '${StringUtils.shellSingleQuoteEscape(savePath)}' --early-exit --save-after-copy && \
                        ${cleanup} && \
                        if [ -f '${StringUtils.shellSingleQuoteEscape(savePath)}' ]; then \
                            wl-copy -t image/png < '${StringUtils.shellSingleQuoteEscape(savePath)}' && \
                            action=\$(notify-send -i '${StringUtils.shellSingleQuoteEscape(savePath)}' -a 'Screenshot' 'Скриншот сохранен' 'Сохранено в ${StringUtils.shellSingleQuoteEscape(savePath)} и скопировано в буфер' --action='open=Открыть папку') && \
                            if [ "\$action" = "open" ]; then \
                                xdg-open '${StringUtils.shellSingleQuoteEscape(finalSaveDir)}'; \
                            fi; \
                        fi`
                    ]
                } else {
                    return ["bash", "-c", `${cropToStdout} | ${annotationCommand} && ${cleanup}`]
                }
                break;
            case ScreenshotAction.Action.Search:
                return ["bash", "-c", `${cropInPlace} && xdg-open "${root.imageSearchEngineBaseUrl}$(${uploadAndGetUrl(screenshotPath)})" && ${cleanup}`]
                break;
            case ScreenshotAction.Action.CharRecognition:
                return ["bash", "-c", `${cropInPlace} && tesseract '${StringUtils.shellSingleQuoteEscape(screenshotPath)}' stdout -l $(tesseract --list-langs | awk 'NR>1{print $1}' | tr '\\n' '+' | sed 's/\\+$/\\n/') | wl-copy && ${cleanup}`]
                break;
            case ScreenshotAction.Action.Record:
                return ["bash", "-c", `${Directories.recordScriptPath} --region '${slurpRegion}'`]
                break;
            case ScreenshotAction.Action.RecordWithSound:
                return ["bash", "-c", `${Directories.recordScriptPath} --region '${slurpRegion}' --sound`]
                break;
            default:
                console.warn("[Region Selector] Unknown snip action, skipping snip.");
                return;
        }
    }
}
