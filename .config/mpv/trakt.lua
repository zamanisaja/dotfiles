mputils = require 'mp.utils'
traktpy = "/home/saja/.config/mpv/traktpy.py"

function start_to_traktpy(  )
    path = mp.get_property("path")
    if path == nil then
        return -1
    else
        local dir, filename = mputils.split_path(path)
        percentage = mp.get_property("percent-pos")
        duration = mp.get_property("duration")
        if duration == nil then
            return -1
        end
        print ( "------------" .. traktpy .. " --path ".. dir .. " --file " .. filename .. " --progress " .. percentage.. " --command" .. " play " .. "--duration" .. duration)
        t = {}
        t.args = {traktpy , "--path", dir , "--file" , filename , "--progress", percentage, "--command" ,"play" , "--duration" ,duration}
        res = mputils.subprocess(t) 
    end
end

function stop_to_traktpy(  )
    t = {}
    t['cancellable']= false
    percentage = mp.get_property("percent-pos")
    t.args = {traktpy , "--command" , "stop" }
    print ("------------" .. traktpy .. " --command stop ")
    res = mputils.subprocess(t) 
end



mp.register_event('playback-restart'   ,start_to_traktpy)
mp.register_event('end-file'   ,stop_to_traktpy)
-- mp.register_event('playback-restart'   ,test)
-- mp.observe_property("percent-pos" , "float" , test)






-- mp.register_event("file-loaded",start_to_traktpy)
