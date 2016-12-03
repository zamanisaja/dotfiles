#!/bin/bash

MUSIC_DIR=$HOME/Music

if [ -z "$1" ]
then
    HOST="127.0.0.1"
else
    HOST="$1"
fi

function get_info
{
    title="$(mpc -h $HOST --format %title% current)"
    artist="$(mpc -h $HOST --format %artist% current)"
    file="$(mpc -h $HOST --format %file% current)"
    album="${file%/*}"
    album_dir="$MUSIC_DIR/$album"
    covers=$(find "$album_dir" -maxdepth 1 -iregex ".*\(cover\|folder\).\(jpg\|png\)")
    notify-send -t 3 "$title" "$artist" -i "$covers"
}

get_info
