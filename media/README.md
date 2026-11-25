# Media Server Documentation
{TOC}

Install the required packages (using `dnf`,`apt` or the package manage for your system)
```bash
# List of packages needed by the Linux system
PACKAGES=(
    libdvdcss
    makemkv
    mediainfo
    lsdvd
    ffmpeg
    dvdbackup
    HandBrake
    vlc
);

# RHEL|Fedora
sudo dnf install -y https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

sudo dnf install -y rpmfusion-free-release-tainted;

sudo dnf install -y $PACKAGES

# Debian|Ubuntu
sudo apt update -y && sudo apt install -y $PACKAGES;
```
## Ripping Media for Plex
> [!WARNING]
>
> **Disclaimer**
>
>This software is intended to assist users in organizing and managing media for personal use. Only use media that you own and are legally permitted to copy, back up, or stream.
>
>Do not use this software to obtain, distribute, share, or reproduce copyrighted works without authorization from the copyright holder. The author assumes no responsibility for misuse of this software or for any copyright infringement committed by its users.

> [!TIP]
> Should you need to check a video file's resolution or encoding, you can use the `linux-stuff_get_video_info()` function in the `media_functions.sh` file. Simply pass the path of the video file to the function and it will return the approximate resolution and codec in JSON format
> ```bash
> linux-stuff_get_video_info get_video_info /mnt/prb-fs-1/Media/movies/Jurassic\ Park\ \(1993\)\ {imdb-tt0107290}/Jurassic\ Park\ \(1993\)*.mp4"
>
> { "codec": "h264", "width": 720, "height": 460 }
> ```

### Movies
Each movie should get a directory created with it's title, year of release, and *IMDB ID* in the name. This helps Plex keep the library organized and aids the media agent with content matching. The Plex documentation goes further in-depth on [the folder structure of the movie library](https://support.plex.tv/articles/naming-and-organizing-your-movie-media-files/) and [how to handle multiple versions / resolutions of the same movie](https://support.plex.tv/articles/200381043-multi-version-movies/).

1. Using the critically acclaimed film [*Big Buck Bunny (2008)*](https://www.imdb.com/title/tt1254207/) as an example, a directory in the Plex media library should be created as follows to contain the ripped video file
    ```bash
    # Template: <Movie Title>\ \(<Release Year>)\ {<IMDB-ID>}
    mkdir Big\ Buck\ Bunny\ \(2008\)\ {imdb-tt1254207};

    # Or, if you don't want to deal with escape characters
    mkdir "Big Buck Bunny (2008) {imdb-tt1254207}
    ```
    The *IMDB ID* can be obtained from the IMDB URL for the film: [https://www.imdb.com/title/tt1254207/](https://www.imdb.com/title/tt1254207/)

1. Now that the movie's directory has been created, we're ready to rip the movie from the disc to the directory that was just created. The movie file should include the title, year of release, resolution and codec in the name. For example:
    ```plaintext
    Big Buck Bunny (2008).1080p.h264.mp4
    ```
    1. **Option 1:** Use `HandBrakeCLI` to rip the disc and encode the file on write
        ```bash
        # Ripping discs to H.265 MP4 files
        HandBrakeCLI -i /dev/sr0 -o ./Big\ \Buck\ Bunny\ \(2008\).1080p.h265.mp4 -e x265 -q 22 --encoder-preset fast --format av_mp4 --subtitle-lang-list eng --audio-lang-list eng --main-feature

        # Ripping Blu Rays to H.265 MKV files
        HandBrakeCLI -i /dev/sr0 -o ./Big\ \Buck\ Bunny\ \(2008\).1080p.h265.mkv -f av_mkv -e x265_10bit -q 22 --encoder-preset fast --all-audio -E copy --audio-fallback ac3 --all-subtitles
        ```
    1. **Option 2:** If the `HandBrakeCLI` binary isn't able to rip the disc / is taking too long you can use `makemkvcon` to rip the disc as a `.MKV` file and then encode once the rip is complete.
        ```bash
        makemkvcon mkv dev:/dev/sr0 all /tmp/output.mp4

        HandBrakeCLI -i /tmp/output.mp4 -o ./Big\ \Buck\ Bunny\ \(2008\).1080p.h265.mp4 -e x265 -q 22 --encoder-preset fast --format av_mp4 --subtitle-lang-list eng --audio-lang-list eng
        ```
1. Some rips (like 4K Blu Rays) can be quite large. If you're not worried about quality loss, you can compress the large video files using `HandBrakeCLI`.
    ```bash
    HandBrakeCLI -i "input.mkv" -o "output.mp4" -f av_mkv -e x265_10bit -q 18 --encoder-preset slow --encoder-profile main10 --all-audio -E copy --audio-fallback ac3 --all-subtitles
    ```

### Television Shows
Telvision shows need to be stored with their season and episode numbers for correct indexing on Plex. Follow the [naming convention in the Plex documentation](https://support.plex.tv/articles/naming-and-organizing-your-tv-show-files/) when creating a media library folder tree.

1. Sometimes you may want to do an initial scan of the disc to see all titles and their durations to ensure you are only ripping the actual episodes instead of bonus features. You can list the titles of the disc after doing an initial scan via:
    ```bash
    # May need to include the '--no-dvdnav' parameter to skip DVD navigation menus from being analyzed

    HandBrakeCLI -i /dev/sr0 --title 0 --scan 2>&1 | grep -E "^\+ title|duration:"
    ```
1. If for some reason you only need to rip an single episode from the disc, you can specify that title index to `HandBrakeCLI` via the `--title`` parameter. However, most often you'll be ripping the entire disc (discussed in the next step).
    ```bash
    HandBrakeCLI -i /dev/sr0 --title 2 -o /tmp/episode2.mp4 -e x265 -q 20 --encoder-preset medium --all-audio --all-subtitles;
    ```
1. **Option 1:** Source the `media_functions.sh` script in your shell and use the `linux-stuff_rip_tv_to_disc()` function to rip the TV episodes and encode them on write using `HandBrakeCLI`. Sometimes this method can fail / be extremely slow and resorting to **Option 2** is recommended.
    ```bash
    # Source the functions file
    source media_functions.sh

    ## Invoke the 'linux-stuff_rip_tv_to_disc()' function ##
    : '
    # Documentation of the arguments consumed by the 'linux-stuff_rip_tv_to_disc()' function
    local show_name="$1"   # e.g., "The Paper"
    local season="$2"      # e.g., 1
    local start_ep="$3"    # e.g., 1
    local min_mins="$4"    # Minimum episode length in minutes (e.g., 20)
    local max_mins="$5"    # Maximum episode length in minutes (e.g., 33)
    local out_dir="$6"     # e.g., "/mnt/prb-fs-1/Media/television/The Paper (2025) {imdb-tt32159809}/Season 01"
    local dvd_dev="$7"     # e.g., "/dev/sr0"
    '

    # For half-hour shows, invoke with:
    linux-stuff_rip_tv_to_disc "Show Name" 1 1 20 26 "/media/tv/Show Name/Season 01" /dev/sr0

    #For onr hour shows, use:
    linux-stuff_rip_tv_to_disc "Show Name" 1 1 40 50 "/media/tv/Show Name/Season 01" /dev/sr0
    ```
1. **Option 2:** If directly reading the disc and encoding the file on write is taking too long, the process needs to be broken down into two steps.
    1. Use `makemkvcon` to rip all the titles from the disc as `.mkv` files
        ```bash
        # Rip all the titles from the disc to MKV files
        makemkvcon mkv disc:0 all <output path>

        # Use the '--minlength' parameter to exclude extra features, etc. The integer represents the minimum title length in minutes
        makemkvcon --minlength=600 mkv disc:0 all /tmp/mkv_rip
        ```
    1. After the titles from the disc have been ripped as `.mkv` files, then use `HandBrakeCLI` to encode them as `.mp4` files as a batch process
        ```bash
        for f in /mkv_rip/*.mkv; do
            base=$(basename "$f" .mkv)
            HandBrakeCLI -i "$f" -o "/tmp/${base}.mp4" -e x265 -q 20 --encoder-preset medium -a 1 -E copy --subtitle scan --subtitle-burned=none
        done
        ```
    1. After the `.mkv` --> `.mp4` conversion is complete, don't forget to go back and delete the `.mkv` files so that you aren't storing duplicate copies of the same content