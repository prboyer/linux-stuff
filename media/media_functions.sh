linux-stuff_get_video_info(){
    FFPROBE_RESULT=$(ffprobe -v quiet -print_format json -show_streams "$1" | jq '.streams[] | select(.codec_type=="video") | {codec: .codec_name, width: .width, height: .height}')

    if [[ "$FFPROBE_RESULT" = "" ]]; then
        mediainfo --Inform="Video;%Format% %Width%x%Height%" "$1";
    else
    echo $FFPROBE_RESULT;
    fi;
}

linux-stuff_rip_tv_to_disc() {
    local show_name="$1"   # e.g., "The Paper"
    local season="$2"      # e.g., 1
    local start_ep="$3"    # e.g., 1
    local min_mins="$4"    # Minimum episode length in minutes (e.g., 20)
    local max_mins="$5"    # Maximum episode length in minutes (e.g., 33)
    local out_dir="$6"     # e.g., "/mnt/prb-fs-1/Media/television/The Paper (2025) {imdb-tt32159809}/Season 01"
    local dvd_dev="$7"     # e.g., "/dev/sr0"

    mkdir -p "$out_dir"
    echo "Scanning $dvd_dev for titles between ${min_mins} and ${max_mins} minutes..."

    local titles=()
    mapfile -t titles < <(
        HandBrakeCLI -i "$dvd_dev" --title 0 --scan 2>&1 | awk -v min="$min_mins" -v max="$max_mins" '
            /^\+ title [0-9]+:/ {
                gsub(/:/, "", $3)
                t = $3
            }
            /duration:/ {
                split($3, d, ":")
                mins = (d[1] * 60) + d[2] + (d[3] / 60)
                if (mins >= min && mins <= max && $3 != prev_dur) {
                    print t
                    prev_dur = $3
                }
            }
        '
    )

    if [ ${#titles[@]} -eq 0 ]; then
        echo "No titles found matching ${min_mins}-${max_mins} minutes."
        return 1
    fi

    echo "Found matching titles: ${titles[*]}"
    local ep="$start_ep"

    for t in "${titles[@]}"; do
        local s_pad=$(printf "%02d" "$season")
        local e_pad=$(printf "%02d" "$ep")
        local out_file="${out_dir}/${show_name} - s${s_pad}e${e_pad}.mp4"

        echo "Ripping DVD Title $t -> $out_file"
        HandBrakeCLI -i "$dvd_dev" \
            -t "$t" \
            -o "$out_file" \
            -e x265 -q 20 --encoder-preset medium \
            --all-audio --all-subtitles

        ((ep++))
    done
 }
