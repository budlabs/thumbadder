# MAINTAINED AT https://git.budlabs.xyz/bud/thumbadder

## thumbadder - manually add thumbnails to files

first argument needs to be the path to a file.
Second argument is optional but if it is present
it should be the path to an image. If no second
image argument is passed, `zenity` is used to
prompt for an image file via the filechooser
dialog.

thumbadder doesn't set the **Thumb::URI** and
**Thumb::MTime** attributes, and might not work with
all filemanagers, only tested with `thunar`.
https://specifications.freedesktop.org/thumbnail-spec/thumbnail-spec-latest.html

### dependencies

`zenity`, `libnotify`, `gdk-pixbuf-thumbnailer`, `curl`

### example

```shell
$ thumbadder ~/Documents/file.md ~/Pictures/rose.jpg
# will generate thumbnails for file.md from rose.jpg
```

See this video on youtube for a demo:
https://youtu.be/TRzTxtFLJa4

Created by budRich@budlabs 2020
