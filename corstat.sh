#! /bin/sh -e

src_dir="$HOME"/.cache
src_file="$src_dir"/corona_tracker.cache
src_url="https://corona-stats.online/PH?minimal=true"

mkdir -p "$src_dir"
touch "$src_file"

show_coronastatus() {
    if [ -n "$1" ]; then
        case "$1" in
            -f|--fmt|--format)  if [ -n "$2" ]; then
                                    show_fmt="$2"
                                else
                                    cat << EOF
$0: No format string given

Try '$0 help' for more information.
EOF
                                    exit 1
                                fi
                                ;;
            *)                  cat << EOF
$0: unrecognized option '$1'

Try '$0 help' for more information.
EOF
                                exit 1
                                ;;
        esac
    fi
    
    updt_coronastatus
    printf "${show_fmt:-%s\n}" "$(cat $src_file)"
}

mntr_coronastatus() {
    true
}

updt_coronastatus() {
    if [ -n "$1" ]; then
        case "$1" in
            -a|--all)   for pid in $(pgrep $(basename $0)); do
                            [ "$pid" != "$$" ] && kill -USR1 "$pid"
                        done
                        ;;
            *)          cat << EOF
$0: unrecognized option '$1'

Try '$0 help' for more information.
EOF
                        exit 1
        esac
    fi

    if curl "$src_url" -so "$src_file"; then
        sed -i \
            's/\x1B[@A-Z\\\]^_]\|\x1B\[[0-9:;<=>?]*[-!"#$%&'"'"'()*+,.\/]*[][\\@A-Z^_`a-z{|}~]//g' \
            "$src_file"
        fmtout="$(awk '/PH/ {print $4}' "$src_file")"
        echo "$fmtout" > "$src_file"
    else
        printf "$0: updating Corona Virus status failed\n"
        exit 1
    fi
}

help_coronastatus() {
    cat << EOF
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
}

main() {
    case "$1" in
        s|show)     shift; show_coronastatus "$@"
                    ;;
        m|monitor)  shift; mntr_coronastatus "$@"
                    ;;
        u|update)   shift; updt_coronastatus "$@"
                    ;;
        h|help)     help_coronastatus
                    ;;
        *)          if [ -n "$1" ]; then
                        cat << EOF
$0: unrecognized command '$1'

Try '$0 help' for more information.
EOF
                        exit 1
                    else
                        cat << EOF
$0: no command given

Try '$0 help' for more information.
EOF
                        exit 1
                    fi
                    ;;
    esac
}

main "$@"
