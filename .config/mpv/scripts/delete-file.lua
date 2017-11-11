mputils = require 'mp.utils'
filename = nil

function del(  )
    t = {}
    if filename == mp.get_property("path") then
        name = filename:gsub ('%..*$' , '')
        command = "deleting file " .. name
        t.args = {"rm" , filename , name .. ".en." .. "srt", name .. ".es." .. "srt", name .. ".fa." .. "srt" }
        res = mputils.subprocess(t) 
        mp.osd_message(command, 5)
    end
end

function help(  )
    filename = mp.get_property("path")
    mp.add_timeout(3,del)
end

function shift_del()
    filename = mp.get_property("path")
    t = {}
    name = filename:gsub ('%..*$' , '')
    mp.osd_message("deleting file " .. name , 5)
    t.args = {"rm" , filename , name .. ".en." .. "srt", name .. ".es." .. "srt", name .. ".fa." .. "srt" }
    res = mputils.subprocess(t)
end

mp.add_forced_key_binding("del", "delete-file", help)
mp.add_forced_key_binding("BS", "delete-file", help)
mp.add_forced_key_binding("Shift+del", "shift-delete-file", shift_del)
mp.add_forced_key_binding("Shift+BS", "shift-delete-file", shift_del)
