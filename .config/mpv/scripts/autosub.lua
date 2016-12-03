-- requires subliminal, version 1.0 or newer
-- default keybinding: b
-- add the following to your input.conf to change the default keybinding:
-- keyname script_binding auto_load_subs
local utils = require 'mp.utils'
function load_sub_fn()
    subl = "/usr/local/bin/subliminal" -- use 'which subliminal' to find the path
    mp.msg.info("Searching subtitle")
    mp.osd_message("Searching subtitle")
    t = {}
    t.args = {subl, "download", "-f" , "-l", "en" , "-l" ,"fa" , "-l"  , "es", mp.get_property("path")}
    res = utils.subprocess(t)
   -- t2 = {} 
--    t2.args = {"youtube-dl" , "--output" , "(%(upload_date)s)-%(uploader)s-%(title)s-(%(id)s).%(ext)s" , "`echo" , mp.get_property("path") , "|" , "sed 's/.*-(\(.*\)).mp4/\1/'`"}
    -- utils.subprocess(t2)
    print ("------------------------------>\n" .. tostring(res.error))
    if res.status == 0 then
        mp.commandv("rescan_external_files", "reselect") 
        mp.msg.info("Subtitle download succeeded")
        mp.osd_message("Subtitle download succeeded")
    else
        mp.msg.warn("Subtitle download failed")
        mp.osd_message("Subtitle download failed")
    end
end

mp.add_forced_key_binding("S", "auto_load_subs", load_sub_fn)
