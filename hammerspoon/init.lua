hs.hotkey.bind({ "cmd", "alt", "ctrl" }, "W", function()
    hs.alert.show("Hello World!")
end)

local logger = hs.logger.new("main", "debug")

local hotkeys = {}

table.insert(hotkeys, hs.hotkey.bind({ "ctrl" }, "a", function()
    hs.eventtap.keyStroke({ "cmd" }, "a", 0)
    hs.eventtap.keyStroke({ "cmd" }, "a", 0)
end))

table.insert(hotkeys, hs.hotkey.bind({ "ctrl" }, "c", function()
    hs.eventtap.keyStroke({ "cmd" }, "c", 0)
    hs.eventtap.keyStroke({ "cmd" }, "c", 0)
end))

table.insert(hotkeys, hs.hotkey.bind({ "ctrl" }, "x", function()
    hs.eventtap.keyStroke({ "cmd" }, "x", 0)
    hs.eventtap.keyStroke({ "cmd" }, "x", 0)
end))

table.insert(hotkeys, hs.hotkey.bind({ "ctrl" }, "v", function()
    hs.eventtap.keyStroke({ "cmd" }, "v", 0)
    hs.eventtap.keyStroke({ "cmd" }, "v", 0)
end))

table.insert(hotkeys, hs.hotkey.bind({ "ctrl" }, "z", function()
    hs.eventtap.keyStroke({ "cmd" }, "z", 0)
    hs.eventtap.keyStroke({ "cmd" }, "z", 0)
end))

table.insert(hotkeys, hs.hotkey.bind({ "ctrl", "shift" }, "z", function()
    hs.eventtap.keyStroke({ "cmd", "shift" }, "z", 0)
    hs.eventtap.keyStroke({ "cmd", "shift" }, "z", 0)
end))

-- Note: making this variable local makes the garbage collector clean it up after a while
watcher = hs.application.watcher.new(function(applicationTitle, event)
    if applicationTitle == "WezTerm" then
        if event == hs.application.watcher.activated then
            for i, hotkey in ipairs(hotkeys) do
                hotkey:disable()
            end
        elseif event == hs.application.watcher.deactivated then
            for i, hotkey in ipairs(hotkeys) do
                hotkey:enable()
            end
        end
    end
end)
watcher:start()
