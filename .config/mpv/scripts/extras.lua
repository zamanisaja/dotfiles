require 'os'
local utils = require 'mp.utils'
-- Removes files from this list of extensions from now playing
exclude_extensions =  {'srt', 'vtt', 'jpg', 'jpeg', 'png', 'nfo', }

--replace matches on filenames
--format: {['string to match'] = 'value to replace as', ...} - replaces will be done in random order
--put as false to not replace anything
filename_replace = {
    -- ['^.*/']='',                            --strip paths from file, all before and last / removed
    ['[%s-]*[%[%(].-[%]%)][%s-]*']='',      --remove brackets, their content and surrounding white space
    ['_']=' ',                              --change underscore to space
    ['%.mkv']='',
    ['%.mp4']='',
    ['%.avi']='',
    ['%.mp3']='',
    -- ['%..*$']='',                           --remove extension
}

repeatable = false
dir = nil
cursor = 0
path = nil
length=0
defaultpath = "/"
mode = nil
save_name = "/home/saja/Videos/0-mpv.m3u"

function os.capture(cmd, raw)
  local f = assert(io.popen(cmd, 'r'))
  local s = assert(f:read('*a'))
  f:close()
  return string.sub(s, 0, -2)
end

function show_info(  )
    -- mp.command("show-progress")
    mp.osd_message(stripfile(mp.get_property('filename')),4)
end

function stripfile(pathfile)
  if pathfile == nil  then return "." end
    local tmp = pathfile
    if filename_replace then
        for k,v in pairs(filename_replace) do
            tmp = tmp:gsub(k, v)
        end
    end
    return tmp
end

function open_addmode(  )
  mode = "addmode"
  handler()
end

function open_playlistmode(  )
  mode = "playlist"
  handler()
end

function open_nowplaying(  )
  mode = "nowplaying"
  cursor = mp.get_property('playlist-pos')
  handler()
end

function handler(arg)
  if not path then
    if mp.get_property('path') then
      path = string.sub(mp.get_property("path"), 1, string.len(mp.get_property("path"))-string.len(mp.get_property("filename")))
    end
  end
  local output = ""
  if     mode == "addmode"  then output = "Navigator                   " .. path .. "\n-------------------------\n"
  dir,length = scandirectory(path) 
  elseif mode == "playlist" then output = "Playlist Organizer          " .. path .. "\n-------------------------\n"
  dir,length = scandirectory(path) 
  elseif mode == "nowplaying" then output="Now playing                 " ..         "\n-------------------------\n" 
  dir,length = scanplaylist()
  end

  local b = cursor - 5
  if b > 0 then output = output .. "...\n" end
  if b < 0 then b = 0                      end
  for a = b, b+15 ,1 do
    if a == length then break end
    if a == cursor then
      output = output .. tostring (a) .. ".> " .. stripfile(dir[a]) .. " <"
      if arg then 
        if mode == "playlist" then        output = output .. " + added to playlist\n" 
        elseif mode == "addmode" then     output = output .. " + added to now playing ▶\n" 
        end
      else output= tostring (a) .."." .. output.."\n" end
    else
      output = output .. tostring (a) .. "." .. stripfile(dir[a]) .."\n"
    end
    if a == b + 15 then
      output = output .. " ..."
    end
  end
  mp.osd_message(output, 5)


  -- path = utils.split_path ( mp.get_property("filename"))
end


function scandirectory(arg)
  local directory = {}
  local search = string.gsub(arg, "%s+", "\\ ")..'*'
  local popen=nil
  local i = 0
  if mode == "playlist" then
      popen = io.popen('find '..search..' -maxdepth 0  \\( -name  "*m3u" -or -type d  \\) -printf "%f\\n" 2>/dev/null')
  else
    popen = io.popen('find '..search..'  ! -regex  ".*\\(jpg\\|png\\|nfo\\|srt\\|sub\\|vtt\\|pdf\\|txt\\)$" -maxdepth 0 -printf "%f\\n" 2>/dev/null')
  end
  if popen then
      for dirx in popen:lines() do
          directory[i] = dirx
          i=i+1
      end
  else
      print("error: could not scan for files")
  end
  return directory, i
end

function clean_playlist(  )
  n = tonumber (mp.get_property('playlist-count'))
  i = 0
  while (i < n ) do
    f = mp.get_property("playlist/" .. tostring(i) .. "/filename")
    print ("Index is: " .. tostring(i))
    print ("Filename is " .. tostring(f))
    for _,ext in pairs(exclude_extensions) do
      if string.match(f,ext) then
    -- if string.match(f,".jpg") then
        print ("Removing file " .. tostring(i) .."th : " .. f .. " from playlist")
        mp.command("playlist-remove " .. tostring(i))
        n = n-1
        i = i-1
      end
    end
    i = i + 1
  end
end


function scanplaylist(  )
  n = tonumber(mp.get_property('playlist-count'))
  items = {}
  for i = 0 ,n-1 do
    _ , items [i] = utils.split_path ( mp.get_property("playlist/" .. tostring(i) .. "/filename"))
  end
  return items,n
end

function navdown()
  if mode == nil then
    return -1
  end
  if cursor ~= length-1
   then
    cursor = cursor+1
  elseif repeatable then
    cursor = 0
  end
  handler()
end

function navup()
  if mode == nil then
    return -1
  end
  if cursor ~= 0 then
    cursor = cursor-1
  elseif repeatable then
    cursor = length-1
  end
  handler()
end

function navdownfast()
  if mode == nil then
    return -1
  end
  if cursor ~= length -1
   then
    cursor = cursor + 10
  elseif repeatable then
    cursor = 0
  end
  handler()
end

function navupfast()
  if mode == nil then
    return -1
  end
  if cursor ~= 0 then
    cursor = cursor-10
  elseif repeatable then
    cursor = length-1
  end
  handler()
end

function  add()
  if dir == nil or path == nil then return  end
  local item = dir[cursor]
  if item then
    local isfolder = os.capture('if test -d '..string.gsub(path..item, "%s+", "\\ ")..'; then echo "true"; fi')
    local isfile   = os.capture('if test -f '..string.gsub(path..item, "%s+", "\\ ")..'; then echo "true"; fi')
    -- print ("isfile: " .. tostring(isfile))
    -- print ("isfolder: " .. tostring(isfolder))
    if mode == "playlist" and isfolder =="true" then return  -1 end
    if mode == "playlist" and isfile == "true" and string.find(tostring(item),"m3u") ~= nil then
      addtoplaylist(path..item)
      handler(true)
    elseif mode == "addmode" and (isfolder =="true" or isfile == "true" )then
      mp.commandv("loadfile", path..item, "append-play")
      handler(true)
    elseif mode == "nowplaying" then
      -- print("----> cursor " .. cursor )
      -- print("----> now " .. mp.get_property('playlist-pos'))
      diff = cursor - mp.get_property('playlist-pos')
      for i=1,diff do
        mp.command("playlist-next")
      end
      if diff <0 then 
        diff = -1 * diff 
      for i=1,diff do
        mp.command("playlist-prev")
      end
      end
    end
  end
end

function deletefromnowplaying(  )
  if mode == "nowplaying" then
    mp.command("playlist-remove " .. tostring(cursor))
    handler()
  end
end

function save_playlist(  )
  file = io.open(save_name , "a+")
  for i=0,mp.get_property('playlist-count')-1 do 
    file:write ( mp.get_property('playlist/'..tostring(i)..'/filename') ,"\n")
  end
  mp.osd_message("Added now playing to " .. save_name ,4 )
  file:close()
end

function changepath(args)
  path = args
  dir,length = scandirectory(path)
  cursor=0
  handler()
end

function opendir()
  if mode == "nowplaying" or mode == nil then
    return -1
  end
  handler()
  local item = dir[cursor]
  if item then
    local isfolder = os.capture('if test -d '..string.gsub(path..item, "%s+", "\\ ")..'; then echo "true"; fi')
    local isplaylist = string.find(tostring(item),"m3u")
    if isfolder=="true" then
      changepath(path..dir[cursor].."/")
    elseif isplaylist ~= nil then
      print ("--------> playlist")
    end
  end
end


function parentdir()
  if mode == "nowplaying" or mode == nil then
    return -1
  end
  handler()
  local parent = os.capture('cd '..string.gsub(path, "%s+", "\\ ")..'; cd .. ; pwd').."/"
  changepath(parent)
end

function addtoplaylist(playlist) 
  playlist = playlist:gsub ("^%/*","/")
  path = mp.get_property("working-directory") .. "/" .. mp.get_property("path")
  common , diff ,  j   = rel_path ( playlist , path)
  line = diff .. path:sub(j,#path)
  -- text = "playlist = " .. playlist .. "\n"
  --     .. "path     = " .. path .. "\n"
  --     .. "common   = " .. common .. "\n"
  --     .. "diff     = " .. diff .. "\n"
  --     .. "j        = " .. j .. "\n"
  --     .. "line     = " .. line .. "\n"
  -- print (text)
  file = io.open ( playlist ,  "a+" )
  file:write(line,"\n")
  path , _ = utils.split_path(playlist)  
end

function rel_path( path_start , path_dest )
  m = math.max(unpack({#path_start,#path_dest}))
  local i = 1
  local common = ""
  while ( i < m and path_start:sub(i,i) == path_dest:sub(i,i) ) do  
        common = common .. path_dest:sub(i,i)
        i = i+1 
    end 
  _, count = string.gsub(path_start:sub(i,#path_start),"%/","")
  local line = ""
  for j=1,count-1 do line = line .. "../" end
  return common , line, i
end



-- mp.add_forced_key_binding("A", "toggle", togglemode)

mp.register_event("start-file", clean_playlist)
-- mp.register_event("playback-restart", clean_playlist)


mp.add_forced_key_binding("Ctrl+o", "addmode", open_addmode)
mp.add_forced_key_binding("Ctrl+p", "playlistmode", open_playlistmode)
mp.add_forced_key_binding("ctrl+ENTER", "nowplayintmode", open_nowplaying)

mp.add_forced_key_binding("a", "add", add)
mp.add_forced_key_binding("d", "delete", deletefromnowplaying, "repeatable")

-- mp.add_forced_key_binding("Ctrl+s", "save", save_playlist)

mp.add_forced_key_binding("J", "navdownfast", navdownfast, "repeatable")
mp.add_forced_key_binding("K", "navupfast", navupfast, "repeatable")

mp.add_forced_key_binding("j", "navdown", navdown, "repeatable")
mp.add_forced_key_binding("k", "navup", navup, "repeatable")
mp.add_forced_key_binding("h", "opendir", opendir)
mp.add_forced_key_binding("l", "parentdir", parentdir)

mp.add_forced_key_binding("i", "show_info", show_info)
