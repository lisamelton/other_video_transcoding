# Changes to the "[Other Video Transcoding](https://github.com/donmelton/other_video_transcoding)" project

This single document contains all of the notes created for each [release](https://github.com/donmelton/other_video_transcoding/releases).

## [0.3.2](https://github.com/donmelton/other_video_transcoding/releases/tag/0.3.2)

Friday, September 11, 2020

* Modify `other-transcode` to use a new `ffmpeg` Matroksa muxer option so the `-disposition` option is once again honored when using `ffmpeg` version 4.3 and later.
* Change the codec ID from the default of `hev1` to `hvc1` for HEVC video in MP4 output from `other-transcode` to enable playback in QuickTime on macOS. Via [ #50](https://github.com/donmelton/other_video_transcoding/issues/50).
* Convert added SRT format subtitles to MOV-compatible format in MP4 output from `other-transcode`. Via [ #55](https://github.com/donmelton/other_video_transcoding/issues/55).

## [0.3.1](https://github.com/donmelton/other_video_transcoding/releases/tag/0.3.1)

Tuesday, May 26, 2020

* Modify the `--preview-crop` option in `other-transcode` to show commands compatible with newer versions of `mpv`.
* No longer force a NTSC film frame rate for interlaced inputs in PAL MPEG-2 format.
* When using the `--dry-run` option in `other-transcode`, issue a warning instead of failing if the output or log files already exist.
* Add a link to another Docker container for Linux in the "README" document. Thanks, @ttyS0!

## [0.3.0](https://github.com/donmelton/other_video_transcoding/releases/tag/0.3.0)

Thursday, February 27, 2020

* Add a `--scan` option to `other-transcode`. This prints media information and then exits, allowing easy identification of track numbers and formats. Via [ #11](https://github.com/donmelton/other_video_transcoding/issues/11).
* Add a `--mono-bitrate` option to `other-transcode`. This sets the mono audio bitrate, which is otherwise 50% of the stereo bitrate.
* Raise the maximum bitrates for audio in AAC format to 320 Kbps for stereo and 256 Kbps for mono. The default birates remain the same.
* Add a `--all-eac3` option to `other-transcode`. This uses the Dolby Digital Plus (Enhanced AC-3) format for all transcoded audio. The behavior of the `--eac3` option, which uses Dolby Digital Plus for surround audio only, remains the same.
* Add a `--keep-ac3-stereo` option to `other-transcode`. This copies stereo and mono audio in AC-3 format even when the original source bitrate is above the output transcoding bitrate.
* Add a `--pass-dts` option to `other-transcode`. This enables passthrough of audio in DTS and DTS-ES formats. However, such audio also in surround format will still be transcoded if that audio is output to a stereo-width track.
* Add `--rc-maxrate` and `--rc-bufsize` options to `other-transcode`. These set the ratecontrol maximum rate and/or the buffer size as a multiple of the video bitrate target, but only for certain encoders and ratecontrol systems.
* Add a `--x264-mbtree` option to `other-transcode`. This uses macroblock-tree ratecontrol and disables AVBR if in use.
* In order to ensure compatible H.264 levels, limit the number of reference frames when using the `x264` encoder with slower presets.
* Remove the deprecated `--name` option of `other-transcode`.
* Add a link to a Docker container for Linux in the "README" document. Thanks, @ttyS0!

## [0.2.0](https://github.com/donmelton/other_video_transcoding/releases/tag/0.2.0)

Monday, January 13, 2020

* Allow `all` to be used as an argument to the `--add-audio` and `--add-subtitle` options of `other-transcode`, adding all audio tracks or all subtitle tracks. Via [ #3](https://github.com/donmelton/other_video_transcoding/issues/3).
* Add `original` as a width attribute to the `--main-audio` and `--add-audio` options of `other-transcode`. Unlike `stereo` and `surround`, this disables transcoding and always copies the selected track(s). Via [ #5](https://github.com/donmelton/other_video_transcoding/issues/5).
* Add a `--copy-video` option to `other-transcode`. This disables transcoding and copies the original video track to the output.
* No longer ignore any image-based subtitles added to MP4 output. Instead, let `ffmpeg` foolishly add DVD-style subtitles and (currently) fail when adding Blu-ray Disc-style subtitles.
* Deprecate the `--name` option of `other-transcode` because it doesn't make sense to name only the first output file from a tool which can take multiple inputs. The option still works for now, but using it issues a warning message. It will be removed in a future release.
* Remove warnings when other options disable the Nvidia video decoder, which could only happen if the `--burn-subtitle` or `--detelecine` options were used with the `--cuvid` option.

## [0.1.1](https://github.com/donmelton/other_video_transcoding/releases/tag/0.1.1)

Friday, January 3, 2020

* Prevent passing full or partial paths to the `--name` option of `other-transcode`.
* Hide the path prefix when naming the program in `--help` output and in usage errors for both `other-transcode` and `ask-ffmpeg-log`.
* In the "README" document:
    * Add warnings to avoid installing within virtual machines and about the possible need to use `sudo`.
    * Add a link to additional documentation on the wiki for installing `ffprobe`, `ffmpeg`, `mkvpropedit` and `mpv` on Windows.
    * Also explain how to install those same programs on macOS using Homebrew.
* Update all copyright notices to the year 2020.

## [0.1.0](https://github.com/donmelton/other_video_transcoding/releases/tag/0.1.0)

Thursday, December 26, 2019

* Initial project version.
