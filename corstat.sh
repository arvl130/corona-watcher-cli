#! /bin/sh -e

src_dir="$HOME"/.cache
src_file="$src_dir"/corona_tracker.cache

get_coronastatus() {
    printf 'D  %s±i \n' "$(cat $src_file)"
}
upd_coronastatus() {
    printf "Updating COVID19 status..."
    if ping -c 5 1.1.1.1 > /dev/null 2>&1 && curl "https://corona-stats.online/PH?minimal=true" -so "$src_file"; then
        awkout="$(awk '/PH/ {print $6}' "$src_file" )"
        awkout="${awkout#?????}"
        awkout="$(echo "$awkout" | sed 's/\x1B[@A-Z\\\]^_]\|\x1B\[[0-9:;<=>?]*[-!"#$%&'"'"'()*+,.\/]*[][\\@A-Z^_`a-z{|}~]//g')"
        printf '%s\n' "$awkout" > "$src_file"
        printf " done.\n"
    else
        printf " something went wrong. :(\n"
        exit 1
    fi
}

case "$1" in
    -h|--help)      cat << EOF
Usage: $0 [command] [options]

COMMANDS
     [s]how      Update and show the current Corona Virus status.
     [m]onitor   Monitor the current Corona Virus status.
     [u]pdate    Update the Corona Virus status cache.
     [h]elp      Show this help message.

SHOW
    -f, --fmt,   Set the output format for printing. See printf(1).
      --format   Default: "%s\n"

MONITOR
   -e, --every   Update the Corona Virus cache ourselves every N
                 period of time. See sleep(1).
                 Default: "60m"

UPDATE
     -a, --all   Searches for other instances of the program and
                 tells them to update themselves (including itself).
EOF
                ;;
    s|show)     show_coronastatus
                ;;
    m|monitor)  mntr_coronastatus
                ;;
    u|update)   updt_coronastatus
                ;;
    h|help)     help_coronastatus
                ;;
    *)          if [ -n "$1" ]; then
                    cat << EOF
$0: unrecognized command '$1'

Try '$0 help' for more information.
EOF
                else
                    cat << EOF
$0: no command given

Try '$0 help' for more information.
EOF
                fi
                ;;
esac
