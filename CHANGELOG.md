# Changes to the "[Other Video Transcoding](https://github.com/lisamelton/other_video_transcoding)" project

### [2025.01.21](https://github.com/lisamelton/other_video_transcoding/releases/tag/2025.01.21)

Tuesday, January 21, 2025

* Update all copyright notices to the year 2025.
* Simplify the description of the `other-transcode.rb` tool.
* Add a note to the "README" document regarding the project's current status.
* Begin using an updated date-based version numbering scheme.

Friday, July 5, 2024

* Deprecate and replace the [RubyGems](https://en.wikipedia.org/wiki/RubyGems)-based `other-transcode` tool with a new standalone `other-transcode.rb` script.
* Modify the "README" document to include installation instructions for the new script.
* Deprecate and remove the `ask-ffmpeg-log` tool.
* Remove the `other_video_transcoding.gemspec` file since it's no longer needed.
* Begin using a date-based version numbering scheme for `other-transcode.rb`.
* Modify `other-transcode.rb` to only create a `.log` file when the `--debug` option is used.

## Archives

> [!NOTE]
> Below are all of the notes created for each [release](https://github.com/lisamelton/other_video_transcoding/releases) of this project when it used the original version numbering scheme.

### [0.12.0](https://github.com/lisamelton/other_video_transcoding/releases/tag/0.12.0)

Wednesday, October 12, 2022

* Modify `other-transcode` to explicitly set the output layout for AC-3 and Dolby Digital Plus (Enhanced AC-3) surround audio formats to six channels when the input has more than six channels, typically with 7.1 surround audio. Otherwise new versions of `ffmpeg` will only create five channels and drop the LFE channel. Via [ #167](https://github.com/lisamelton/other_video_transcoding/issues/167).

### [0.11.0](https://github.com/lisamelton/other_video_transcoding/releases/tag/0.11.0)

Saturday, July 16, 2022

* Modify `other-transcode` to copy 10-bit high-dynamic-range (HDR10) metadata, extracting content light level and mastering display metadata from a HDR10 video frame input and tagging a 10-bit video stream output in Matroska (MKV) format with that information. This will also copy static HDR10 metadata from Dolby Vision and HDR10+ video streams but it will _not_ copy additional dynamic metadata from those formats.
* Add a `--overlay-params` option to `other-transcode` to override the `overlay` filter configuration applied when burning subtitles. This is useful when cropping to move a subtitle within the output boundary.
* Add a `--fdk-vbr` option to `other-transcode` to set the numeric variable bitrate (VBR) mode for the Fraunhofer `libfdk_aac` audio encoder, disabling constant bitrate (CBR) ratecontrol. VBR mode `1` selects the lowest quality and `5` the highest. Please note that the `libfdk_aac` encoder is not normally included with `ffmpeg` due to licensing restrictions and the `--fdk-vbr` option has no effect if that encoder is not available. Via [ #127](https://github.com/lisamelton/other_video_transcoding/issues/127).

### [0.10.0](https://github.com/lisamelton/other_video_transcoding/releases/tag/0.10.0)

Thursday, January 27, 2022

* Add a `--nvenc-gpu-only` option to `other-transcode` to keep data on the GPU for greater speed, if possible. Deinterlacing is allowed but cropping, scaling, detelecining, setting frame rates and burning subtitles will prevent this from working and may actually slow things down. Performance can also be affected negatively depending on PC configuration. Please note that the `--nvenc-gpu-only` option requires `ffmpeg` version 5.0 or later.
* Add a `--x264-cbr` option to `other-transcode` to simplify access to constant bitrate (CBR) ratecontrol. Despite the name, actual output bitrates from the `x264` encoder are variable and below what might be expected. So, default video bitrate targets are raised to accommodate this.
* Enable proper crop detection in `other-transcode` for 4K UHD Blu-ray rips and other media with a 10-bit color depth. This was done by changing the `limit` value passed to the `cropdetect` filter from an integer constant to a floating point equation. Via [ #52](https://github.com/lisamelton/other_video_transcoding/issues/52).
* Modify `other-transcode` to add a workaround for the mapping of BT.470 M and BT.470 BG color transfer characteristics from values returned from `ffprobe` to values actually used by `ffmpeg`. Via [ #112](https://github.com/lisamelton/other_video_transcoding/issues/112).
* Modify `other-transcode` to allow parentheses within the argument to the `--yadif-params`, `--x264-params` and `--x265-params` options. Via [ #119](https://github.com/lisamelton/other_video_transcoding/issues/119).
* Modify `ask-ffmpeg-log` to fix detection of frame counts less than five digits within `.log` files from very short duration videos. Via [ #126](https://github.com/lisamelton/other_video_transcoding/issues/126).
* Modify `ask-ffmpeg-log` to fix detection of statistics within `.log` files not generated by `other-transcode`.
* Remove the deprecated `--nvenc-rc-mode` and `--aac-stereo` options from `other-transcode`.
* Update all copyright notices to the year 2022.

### [0.9.0](https://github.com/lisamelton/other_video_transcoding/releases/tag/0.9.0)

Saturday, June 5, 2021

Nvidia encoders:

* Add a `--nvenc-recommended` option to `other-transcode` which easily and optimally configures the Nvidia H.264 and HEVC video encoders, equivalent to using:
    * `--nvenc-spatial-aq --nvenc-lookahead 32 --nvenc-bframe-refs middle`
* The `--nvenc-bframe-refs` option is also new and using `middle` as its argument increases compression efficiency. However, it's not supported on all Nvidia hardware. Which means, neither is the `--nvenc-recommended` option.
* So, using `--nvenc-recommended` for H.264 encoding requires at minimum a fourth generation Pascal-based GPU like the GTX 1080. And using it for HEVC encoding requires at minimum a more recent sixth generation Turing-based model like the GTX 1660 or RTX 2070.
* Add a `--nvenc-cq` option to `other-transcode` to allow constant quality (CQ) ratecontrol. This option ignores the target video bitrate and takes a single numerical argument between `1` and `51` with lower values indicating higher quality. However, only values between `25` and `30` are really practical for 1080p content. It's recommended to start with `--nvenc-cq 28` and adjust as needed. Fractional values are also supported.
* While CQ ratecontrol can adapt better to extremely dynamic content compared to the default average bitrate (ABR) ratecontrol system, the output bitrates produced by CQ can vary significantly and it can be slightly more prone to color banding with the H.264 encoder. So, for now, consider the `--nvenc-cq` option an experimental feature.
* Deprecate the `--nvenc-rc-mode` option in `other-transcode` because maximum rate and buffer size values are already specified so an explicit ratecontrol mode is not required.

Audio:

* Modify `other-transcode` to no longer explicitly set audio bitrates and instead rely on the defaults from the audio encoders included with `ffmpeg`. This is being done to both simplify the code in `other-transcode` and to leverage the judgement of the audio encoder developers, which means:
    * AC-3 surround audio is lowered from 640 Kbps to 448 Kbps.
    * Dolby Digital Plus (Enhanced AC-3) surround audio is raised from 384 Kbps to 448 Kbps.
    * AAC stereo audio is lowered from 256 Kbps to 128 Kbps when using the native `ffmpeg` or Apple AudioToolbox encoders.
* If desired, use the `--surround-bitrate` and `--stereo-bitrate` options to restore the previous default audio bitrates.
* Add a `--aac-only` option to `other-transcode` to force transcoding of all audio into AAC format, copying only tracks which are already in that format. Surround tracks are converted to a 5.1-channel AAC format at 341 Kbps when using the native `ffmpeg` encoder. This channel layout is compatible with most playback devices. Allowing more than 5.1 channels would significantly reduce playback compatibility.
* Deprecate the `--aac-stereo` option in `other-transcode` and replace with a new `--eac3-aac` option, which uses Dolby Digital Plus format only for surround audio with AAC format for stereo audio. Since the `--aac-stereo` option only made sense when used in combination with the `--eac3` option, this makes `--eac3-aac` more convenient.

Other changes:

* Change the default ratecontrol maximum rate and buffer size values in `other-transcode`, as well as how those values increased when the target video bitrate is increased. The default values now also differ depending on whether the output video is in H.264 or HEVC format.
* Modify the `--rc-maxrate` and `--rc-bufsize` options in `other-transcode` to allow specific bitrates as arguments and not just multiples of the video bitrate target. These options are most useful for lowering maximum rate and buffer size values. To raise those values, increase the target video bitrate instead.
* Change the pixel format and force a Main 10 video profile in `other-transcode` when using the Apple VideoToolbox encoder to create output with a 10-bit color depth. Correct generation of 10-bit output requires macOS Big Sur or later.
* Modify `other-transcode` to copy the three basic color properties (primaries, transer and space) from the input to the output when those properties are availabe. Otherwise use some sensible defaults.
* Modify `other-transcode` to force a H.264 level when using `--x264` with slower presets. This ensures that the `x264` encoder continues to generate a video stream compatible with most playback devices when those presets are used.
* Modify `other-transcode` to remove the hack which avoids using the Matroksa muxer `-disposition` option in old versions of `ffmpeg`. This means version 4.3 or later of `ffmpeg` is now required to run `other-transcode`.

### [0.8.0](https://github.com/lisamelton/other_video_transcoding/releases/tag/0.8.0)

Saturday, February 13, 2021

* Modify `other-transcode` to:
    * No longer automatically deinterlace video with a frame rate of 29.97 FPS.
    * No longer change the frame rate of any video in MPEG-2 format which was automatically deinterlaced.
    * Only automatically deinterlace non-progressive video.
    * Apply any automatic or explicit deinterlacing to all frames of the video, not just the interlaced frames.
    * Force a constant frame rate for any video in MPEG-2 format at 29.97 FPS.
* Add a `--yadif-params` option to `other-transcode` to allow customization of the `yadif` filter used for deinterlacing.
* Remove the deprecated `--all-eac3` option of `other-transcode`.

### [0.7.0](https://github.com/lisamelton/other_video_transcoding/releases/tag/0.7.0)

Monday, January 4, 2021

* Modify `other-transcode` to lower default target bitrates in order to significantly reduce the size of transcoded output at the risk of a slight reduction in perceived quality. Via [ #89](https://github.com/lisamelton/other_video_transcoding/issues/89).

H.264 video:

Resolution | old | new
--- | --- | ---
1080p (Blu-ray video) | 8000 Kbps | 6000 Kbps
720p | 4000 Kbps | 3000 Kbps
480p (DVD video) | 2000 Kbps | 1500 Kbps

HEVC video:

Resolution | old | new
--- | --- | ---
1080p (Blu-ray video) | 6000 Kbps | 4000 Kbps
720p | 3000 Kbps | 2000 Kbps
480p (DVD video) | 1500 Kbps | 1000 Kbps

Dolby Digital Plus (Enhanced AC-3) audio:

Channels | old | new
--- | --- | ---
Surround | 640 Kbps | 384 Kbps
Stereo | 256 Kbps | 192 Kbps
Mono | 128 Kbps | 96 Kbps

Note: There are no changes to default target bitrates for Dolby Digital (AC-3) and AAC audio formats.

* Change the `--eac3` option in `other-transcode` to use Dolby Digital Plus format for _all_ transcoded audio instead of just surround output.
* Deprecate the `--all-eac3` option in `other-transcode` since the `--eac3` option now has the same behavior.
* Add a `--aac-stereo` option to `other-transcode`. This uses AAC format for transcoded stereo audio output so it can be paired with `--eac3` to get that option's old behavior.
* Add a `--8-bit-vc1` option. When the color depth is currently 10-bit, this option uses an 8-bit color depth _for video inputs in VC-1 format only_.

### [0.6.0](https://github.com/lisamelton/other_video_transcoding/releases/tag/0.6.0)

Tuesday, December 22, 2020

* Lower the default target bitrates for 8-bit HEVC video in `other-transcode` to match the defaults for 10-bit HEVC video. This means, for example, the default target for HEVC at a 1080p resolution will be 6000 Kbps no matter the output bit depth.
* Modify `other-transcode` to set the video buffer size equal to the maximum video bitrate when using an Nvidia encoder, essentially adding `--rc-bufsize 3` to the command line. Previously the buffer size was never explicitly set so `ffmpeg` would use a default value of twice the target bitrate. Since the maximum bitrate is normally three times the target bitrate this meant the buffer size was actually smaller than the maximum. While this didn't cause any known problems, Nvidia recommends a larger buffer size to improve quality. However, using `--rc-bufsize 0` will restore the old behavior and the default value from `ffmpeg`.
* Ignore the `--nvenc-lookahead` option in `other-transcode` when the argument is `0` since such a value won't change the behavior of an Nvidia encoder anyway.
* Add a `--limit-ac3-surround` option to `other-transcode` which prevents surround audio in AC-3 or Dolby Digital Plus (Enhanced AC-3) format from being copied instead of transcoded when the orginal bitrate is above the transcoding bitrate. This allows setting a lower target with the `--surround-bitrate` option in order to force higher-bitrate tracks to be transcoded instead of copied.
* Reduce the minimum bitrates for Dolby Digital Plus audio in `other-transcode` from 256, 128 and 64 Kbps for surround, stereo and mono layouts to 192, 96 and 48 Kbps. The default bitrates for Dolby Digital Plus audio remain the same and this change does not affect audio output in AC-3 or AAC formats.

### [0.5.0](https://github.com/lisamelton/other_video_transcoding/releases/tag/0.5.0)

Tuesday, November 24, 2020

* Add `--qsv-decoder` and `--qsv-device` options to `other-transcode`, both of which enable the scoped use of the Intel Quick Sync Video (QSV) decoder instead of the generic hardware decoder. These options can significantly speed operation of the QSV encoder, invoked via `--qsv`. It's recommended that `--decode all` be included when using these options to decode all video input formats. The `--qsv-device` option allows selection of specific hardware by number or path depending on platform. Please note that deinterlacing, cropping, scaling or using other filters will disable QSV's format-specific decoders.
* Remove all deprecated options and arguments from `other-transcode`.

### [0.4.0](https://github.com/lisamelton/other_video_transcoding/releases/tag/0.4.0)

Sunday, November 1, 2020

* Modify the behavior and augment the capabilities of both encoding and decoding when using Nvidia hardware with `other-transcode`. This is necessary for compatibility with unleased versions of `ffmpeg` which are now built using the new Nvidia Software Development Kit (SDK) version 11.0. This SDK changes default encoder behavior and adds new presets which allow finer control of the performance/quality trade-off when transcoding video. To allow maximum performance, `other-transcode` no longer enables some quality settings by default:
    * Multipass mode, now accessible via a new `--nvenc-multipass` option. Be advised that any improved quality from enabling multipass mode is probably not worth the performance impact.
    * Spatial and temporal adaptive quantization (AQ), accessible via the `--nvenc-spatial-aq` and `--nvenc-temporal-aq` options. While enabling spatial AQ is still useful in reducing color banding for some inputs, be advised that enabling temporal AQ is probably not necessary and can cause some other side effects.
* Add support for seven new Nvidia encoder presets to `other-transcode`. Use `--preset p1` for best performance and `--preset p7` for best quality. It's not necessary to use `--preset p4` since that's the default. See the [Nvidia preset migration guide](https://docs.nvidia.com/video-technologies/video-codec-sdk/nvenc-preset-migration-guide/index.html) to understand how these presets work and how they map to older behavior.
* Add a `--nvenc-rc-mode` option to `other-transcode` for backward comaptibility with `ffmpeg` version 4.3.1 and older.
* Add `--cuda` and `--no-cuda` options to `other-transcode`. These options enable or disable the scoped use of the Nvidia CUDA hardware decoder instead of the generic hardware decoder. By default the CUDA _decoder_ is enabled when using the Nvidia video _encoder_, but disabled when using other encoders.
* Deprecate the `--cuvid` option in `other-transcode` because the CUDA decoder is faster and more flexible.
* Deprecate `--preset none` in `other-transcode` because it's no longer necessary.
* Always use hyphen-based spellings of Nvidia AQ options in `ffmpeg` commands generated by `other-transcode`.
* Add `--x264-params` and `--x265-params` options to `other-transcode` for _very_ advanced manipulation of the `x264` and `x265` software encoders.
* Modify `other-transcode` to assume a video input without a `field_order` tag is progressive instead of interlaced so a deinterlace fliter is not automatically and incorrectly applied to that video. This avoids problems with some 4K Ultra HD Blu-ray rips.
* Update the link to Docker containers for Linux in the "README" document. Thanks, @ttyS0!

### [0.3.2](https://github.com/lisamelton/other_video_transcoding/releases/tag/0.3.2)

Friday, September 11, 2020

* Modify `other-transcode` to use a new `ffmpeg` Matroksa muxer option so the `-disposition` option is once again honored when using `ffmpeg` version 4.3 and later.
* Change the codec ID from the default of `hev1` to `hvc1` for HEVC video in MP4 output from `other-transcode` to enable playback in QuickTime on macOS. Via [ #50](https://github.com/lisamelton/other_video_transcoding/issues/50).
* Convert added SRT format subtitles to MOV-compatible format in MP4 output from `other-transcode`. Via [ #55](https://github.com/lisamelton/other_video_transcoding/issues/55).

### [0.3.1](https://github.com/lisamelton/other_video_transcoding/releases/tag/0.3.1)

Tuesday, May 26, 2020

* Modify the `--preview-crop` option in `other-transcode` to show commands compatible with newer versions of `mpv`.
* No longer force a NTSC film frame rate for interlaced inputs in PAL MPEG-2 format.
* When using the `--dry-run` option in `other-transcode`, issue a warning instead of failing if the output or log files already exist.
* Add a link to another Docker container for Linux in the "README" document. Thanks, @ttyS0!

### [0.3.0](https://github.com/lisamelton/other_video_transcoding/releases/tag/0.3.0)

Thursday, February 27, 2020

* Add a `--scan` option to `other-transcode`. This prints media information and then exits, allowing easy identification of track numbers and formats. Via [ #11](https://github.com/lisamelton/other_video_transcoding/issues/11).
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

### [0.2.0](https://github.com/lisamelton/other_video_transcoding/releases/tag/0.2.0)

Monday, January 13, 2020

* Allow `all` to be used as an argument to the `--add-audio` and `--add-subtitle` options of `other-transcode`, adding all audio tracks or all subtitle tracks. Via [ #3](https://github.com/lisamelton/other_video_transcoding/issues/3).
* Add `original` as a width attribute to the `--main-audio` and `--add-audio` options of `other-transcode`. Unlike `stereo` and `surround`, this disables transcoding and always copies the selected track(s). Via [ #5](https://github.com/lisamelton/other_video_transcoding/issues/5).
* Add a `--copy-video` option to `other-transcode`. This disables transcoding and copies the original video track to the output.
* No longer ignore any image-based subtitles added to MP4 output. Instead, let `ffmpeg` foolishly add DVD-style subtitles and (currently) fail when adding Blu-ray Disc-style subtitles.
* Deprecate the `--name` option of `other-transcode` because it doesn't make sense to name only the first output file from a tool which can take multiple inputs. The option still works for now, but using it issues a warning message. It will be removed in a future release.
* Remove warnings when other options disable the Nvidia video decoder, which could only happen if the `--burn-subtitle` or `--detelecine` options were used with the `--cuvid` option.

### [0.1.1](https://github.com/lisamelton/other_video_transcoding/releases/tag/0.1.1)

Friday, January 3, 2020

* Prevent passing full or partial paths to the `--name` option of `other-transcode`.
* Hide the path prefix when naming the program in `--help` output and in usage errors for both `other-transcode` and `ask-ffmpeg-log`.
* In the "README" document:
    * Add warnings to avoid installing within virtual machines and about the possible need to use `sudo`.
    * Add a link to additional documentation on the wiki for installing `ffprobe`, `ffmpeg`, `mkvpropedit` and `mpv` on Windows.
    * Also explain how to install those same programs on macOS using Homebrew.
* Update all copyright notices to the year 2020.

### [0.1.0](https://github.com/lisamelton/other_video_transcoding/releases/tag/0.1.0)

Thursday, December 26, 2019

* Initial project version.
