# Other Video Transcoding

Other tools to transcode videos.

## About

Hi, I'm [Don Melton](http://donmelton.com/). I created these tools to transcode my collection of Blu-ray Discs and DVDs into a smaller, more portable format while remaining high enough quality to be mistaken for the originals.

Unlike my older [Video Transcoding](https://github.com/donmelton/video_transcoding) project, the `other-transcode` tool in this package automatically selects a platform-specific hardware video encoder rather than relying on a slower software encoder.

Using an encoder built into a CPU or video card means that even Blu-ray Disc-sized media can be transcoded 5 to 10 times faster than its original playback speed, depending on which hardware is available.

But even at those speeds, quality is never compromised because the `other-transcode` tool also selects the best ratecontrol system available within those encoders and properly configures that system. This is what sets it apart from other tools using hardware encoders.

Because the `other-transcode` tool leverages [FFmpeg](http://ffmpeg.org/), many hardware platforms are supported including:

* [Nvidia NVENC](https://en.wikipedia.org/wiki/Nvidia_NVENC)
* [Intel Quick Sync Video](https://en.wikipedia.org/wiki/Intel_Quick_Sync_Video)
* [AMD Video Coding Engine](https://en.wikipedia.org/wiki/Video_Coding_Engine)
* [Apple VideoToolbox](https://developer.apple.com/documentation/videotoolbox)

And many features are supported including:

* High quality 10-bit [HEVC](https://en.wikipedia.org/wiki/High_Efficiency_Video_Coding) encoding on recent generations of Nvidia and Intel hardware
* 8-bit HEVC encoding on other hardware platforms
* Hardware-based video decoding for improved performance
* Fallback to software video encoding when appropriate hardware is not available
* Optional automatic and reliable video cropping
* Adding audio and subtitle tracks by language or title
* [Dolby Digital Plus](https://en.wikipedia.org/wiki/Dolby_Digital_Plus) (Enhanced AC-3) audio encoding
* Burning image-based subtitles into video output to ease player compatibility

Also included in this package is `ask-ffmpeg-log` which reports temporal information from FFmpeg-generated `.log` files containing encoding statistics.

Additional documentation for this project is available in the [wiki](https://github.com/donmelton/other_video_transcoding/wiki).

## Installation

_Avoid installing within [virtual machines](https://en.wikipedia.org/wiki/Virtual_machine) such as the [Windows Subsystem for Linux](https://en.wikipedia.org/wiki/Windows_Subsystem_for_Linux) since access to hardware video encoders may not be allowed, severely impacting performance._

These tools work on Windows, Linux and macOS. They're packaged as a Gem and require Ruby. See "[Installing Ruby](https://www.ruby-lang.org/en/documentation/installation/)" if you don't have it on your platform.

Use this command to install the package: 

    gem install other_video_transcoding

And this command to update it:

    gem update other_video_transcoding

_The commands to install and update may need postfixing with_ `--user-install` _on some platforms._

The `other-transcode` tool in this package requires other software to function properly, specifically these command line programs:

* `ffprobe`
* `ffmpeg`
* `mkvpropedit`

Optional crop previewing also requires the `mpv` command line program.

See "[Download FFmpeg](https://ffmpeg.org/download.html)," "[MKVToolNix Downloads](https://mkvtoolnix.download/downloads.html)" and "[mpv Installation](https://mpv.io/installation/)" to find versions for your platform.

Additional documentation for installing these programs on Windows is available in the [wiki](https://github.com/donmelton/other_video_transcoding/wiki/Windows).

[Docker](https://en.wikipedia.org/wiki/Docker_(software)) containers for Linux, including installation instructions, are available here:

https://github.com/ttyS0/docker-other-transcode

On macOS, all of these programs can be easily installed via [Homebrew](http://brew.sh/), an optional package manager:

    brew install ffmpeg
    brew install mkvtoolnix
    brew install mpv

The `ffprobe` program is included within the `ffmpeg` package and the `mkvpropedit` program is included within the `mkvtoolnix` package.

## Usage

Each tool in this package has several command line options. The `other-transcode` tool is the most complex with over 50 of its own. Use `--help` to list the options available for a specific tool, along with brief instructions on their usage:

    other-transcode --help

More options for the `other-transcode` tool are available with:

    other-transcode --help more

And the full set of options is available with:

    other-transcode --help full

The `other-transcode` tool automatically determines target video bitrate, main audio track configuration, etc. without any command line options, so using it can be as simple as this on Windows:

    other-transcode C:\Rips\Movie.mkv

Or this on Linux and macOS:

    other-transcode /Rips/Movie.mkv

On completion that command creates two files in the current working directory:

    Movie.mkv
    Movie.mkv.log

The `.log` file can be used as input to the `ask-ffmpeg-log` tool.

Use the `--hevc` option to create HEVC video:

    other-transcode --hevc C:\Rips\Movie.mkv

High quality 10-bit HEVC is automatically selected when using the Nvidia and Intel encoders.

Use the `--eac3` option to create Dolby Digital Plus audio:

    other-transcode --eac3 C:\Rips\Movie.mkv

## Feedback

Please report bugs or ask questions by [creating a new issue](https://github.com/donmelton/other_video_transcoding/issues) on GitHub. I always try to respond quickly but sometimes it may take as long as 24 hours.

## Acknowledgements

This project would not be possible without my collaborators on the [Video Transcoding Slack](https://videotranscoding.slack.com/) who spend countless hours reviewing, testing, documenting and supporting this software.

## License

Other Video Transcoding is copyright [Don Melton](http://donmelton.com/) and available under a [MIT license](https://github.com/donmelton/other_video_transcoding/blob/master/LICENSE).
