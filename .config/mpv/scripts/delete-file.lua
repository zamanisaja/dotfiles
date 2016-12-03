mputils = require 'mp.utils'
filename = nil

function del(  )
    t = {}
    if filename == mp.get_property("path") then
        -- dir , name = mputils.split_path(filename)
        name = filename:gsub ('%..*$' , '')
        command = "deleting file " .. name
        -- print (command)
        t.args = {"rm" , filename , name .. ".en." .. "srt", name .. ".es." .. "srt", name .. ".fa." .. "srt" }
        res = mputils.subprocess(t) 
        mp.osd_message(command, 5)
    end
end

function help(  )
    filename = mp.get_property("path")
    mp.add_timeout(3,del)
end

mp.add_forced_key_binding("D", "delete-file", help)
