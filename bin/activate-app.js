#!/usr/bin/env osascript -l JavaScript


function logMessage(msg) {
    //console.log(new Date().toLocaleString() + " - " + msg);
}

function executeCommand(command) {
    try {
        let currentApp = Application.currentApplication();
        currentApp.includeStandardAdditions = true;
        currentApp.doShellScript(command);
        return true;
    } catch (error) {
        logMessage(`Failed to execute command: ${error}`);
        return false;
    }
}

function findTargetWindow(appName, windowTitle) {
    logMessage(`Looking for ${appName} window with title containing "${windowTitle}"`);
    
    let app, wins;
    try {
        const apps = Application("System Events").applicationProcesses.whose({name: appName});
        for (var i = 0; i < apps.length; i++) {
            const app = apps[i];
            if (app.name() == "ghostty") {
                const wins = app.windows.whose({name: windowTitle})
                if (wins.length > 0) {
                    return { app, wins };
                }
            }
        }
    } catch (e) {
        logMessage(`Error in findAndActivateWindow: ${e}`);
    }
    return { app: null, wins: null };
}

function run(argv) {

    if (argv.length < 3) {
        logMessage("Usage: activate-app.js [appName] [windowTitle] [openCommand]");
        return "Missing required arguments";
    }

    const appName = argv[0];
    const windowTitle = argv[1];
    const openCommand = argv[2];
    
    try {
        // ウィンドウを探して有効化
        const { app, wins } = findTargetWindow(appName, windowTitle);

        if (!app || !wins) {
            logMessage(`No matching window found, running: ${openCommand}`);
            executeCommand(openCommand);
            return;
        }
        
        for (var i = 0; i < wins.length; i++) {
            const win = wins[i];
            if (win.value({ _property: "AXMinimized" }) === true) {
                logMessage("Window is minimized; restoring it.");
                win.attributes.byName("AXMinimized").value = false;
                win.attributes.byName("AXMain").value = true;
                app.frontmost = true
            } else if (app.frontmost()) {
                //logMessage("Window is frontmost; minimizing it.");
                //app.setFrontmost(false);
                //win.attributes.byName("AXMinimized").value = true;
            } else {
                logMessage("Window is not frontmost; bringing it to front.");
                win.attributes.byName("AXMain").value = true;
                app.frontmost = true
            }
        }
    } catch (e) {
        logMessage(`Error in main process: ${e}, running: ${openCommand}`);
        //executeCommand(openCommand);
        throw e
    }
}
