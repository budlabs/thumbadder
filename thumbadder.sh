#!/bin/bash

ERH() { cat << 'EOB' >&2
thumbadder - manually add thumbnails to files

first argument needs to be the path to a file.
Second argument is optional but if it is present
it should be the path to an image. If no second
image argument is passed, *zenity* is used to
prompt for an image file via the filechooser
dialog.

thumbadder doesn't set the Thumb::URI and
Thumb::MTime attributes, and might not work with
all filemanagers, only tested with *thunar*.

DEPENDENCIES
------------
zenity, libnotify, gdk-pixbuf-thumbnailer, curl

EXAMPLE
-------
$ thumbadder ~/Documents/file.md ~/Pictures/rose.jpg
# will generate thumbnails for file.md from rose.jpg

See this video on youtube for a demo:
https://youtu.be/TRzTxtFLJa4

Created by budRich@budlabs 2020
EOB
exit 0
}

for a do case $a in -h|--help ) ERH ;; esac ; done

main() {

  local trg img imgdir

  [[ -f ${trg:=$1} ]] || ERX "file not found, $trg"
  [[ -f ${img:=$2} ]] || {
    # https://wiki.archlinux.org/index.php/XDG_user_directories
    imgdir="$(xdg-user-dir PICTURES)"
    : "${imgdir:=$HOME}"

    img=$(command cd "$imgdir" &&                  \
      zenity --title "select new thumbnail source" \
             --file-selection                      \
             --file-filter '*.jpg *.png'
    )

    [[ -f $img ]] || ERX "no image selected"
  }
  
  trg=$(realpath --no-symlinks "$trg")
  uri=$(getURI "$trg")

  generatethumbs "$img" "$uri" "$trg"
  touch "$trg"
}

generatethumbs() {
  local img=$1 uri=$2 trg=$3
  local thumbdir="$HOME/.cache/thumbnails"
  local md5 tmpdir

  md5=$(echo -n "$uri" | md5sum | cut -f1 -d' ')
  mkdir -p "${thumbdir}/"{normal,large}
  # mtime=$(stat -c "%Y" "$trg")
  tmpdir="$(mktemp -d)"

  types=([128]=normal [256]=large)

  for f in "${!types[@]}"; do
    gdk-pixbuf-thumbnailer -s "$f" "$img" "$tmpdir/${types[$f]}"
    mv -f "$tmpdir/${types[$f]}" "$thumbdir/${types[$f]}/$md5.png"
  done

  rm -rf "$tmpdir"
}

getURI() {
  local trg="$1"

  echo -n "file://$trg"            \
    | curl -Gso /dev/null          \
           -w '%{url_effective}'   \
           --data-urlencode @- ""  \
    | cut -c 3- | sed '
        s|%26|\&|g
        s|%24|$|g
        s|%2F|/|g
        s|%2B|+|g
        s|%29|)|g
        s|%28|(|g
        s|%3A|:|g
        s|%3D|=|g
        s|%40|@|g
        s|%2C|,|g
     '
}

set -E
trap '[ "$?" -ne 77 ] || exit 77' ERR

ERM(){

  local mode

  getopts xr mode
  case "$mode" in
    x ) urg=critical ; prefix='[ERROR]: '   ;;
    r ) urg=low      ; prefix='[WARNING]: ' ;;
    * ) urg=normal   ; mode=m ;;
  esac
  shift $((OPTIND-1))

  msg="${prefix}$*"

  if [[ -t 2 ]]; then
    echo "$msg" >&2
  else
    notify-send -u "$urg" "$msg"
  fi

  [[ $mode = x ]] && exit 77
}

ERX() { ERM -x "$*" ;}
ERR() { ERM -r "$*" ;}

main "$@"
