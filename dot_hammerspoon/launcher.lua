local chooser = nil
local apps = {}

-- アプリケーションのリストを取得
local function getApps()
  local appList = hs.application.enabledApplications()
  for _, app in ipairs(appList) do
    if app.bundleID then     -- バンドルIDが存在する場合のみ追加
      table.insert(apps, {
        text = app.name,
        subText = app.bundleID,
        image = hs.image.imageFromAppBundle(app.bundleID),
        path = app.path
      })
    end
  end
end

-- ランチャーUIを表示
local function showLauncher()
  if not chooser then
    chooser = hs.chooser.new(function(choice)
      if choice then
        hs.application.launchOrFocus(choice.path)
      end
    end)
  end

  chooser:choices(apps)
  chooser:show()
end

-- 初期化
getApps()

return {
  showLauncher = showLauncher
}
