#! /usr/bin/python
import ast
from trakt import Trakt
import getopt
import sys
import os
import fnmatch
import xml.etree.ElementTree as ET
import time

client_id = "aed654a151ce31fe2038107037b8bb1d61fcf3b06fe24a595e49075cefecd8d2"
secret_id = "d4a14732e5b03eaafb43bb4a8a3447100f415be4cc23b3c406c8f063cffb8187"
Trakt.configuration.defaults.client( id = client_id ,secret =  secret_id )
tmpfile = "/tmp/mpv-playing.txt"

input_dict ={
    'media_file'    : '',
    'path'          : '',
    'nfo_file'      : '',
    'media_type'    : '',
    'progress'      : '',
    'year'          : '',
    'command'       : '',
    'duration'      : '', 
}

def send_notify(title,text):
    os.system(('notify-send --icon trakt "' + title + '" "' + text  + '"' ).encode('ascii','replace'))

def get_access(config_file):
    res = Trakt['oauth/device'].code()
    if sys.version.startswith("3"):
        input ("Visit %s and put the code \"%s\" Then press enter\n" % (res['verification_url'] , res['user_code']) )
    else:
        raw_input ("Visit %s and put the code \"%s\" Then enter\n" % (res['verification_url'] , res['user_code']) )
    authorization = Trakt['oauth/device'].token(res['device_code'])
    f = open (config_file , "w")
    f.write(str(authorization))
    f.close()
    return authorization

def init_token():
    valid_config = False
    config_file = os.path.join( os.path.dirname(os.path.abspath(__file__)) ,"trakt.txt" )
    if not os.path.isfile(config_file):
        open ( config_file , "a" ).close()
    with open ( config_file , "r") as f:
        text = f.readline()
        f.close()
    try:
        authorization = ast.literal_eval(text)
        valid_config = True
    except:
        print ("config file not valid")
    if not valid_config:
        authorization = get_access(config_file)
    Trakt.configuration.defaults.oauth.from_response(authorization)

def get_info(nfo_file):
    tree = ET.parse(nfo_file)
    root = tree.getroot()
    ret = {'ids' : {}}
    if root.tag == "episodedetails":
        input_dict['media_type'] = "episode"
        # ret ['type'] = 'episode'
        for child in root:
            if child.tag == "episode":
                ret ['number'] = child.text
            elif child.tag == "season":
                ret ['season'] = child.text
# 
    elif root.tag == "tvshow":
        for child in root:
            if child.tag == "title":
                ret['title'] = child.text
            elif child.tag == "year":
                ret['year'] = child.text
            elif child.tag == "imdbid":
                ret['ids']['imdb'] = child.text
            elif child.tag == "id":
                ret['ids']['tvdb'] = child.text
# 
    elif root.tag == "movie" :
        input_dict['media_type'] = "movie"
        for child in root:
            if child.tag == "title":
                ret [ 'title' ] = child.text
            elif child.tag == "year":
                ret [ 'year' ] = child.text
            elif child.tag == 'id':
                ret ['ids']['imdb']  = child.text
            elif child.tag == "tmdbid":
                ret ['ids']['tmbd'] = child.text
    return ret

def find(pattern, path):
    result = []
    for root, dirs, files in os.walk(path):
        for name in files:
            if fnmatch.fnmatch(name, pattern):
                result.append(os.path.join(root, name))
    return result

def parse_options():
    optlist, args = getopt.getopt(sys.argv[1:],shortopts=None,longopts=["command=","progress=","path=" , "file=","duration="])
    for k,v in optlist:
        print("%s : %s" % (k,v))
        if k == "--path":
            input_dict['path'] =  os.path.abspath(v)
        elif k == "--file":
            input_dict['file'] = v
        elif k == "--progress":
            input_dict['progress'] = v
        elif k == "--command":
            input_dict['command'] = v
        elif k == "--duration":
            input_dict['duration'] = v 
    # 
    if input_dict['command'] == "play":
        f = os.path.splitext(input_dict['file']) [0]
        nfo_file=""
        if( len(find( f + "*nfo",input_dict['path'])) > 0 ):
            nfo_file = find( f + "*nfo",input_dict['path'])[0]
        if not nfo_file:
            nfo_file = find ("movie.nfo",input_dict['path'])[0]
        if not nfo_file:
            os.remove(tmpfile)
            exit(-1)
        print("nfo file is : %s" % nfo_file)
        # 
        media_info =  get_info(nfo_file)
        print ("media Info: " , media_info)
        print ("input dict:" , input_dict)
        t = input_dict['media_type'] + "\n"  + str(media_info) + "\n"
        episode_info = {}
        show_info = {}
        # 
        if input_dict['media_type'] == "movie" :
            # Trakt['scrobble'].pause(movie=media_info,progress=input_dict['progress'])
            Trakt['scrobble'].start(movie=media_info,progress=input_dict['progress'])
            # send_notify(media_info['title'] ,media_info['year'] + " --> %" + input_dict['progress'])
        elif input_dict['media_type'] == "episode":
            episode_info = media_info
            tvfile = os.path.join(input_dict['path'],"../","tvshow.nfo")
            show_info = get_info (tvfile)
            t = t + str(show_info) + "\n" 
            # Trakt['scrobble'].pause(show=show_info,episode=episode_info,progress=input_dict['progress'])
            Trakt['scrobble'].start(show=show_info,episode=episode_info,progress=input_dict['progress'])
            # send_notify ( show_info['title'] , "Season " + episode_info['season'] + " - Episode " + episode_info['number'])
        t = t + input_dict['duration'] + "\n" + str ( time.time() + (100 - float (input_dict['progress'])) / 100 *  float(input_dict['duration'])) + "\n" 
        # + "progress= " + input_dict['progress'] + "\n"
        f = open(tmpfile,"w")
        f.write(t)
        f.close()
    # 
    # elif input_dict['command'] == "pause":
    #     f = open (tmpfile,"r")
    #     media_type = f.readline().strip("\n")
    #     if media_type == "movie" :
    #         movie_info = ast.literal_eval(f.readline().strip("\n"))
    #         progress = f.readline().strip("\n")
    #         Trakt['scrobble'].pause(movie=movie_info,progress=float(progress))
    #     elif media_type == "episode" :
    #         show_info = ast.literal_eval(f.readline().strip("\n"))
    #         episode_info = ast.literal_eval(f.readline().strip("\n"))
    #         progress = f.readline().strip("\n")
    #         Trakt['scrobble'].pause(show=show_info,episode=episode_info,progress=float(progress))

    elif input_dict['command'] == "stop":
        f = open (tmpfile,"r")
        media_type = f.readline().strip("\n")
        if media_type == "movie" :
            movie_info = ast.literal_eval(f.readline().strip("\n"))
            duration = float (f.readline().strip("\n"))
            endtime =  float (f.readline().strip("\n"))
            now = time.time()
            progress = 100 * (1 - (endtime - time.time()) / duration )
            if now > ( endtime + 10 ) or progress < 93:
                os.remove(tmpfile)
                # exit (-1)
            send_notify ( movie_info['title'] ,movie_info['year'] + "  " +  str(progress))
            Trakt['scrobble'].stop(movie=movie_info,progress=progress)
        elif media_type == "episode" :
            episode_info = ast.literal_eval(f.readline().strip("\n"))
            show_info = ast.literal_eval(f.readline().strip("\n"))
            duration = float (f.readline().strip("\n"))
            endtime =  float (f.readline().strip("\n"))
            now = time.time()
            progress = 100 * (1 - (endtime - now) / duration )
            if now > (endtime + 10 ) or progress < 93:
                os.remove(tmpfile)
                # exit (-1)
            send_notify ( show_info['title'] , "Season " + episode_info['season'] + " - Episode " + episode_info['number'] + " --> %" + str(progress))
            Trakt['scrobble'].stop(show=show_info,episode=episode_info,progress=progress)

def test():
    init_token()
    for key, movie in Trakt['sync/watched'].movies().items():
        print('%s (%s)' % (movie.title, movie.year))    

if __name__ == '__main__':
    init_token()
    parse_options()
    # test()
