-- hs.hotkey.bind({"cmd"}, "1", function()
-- hs.hotkey.bind({"cmd"}, '2', function() hs.application.LaunchOrFocus('terminal') end)
hs.hotkey.bind({"cmd"}, "1", function() hs.application.launchOrFocus("Google Chrome") end)
hs.hotkey.bind({"cmd"}, '2', function() hs.application.launchOrFocus("hyper") end)

hs.hotkey.bind({"cmd",'shift'}, 'down', function() hs.execute ("echo pause > ~/.config/mpv/fifo") end)
hs.hotkey.bind({"cmd",'alt'},   'down', function() hs.execute ("echo add volume -5 > ~/.config/mpv/fifo") end)
hs.hotkey.bind({"cmd",'alt'},   'up'  , function() hs.execute ("echo add volume +5 > ~/.config/mpv/fifo") end)
hs.hotkey.bind({"cmd",'alt'},   'right'  , function() hs.execute ("echo seek +5 > ~/.config/mpv/fifo") end)
hs.hotkey.bind({"cmd",'alt'},   'left'   , function() hs.execute ("echo seek -5 > ~/.config/mpv/fifo") end)

-- local browser   = hs.appfinder.appFromName("Google Chrome")
hs.hotkey.bind({ 'cmd', 'ctrl' }, 'b', function() ext.app.smartLaunchOrFocus('Google Chrome') end)
