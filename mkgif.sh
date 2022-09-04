#!/bin/bash
set -e
PROG=${0##*/}
pushd "$(dirname "$0")/.." >/dev/null
popd >/dev/null

_err() { echo "$PROG: $@" >&2; exit 1; }

FPS=50
MAXSIZE=800
MAXCOLORS=64
INFILE=
OUTFILE=
DITHER=false

while [[ $# -gt 0 ]]; do case "$1" in
  -h|-help|--help) cat << EOF
Make a GIF from a video
usage: $PROG [options] <videofile>
options:
  -fps=FPS      Set FPS limit. Default: $FPS
  -size=SIZE    Set size limit. Default: $MAXSIZE
  -colors=N     Set color limit. Default: $MAXCOLORS
  -d[ither]     Enable dithering
  -o FILE, -output=FILE
                Write output to FILE instead of <videofile>.gif
  -h, -help     Print help on stdout and exit
EOF
    exit ;;
  -fps=*)     FPS=${1:5}; shift ;;
  -size=*)    MAXSIZE=${1:6}; shift ;;
  -colors=*)  MAXCOLORS=${1:8}; shift ;;
  -output=*)  OUTFILE=${1:8}; shift ;;
  -d|-dither) DITHER=true; shift ;;
  -o)         [ -z "$2" ] && _err "missing value for $1"; OUTFILE=$2; shift; shift ;;
  -*)         _err "unknown option $1" ;;
  *)          [ -n "$INFILE" ] && _err "unexpected argument $1"; INFILE=$1; shift ;;
esac; done

[ -z "$INFILE" ] && _err "missing input file"
OUTFILE=${OUTFILE:-$INFILE.gif}
rm -rf "$OUTFILE"

FFMPEG_VF="fps=$FPS"
#FFMPEG_VF="${FFMPEG_VF},format=rgb24"
# FFMPEG_VF="${FFMPEG_VF},colorspace=all=bt709:trc=srgb:format=yuv420p"
FFMPEG_VF="${FFMPEG_VF},scale=$MAXSIZE:-1:flags=lanczos"
FFMPEG_VF="${FFMPEG_VF},pp=al" # fix whites, see ffmpeg.org/ffmpeg-filters.html#pp
FFMPEG_VF="${FFMPEG_VF},split[s0][s1];[s0]palettegen=stats_mode=diff:max_colors=$MAXCOLORS[p]"

if $DITHER; then
  FFMPEG_VF="${FFMPEG_VF};[s1][p]paletteuse=dither=bayer"
else
  FFMPEG_VF="${FFMPEG_VF};[s1][p]paletteuse"
fi

ffmpeg \
  -i "$INFILE" \
  -vf "$FFMPEG_VF" \
  -loop 0 \
  "$OUTFILE"

/bin/ls -lhF "$OUTFILE" | awk '{print $5}'

# ffmpeg -i "$INFILE" -vf "fps=20,scale=800:-1:flags=lanczos" -c:v pam -f image2pipe - \
# | convert - -loop 0 -layers optimize "$OUTFILE"

# ffmpeg \
#   -i "$INFILE" \
#   -vf "fps=20,scale=800:-1:flags=lanczos,split[s0][s1];[s0]palettegen[p];[s1][p]paletteuse" \
#   -loop 0 \
#   "$OUTFILE"
