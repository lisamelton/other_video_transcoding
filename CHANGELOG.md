# Changes to the "[Other Video Transcoding](https://github.com/donmelton/other_video_transcoding)" project

This single document contains all of the notes created for each [release](https://github.com/donmelton/other_video_transcoding/releases).

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
