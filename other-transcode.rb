#!/usr/bin/env ruby
#
# other-transcode.rb
#
# Copyright (c) 2019-2024 Lisa Melton
#

require 'English'
require 'fileutils'
require 'json'
require 'optparse'

module Transcoding

  class UsageError < RuntimeError
  end

  class Command
    def about
      <<-HERE
other-transcode.rb 0.0.02024070501
Copyright (c) 2019-2024 Lisa Melton
      HERE
    end

    def usage1
      <<-HERE
Transcode Blu-ray Disc or DVD rip into a smaller, more portable format
while remaining high enough quality to be mistaken for the original.

Usage: #{File.basename($PROGRAM_NAME)} [OPTION]... [FILE]...

Creates Matroska `.mkv` format file in current working directory.

Automatically selects a platform-specific hardware video encoder.

      HERE
    end

    def usage2
      <<-HERE
Input options:
    --position TIME, --duration TIME
                    start transcoding at position and/or limit to duration
                      in seconds[.milliseconds] or [HH:]MM:SS[.m...] format

      HERE
    end

    def usage3
      <<-HERE
Output options:
    --debug         increase diagnostic information
    --scan          print media information and exit
    --preview-crop  show commands to preview detected video crop and exit
      HERE
    end

    def usage4
      <<-HERE
    --print-crop    print only detected video crop geometry and exit
    --mp4           output MP4 instead of Matroska `.mkv` format
    --copy-track-names
                    copy all input audio track names to output
      HERE
    end

    def usage5
      <<-HERE
    --max-muxing-queue-size SIZE
                    set maximum number of packets to buffer when muxing
      HERE
    end

    def usage6
      <<-HERE
-n, --dry-run       don't transcode, just show `ffmpeg` command and exit

Video options:
    --hevc          use HEVC version of platform-specific video encoder
      HERE
    end

    def usage7
      <<-HERE
    --vt            use Apple Video Toolbox encoder
    --nvenc         use Nvidia video encoder
    --qsv           use Intel Quick Sync video encoder
    --amf           use AMD video encoder
    --vaapi         use Video Acceleration API encoder
    --x264          use x264 software video encoder
    --x265          use x265    "       "      "
    --10-bit, --no-10-bit
                    use 10-bit color depth (default: not used for H.264,
                      used for HEVC with Nvidia, Intel and x265 encoders)
    --8-bit-vc1     use 8-bit color depth for VC-1 format only
    --preset NAME   apply video encoder preset
    --decode vc1|all|none
                    set scope of automatic hardware decoder acceleration
                      (default: vc1 for VC-1 format only)
    --cuda, --no-cuda
                    enable or disable scoped use of Nvidia video decoder
                      instead of generic hardware decoder
                      (default: enabled when using Nvidia video encoder,
                                disabled when using other encoders)
    --qsv-decoder   enable scoped use of Intel Quick Sync video decoder
                      instead of generic hardware decoder
    --qsv-device DEVICE
                    enable scoped use of QSV decoder for specific device
      HERE
    end

    def usage8
      <<-HERE
    --target [2160p=|1080p=|720p=|480p=]BITRATE
                    set video bitrate target (default: based on input)
                      or target for specific input resolution
    --crop WIDTH:HEIGHT:X:Y|TOP:BOTTOM:LEFT:RIGHT|auto
                    set video crop geometry (default: none)
                      or automatically detect it
    --720p          fit video within 1280x720 pixel bounds
      HERE
    end

    def usage9
      <<-HERE
    --1080p          "    "     "    1920x1080  "     "
    --deinterlace   reduce interlace artifacts without changing frame rate
                      (applied automatically for some inputs)
    --rate FPS      force constant video frame rate
                      (disables automatic deinterlacing)
    --detelecine    drop duplicate frames to restore original frame rate
                      (disables any deinterlacing and forced frame rate)
    --no-filters    disable any automatic adjustments via filters
      HERE
    end

    def usage10
      <<-HERE
    --overlay-params KEY=VALUE[:KEY=VALUE]...
                    override subtitle overlay filter configuration
    --yadif-params KEY=VALUE[:KEY=VALUE]...
                    override yadif deinterlace filter configuration
    --rc-maxrate FACTOR, --rc-bufsize FACTOR|BITRATE
                    set ratecontrol maximum rate and/or buffer size
                      as multiple of video bitrate target or specific bitrate
    --copy-video    disable transcoding and copy original video track

Apple Video Toolbox encoder options:
    --vt-allow-sw   allow software encoding

Nvidia video encoder options:
    --nvenc-recommended
                    apply optimal quality settings, equivalent to using:
                      `--nvenc-spatial-aq`
                      `--nvenc-lookahead 32`
                      `--nvenc-bframe-refs middle`
                      (not supported on all Nvidia hardware)
    --nvenc-spatial-aq
                    enable spatial adaptive quantization (AQ)
    --nvenc-temporal-aq
                    enable temporal adaptive quantization (AQ)
    --nvenc-lookahead FRAMES
                    set number of frames to look ahead for ratecontrol
    --nvenc-multipass qres|fullres
                    set multipass encoding resolution
    --nvenc-refs FRAMES
                    set number of reference frames
    --nvenc-bframes FRAMES
                    set maximum number of B-frames
    --nvenc-bframe-refs each|middle
                    set mode for using B-frames as reference frames
    --nvenc-cq QUALITY
                    use constant quality (CQ) ratecontrol at target quality
    --nvenc-gpu-only
                    keep data on GPU for greater speed, if possible

Intel Quick Sync video encoder options:
    --qsv-refs FRAMES
                    set number of reference frames
    --qsv-bframes FRAMES
                    set maximum number of B-frames

AMD video encoder options:
    --amf-quality balanced|speed|quality
                    set quality preference
    --amf-vbaq      enable variance based AQ
    --amf-pre-analysis
                    enable ratecontrol pre-analysis
    --amf-refs FRAMES
                    set maximum number of reference frames
    --amf-bframes FRAMES
                    set maximum number of B-frames

Video Acceleration API encoder options:
    --vaapi-compression LEVEL
                    set numeric level of compression

x264 software video encoder options:
    --x264-cbr      use constant bitrate (CBR) ratecontrol
                      with variable bitrate output
                      (raises default video bitrate targets)
    --x264-avbr     use average variable bitrate (AVBR) ratecontrol
    --x264-mbtree   use macroblock-tree ratecontrol (disables AVBR if in use)
    --x264-quick    increase encoding speed by 70-80%
                      with no easily perceptible loss in video quality
                      (avoids quality problems with some encoder presets)
    --x264-params KEY=VALUE[:KEY=VALUE]...
                    override x264 configuration (disables other x264 options)

x265 software video encoder options:
    --x265-params KEY=VALUE[:KEY=VALUE]...
                    override x265 configuration
      HERE
    end

    def usage11
      <<-HERE

Audio options:
    --main-audio TRACK[=WIDTH]
                    select main audio track by number (default: 1)
                      with optional width (default: surround)
      HERE
    end

    def usage12
      <<-HERE
                        (use `original` to disable transcoding)
      HERE
    end

    def usage13
      <<-HERE
    --add-audio TRACK|all|LANGUAGE|STRING[=WIDTH]
                    add single audio track by number
                      including main audio track
                    or all audio tracks
                      excluding main audio track
                    or audio tracks by language code
                      excluding main audio track
                      (in ISO 639-2 format, e.g.: `eng`)
                    or audio tracks with titles containing string
                      excluding main audio track
                      (comparison is case-insensitve)
                    with optional width (default: stereo)
      HERE
    end

    def usage14
      <<-HERE
                      (use `original` to disable transcoding)
      HERE
    end

    def usage15
      <<-HERE
    --surround-bitrate BITRATE
                    set surround audio bitrate (default: 448)
    --stereo-bitrate BITRATE
                    set stereo audio bitrate (default: 128)
      HERE
    end

    def usage16
      <<-HERE
    --mono-bitrate BITRATE
                    set mono audio bitrate (default: ~50% of stereo bitrate)
      HERE
    end

    def usage17
      <<-HERE
    --eac3          use Dolby Digital Plus (E-AC-3) format for all audio
                      (default bitrates: 448 for surround, 192 for stereo)
      HERE
    end

    def usage18
      <<-HERE
    --eac3-aac      use Dolby Digital Plus format only for surround audio
                      with AAC format for stereo audio
    --aac-only      use AAC format for all audio,
                      disabling passthrough of audio in other formats
                      (default bitrates: 341 for surround, 128 for stereo)
    --limit-ac3-surround
                    don't copy surround audio in AC-3 format
                      when orginal bitrate is above passthrough bitrate
    --keep-ac3-stereo
                    copy stereo and mono audio in AC-3 format
                      even when orginal bitrate is above passthrough bitrate
    --pass-dts      enable passthrough of audio in DTS and DTS-ES formats
      HERE
    end

    def usage19
      <<-HERE

Fraunhofer FDK AAC audio encoder options:
    --fdk-vbr MODE  set numeric variable bitrate (VBR) mode, from 1 to 5
      HERE
    end

    def usage20
      <<-HERE

Subtitle options:
    --add-subtitle TRACK[=forced]|auto|all|LANGUAGE|STRING
                    add single subtitle track by number
                      optionally setting forced disposition
                    or enable automatic addition of forced subtitle
                    or add all subtitle tracks
                    or subtitle tracks by language code
                      (in ISO 639-2 format, e.g.: `eng`)
                    or subtitle tracks with titles containing string
                      (comparison is case-insensitve)
                    (variations exclude any burned track)
    --burn-subtitle TRACK|auto
                    burn subtitle track by number into video
                      or enable automatic burning of forced subtitle
                      (only image-based subtitles are burned)

Other options:
-h, --help [more|full]
                    display help and exit
                      optionally including more or full information
    --version       output version information and exit

Requires `ffprobe`, `ffmpeg` and `mkvpropedit`.
      HERE
    end

    def initialize
      @position = nil
      @duration = nil
      @debug = false
      @scan = false
      @detect = false
      @preview = false
      @format = :mkv
      @copy_track_names = false
      @max_muxing_queue_size = nil
      @dry_run = false
      @hevc = false
      @encoder = nil
      @ten_bit = nil
      @eight_bit_vc1 = false
      @preset = nil
      @decode_scope = :vc1
      @decode_method = nil
      @qsv_device = nil
      @target_2160p = nil
      @target_1080p = nil
      @target_720p  = nil
      @target_480p  = nil
      @target = nil
      @crop = nil
      @max_width  = 3840
      @max_height = 2160
      @deinterlace = false
      @rate = nil
      @detelecine = false
      @enable_filters = true
      @overlay_params = nil
      @yadif_params = nil
      @maxrate = nil
      @bufsize = nil
      @vt_allow_sw = false
      @nvenc_spatial_aq = false
      @nvenc_temporal_aq = false
      @nvenc_lookahead = nil
      @nvenc_multipass = nil
      @nvenc_refs = nil
      @nvenc_bframes = nil
      @nvenc_bframe_refs = nil
      @nvenc_cq = nil
      @nvenc_gpu_only = false
      @qsv_refs = nil
      @qsv_bframes = nil
      @amf_quality = nil
      @amf_vbaq = false
      @amf_pre_analysis = false
      @amf_refs = nil
      @amf_bframes = nil
      @vaapi_compression = nil
      @x264_avbr = false
      @x264_mbtree = false
      @x264_quick = false
      @x264_params = nil
      @x265_params = nil
      @audio_selections = [{
        :track => 1,
        :language => nil,
        :title => nil,
        :width => :surround
      }]
      @surround_bitrate = nil
      @stereo_bitrate = nil
      @mono_bitrate = nil
      @surround_encoder = 'ac3'
      @stereo_encoder = nil
      @aac_fallback_encoder = 'aac'
      @keep_ac3_surround = true
      @keep_ac3_stereo = false
      @pass_dts = false
      @fdk_vbr_mode = nil
      @subtitle_selections = []
      @auto_add_subtitle = false
      @burn_subtitle_track = 0
    end

    def run
      begin
        OptionParser.new do |opts|
          define_options opts

          opts.on '-h', '--help [ARG]' do |arg|
            case arg
            when 'full'
              puts  usage1 + usage2 + usage3 + usage4 + usage5 + usage6 +
                    usage7 + usage8 + usage9 + usage10 + usage11 + usage12 +
                    usage13 + usage14 + usage15 + usage16 + usage17 +
                    usage18 + usage19 + usage20
            when 'more'
              puts  usage1 + usage2 + usage3 + usage4 + usage6 + usage7 +
                    usage8 + usage9 + usage11 + usage13 + usage15 + usage16 +
                    usage17 + usage18 + usage20
            else
              puts  usage1 + usage3 + usage6 + usage8 + usage11 + usage13 +
                    usage15 + usage17 + usage20
            end

            exit
          end

          opts.on '--version' do
            puts about
            exit
          end
        end.parse!
      rescue OptionParser::ParseError => e
        raise UsageError, e
      end

      fail UsageError, 'missing argument' if ARGV.empty?

      configure ARGV.first
      ARGV.each { |arg| process_input arg }
      exit
    rescue UsageError => e
      Kernel.warn "#{$PROGRAM_NAME}: #{e}"
      Kernel.warn "Try `#{File.basename($PROGRAM_NAME)} --help` for more information."
      exit false
    rescue StandardError => e
      Kernel.warn "#{$PROGRAM_NAME}: #{e}"
      exit(-1)
    rescue SignalException
      puts
      exit(-1)
    end

    def define_options(opts)
      opts.on '--position ARG' do |arg|
        @position = resolve_time(arg)
      end

      opts.on '--duration ARG' do |arg|
        @duration = resolve_time(arg)
      end

      opts.on '--debug' do
        @debug = true
      end

      opts.on '--scan' do
        @scan = true
      end

      opts.on '--preview-crop' do
        @detect = true
        @preview = true
      end

      opts.on '--print-crop' do
        @detect = true
        @preview = false
      end

      opts.on '--mp4' do
        @format = :mp4
      end

      opts.on '--copy-track-names' do
        @copy_track_names = true
      end

      opts.on '--max-muxing-queue-size ARG', Integer do |arg|
        @max_muxing_queue_size = [arg, 1].max
      end

      opts.on '-n', '--dry-run' do
        @dry_run = true
      end

      opts.on '--hevc' do
        @encoder = 'libx265' if @encoder == 'libx264'
        @hevc = true
      end

      opts.on '--vt' do
        @encoder = @hevc ? 'hevc_videotoolbox' : 'h264_videotoolbox'
      end

      opts.on '--nvenc' do
        @encoder = @hevc ? 'hevc_nvenc' : 'h264_nvenc'
      end

      opts.on '--qsv' do
        @encoder = @hevc ? 'hevc_qsv' : 'h264_qsv'
      end

      opts.on '--amf' do
        @encoder = @hevc ? 'hevc_amf' : 'h264_amf'
      end

      opts.on '--vaapi' do
        @encoder = @hevc ? 'hevc_vaapi' : 'h264_vaapi'
      end

      opts.on '--x264' do
        @encoder = 'libx264'
        @hevc = false
      end

      opts.on '--x265' do
        @encoder = 'libx265'
        @hevc = true
      end

      opts.on '--[no-]10-bit' do |arg|
        @ten_bit = arg
        @eight_bit_vc1 = false
        @encoder = nil if @encoder == 'copy'
      end

      opts.on '--8-bit-vc1' do
        @eight_bit_vc1 = true
        @encoder = nil if @encoder == 'copy'
      end

      opts.on '--preset ARG' do |arg|
        @preset = arg
        @encoder = nil if @encoder == 'copy'
      end

      opts.on '--decode ARG' do |arg|
        @decode_scope = case arg
        when 'vc1', 'all', 'none'
          arg.to_sym
        else
          fail UsageError, "invalid scope for automatic hardware decoder usage: #{$1}"
        end
      end

      opts.on '--[no-]cuda' do |arg|
        @decode_method = arg ? 'cuda' : 'auto'
      end

      opts.on '--qsv-decoder' do
        @decode_method = 'qsv'
      end

      opts.on '--qsv-device ARG' do |arg|
        @qsv_device = arg
        @decode_method = 'qsv'
      end

      opts.on '--target ARG' do |arg|
        if arg =~ /^([0-9]+p)=([1-9][0-9]*)$/
          bitrate = [$2.to_i, 1].max

          case $1
          when '2160p'
            @target_2160p = bitrate
          when '1080p'
            @target_1080p = bitrate
          when '720p'
            @target_720p = bitrate
          when '480p'
            @target_480p = bitrate
          else
            fail UsageError, "invalid target video bitrate resolution: #{$1}"
          end

          @target = nil
        else
          @target = [arg.to_i, 1].max
        end

        @nvenc_cq = nil
        @encoder = nil if @encoder == 'copy'
      end

      opts.on '--crop ARG' do |arg|
        case arg
        when /^([0-9]+):([0-9]+):([0-9]+):([0-9]+)$/
          @crop = [$1.to_i, $2.to_i, $3.to_i, $4.to_i]
        when 'auto'
          @crop = arg.to_sym
        else
          fail UsageError, "invalid crop geometry: #{arg}"
        end

        @encoder = nil if @encoder == 'copy'
      end

      opts.on '--720p' do
        @max_width  = 1280
        @max_height = 720
        @encoder = nil if @encoder == 'copy'
      end

      opts.on '--1080p' do
        @max_width  = 1920
        @max_height = 1080
        @encoder = nil if @encoder == 'copy'
      end

      opts.on '--deinterlace' do
        @deinterlace = true
        @detelecine = false
        @enable_filters = false
        @encoder = nil if @encoder == 'copy'
      end

      opts.on '--rate ARG' do |arg|
        @rate = case arg
        when /(24000|30000|60000)\/1001/, /(24|25)\/1/
          arg
        when '23.976', 'film'
          '24000/1001'
        when 'pal'
          '25/1'
        when '29.97', 'ntsc'
          '30000/1001'
        when '59.94'
          '60000/1001'
        when /^[0-9]+$/
          [[arg.to_i, 1].max, 1000].min.to_s + '/1'
        else
          fail UsageError, "invalid frame rate: #{arg}"
        end

        @detelecine = false
        @enable_filters = false
        @encoder = nil if @encoder == 'copy'
      end

      opts.on '--detelecine' do
        @detelecine = true
        @deinterlace = false
        @rate = nil
        @enable_filters = false
        @encoder = nil if @encoder == 'copy'
      end

      opts.on '--no-filters' do
        @enable_filters = false
      end

      opts.on '--overlay-params ARG' do |arg|
        arg.split ':' do |param|
          fail UsageError, "invalid argument: #{arg}" unless param =~ /^[\w\-]+=[\w\-\.,\(\)]+$/
        end

        @overlay_params = arg
      end

      opts.on '--yadif-params ARG' do |arg|
        arg.split ':' do |param|
          fail UsageError, "invalid argument: #{arg}" unless param =~ /^[\w\-]+=[\w\-\.,\(\)]+$/
        end

        @yadif_params = arg
      end

      opts.on '--rc-maxrate ARG', Float do |arg|
        @maxrate = arg
        @encoder = nil if @encoder == 'copy'
      end

      opts.on '--rc-bufsize ARG', Float do |arg|
        @bufsize = arg
        @encoder = nil if @encoder == 'copy'
      end

      opts.on '--copy-video' do
        @encoder = 'copy'
        @hevc = false
        @ten_bit = nil
        @preset = nil
        @target = nil
        @crop = nil
        @rate = nil
        @detelecine = false
        @enable_filters = false
        @burn_subtitle_track = 0
      end

      opts.on '--vt-allow-sw' do
        @encoder = @hevc ? 'hevc_videotoolbox' : 'h264_videotoolbox'
        @vt_allow_sw = true
      end

      opts.on '--nvenc-recommended' do
        @encoder = @hevc ? 'hevc_nvenc' : 'h264_nvenc'
        @nvenc_spatial_aq = true
        @nvenc_lookahead = 32
        @nvenc_bframe_refs = 'middle'
      end

      opts.on '--nvenc-spatial-aq' do
        @encoder = @hevc ? 'hevc_nvenc' : 'h264_nvenc'
        @nvenc_spatial_aq = true
      end

      opts.on '--nvenc-temporal-aq' do
        @encoder = @hevc ? 'hevc_nvenc' : 'h264_nvenc'
        @nvenc_temporal_aq = true
      end

      opts.on '--nvenc-lookahead ARG', Integer do |arg|
        @encoder = @hevc ? 'hevc_nvenc' : 'h264_nvenc'

        if arg > 0
          @nvenc_lookahead = [arg, 32].min
        else
          @nvenc_lookahead = nil
        end
      end

      opts.on '--nvenc-multipass ARG' do |arg|
        @encoder = @hevc ? 'hevc_nvenc' : 'h264_nvenc'

        @nvenc_multipass = case arg
        when 'qres', 'fullres'
          arg
        else
          fail UsageError, "invalid multipass resolution argument: #{arg}"
        end
      end

      opts.on '--nvenc-refs ARG', Integer do |arg|
        @encoder = @hevc ? 'hevc_nvenc' : 'h264_nvenc'
        @nvenc_refs = [arg, 0].max
      end

      opts.on '--nvenc-bframes ARG', Integer do |arg|
        @encoder = @hevc ? 'hevc_nvenc' : 'h264_nvenc'
        @nvenc_bframes = [[arg, 0].max, 4].min
      end

      opts.on '--nvenc-bframe-refs ARG' do |arg|
        @encoder = @hevc ? 'hevc_nvenc' : 'h264_nvenc'

        @nvenc_bframe_refs = case arg
        when 'each', 'middle'
          arg
        else
          fail UsageError, "invalid B-frames as references argument: #{arg}"
        end
      end

      opts.on '--nvenc-cq ARG', Float do |arg|
        @encoder = @hevc ? 'hevc_nvenc' : 'h264_nvenc'
        @nvenc_cq = [[arg, 1].max, 51].min.to_s.sub(/\.0$/, '')
      end

      opts.on '--nvenc-gpu-only' do
        @encoder = @hevc ? 'hevc_nvenc' : 'h264_nvenc'
        @decode_scope = :all
        @decode_method = 'cuda'
        @nvenc_gpu_only = true
      end

      opts.on '--qsv-refs ARG', Integer do |arg|
        @encoder = @hevc ? 'hevc_qsv' : 'h264_qsv'
        @qsv_refs = [arg, 0].max
      end

      opts.on '--qsv-bframes ARG', Integer do |arg|
        @encoder = @hevc ? 'hevc_qsv' : 'h264_qsv'
        @qsv_bframes = [arg, -1].max
      end

      opts.on '--amf-quality ARG' do |arg|
        @encoder = @hevc ? 'hevc_amf' : 'h264_amf'

        @amf_quality = case arg
        when 'balanced', 'speed', 'quality'
          arg
        else
          fail UsageError, "invalid quality argument: #{arg}"
        end
      end

      opts.on '--amf-vbaq' do
        @encoder = @hevc ? 'hevc_amf' : 'h264_amf'
        @amf_vbaq = true
      end

      opts.on '--amf-pre_analysis' do
        @encoder = @hevc ? 'hevc_amf' : 'h264_amf'
        @amf_pre_analysis = true
      end

      opts.on '--amf-refs ARG', Integer do |arg|
        @encoder = @hevc ? 'hevc_amf' : 'h264_amf'
        @amf_refs = [arg, 0].max
      end

      opts.on '--amf-bframes ARG', Integer do |arg|
        @encoder = @hevc ? 'hevc_amf' : 'h264_amf'
        @amf_bframes = [arg, 1].max
      end

      opts.on '--vaapi-compression ARG', Integer do |arg|
        @encoder = @hevc ? 'hevc_vaapi' : 'h264_vaapi'
        @vaapi_compression = [arg, 0].max
      end

      opts.on '--x264-cbr' do
        @encoder = 'libx264'
        @hevc = false
        @x264_mbtree = true
        @x264_avbr = false
        @x264_params = nil
        @maxrate = 1.0
        @bufsize = nil
      end

      opts.on '--x264-avbr' do
        @encoder = 'libx264'
        @hevc = false
        @x264_avbr = true
        @x264_mbtree = false
        @x264_params = nil
      end

      opts.on '--x264-mbtree' do
        @encoder = 'libx264'
        @hevc = false
        @x264_mbtree = true
        @x264_avbr = false
        @x264_params = nil
      end

      opts.on '--x264-quick' do
        @encoder = 'libx264'
        @hevc = false
        @x264_quick = true
        @x264_params = nil
        @preset = nil
      end

      opts.on '--x264-params ARG' do |arg|
        arg.split ':' do |param|
          fail UsageError, "invalid argument: #{arg}" unless param =~ /^[\w\-]+=[\w\-\.,\(\)]+$/
        end

        @encoder = 'libx264'
        @hevc = false
        @x264_params = arg
        @x264_avbr = false
        @x264_mbtree = true
        @x264_quick = false
      end

      opts.on '--x265-params ARG' do |arg|
        arg.split ':' do |param|
          fail UsageError, "invalid argument: #{arg}" unless param =~ /^[\w\-]+=[\w\-\.,\(\)]+$/
        end

        @encoder = 'libx265'
        @hevc = true
        @x265_params = arg
      end

      opts.on '--main-audio ARG' do |arg|
        if arg =~ /^([0-9]+)(?:=(stereo|surround|original))?$/
          @audio_selections[0][:track] = $1.to_i
          @audio_selections[0][:width] = $2.to_sym unless $2.nil?
        else
          fail UsageError, "invalid main audio argument: #{arg}"
        end
      end

      opts.on '--add-audio ARG' do |arg|
        if arg =~ /^([^=]+)(?:=(stereo|surround|original))?$/
          scope = $1
          width = $2

          selection = {
            :track => nil,
            :language => nil,
            :title => nil,
            :width => :stereo
          }

          case scope
          when /^[0-9]+$/
            selection[:track] = scope.to_i
          when /^[a-z]{3}$/
            selection[:language] = scope
          else
            selection[:title] = scope
          end

          selection[:width] = width.to_sym unless width.nil?
          @audio_selections += [selection]
        else
          fail UsageError, "invalid add audio argument: #{arg}"
        end
      end

      opts.on '--surround-bitrate ARG', Integer do |arg|
        @surround_bitrate = arg
      end

      opts.on '--stereo-bitrate ARG', Integer do |arg|
        @stereo_bitrate = arg
        @mono_bitrate ||= @stereo_bitrate / 2
      end

      opts.on '--mono-bitrate ARG', Integer do |arg|
        @mono_bitrate = arg
      end

      opts.on '--eac3' do
        @surround_encoder = 'eac3'
        @stereo_encoder   = 'eac3'
      end

      opts.on '--eac3-aac' do
        @surround_encoder = 'eac3'
        @stereo_encoder = nil
      end

      opts.on '--aac-only' do
        @surround_encoder = nil
        @stereo_encoder   = nil
      end

      opts.on '--limit-ac3-surround' do
        @keep_ac3_surround = false
      end

      opts.on '--keep-ac3-stereo' do
        @keep_ac3_stereo = true
        @surround_encoder ||= 'ac3'
      end

      opts.on '--pass-dts' do
        @pass_dts = true
        @surround_encoder ||= 'ac3'
      end

      opts.on '--fdk-vbr ARG', Integer do |arg|
        @fdk_vbr_mode = [[arg, 1].max, 5].min.to_s
      end

      opts.on '--add-subtitle ARG' do |arg|
        if arg =~ /^([0-9]+)(?:=(forced))?$|^(auto)$|^([a-z]{3})$|^(.*)$/
          @subtitle_selections += [{
            :track => $1.to_i,
            :forced => $2.nil? ? false : true,
            :language => $4,
            :title => $5
          }]

          @auto_add_subtitle = false unless $2.nil?
          @auto_add_subtitle = true unless $3.nil?
        else
          fail UsageError, "invalid add subtitle argument: #{arg}"
        end
      end

      opts.on '--burn-subtitle ARG' do |arg|
        @burn_subtitle_track = case arg
        when /^[0-9]+$/
          arg.to_i
        when 'auto'
          arg.to_sym
        else
          fail UsageError, "invalid subtitle track: #{arg}"
        end

        @encoder = nil if @encoder == 'copy'
      end
    end

    def resolve_time(arg)
      time = 0.0

      case arg
      when /^([0-9]+(?:\.[0-9]+)?)$/
        time = $1.to_f
      when /^(?:(?:([0-9][0-9]):)?([0-9][0-9]):)?([0-9][0-9](?:\.[0-9]+)?)$/
        time = $3.to_f
        time = ($2.to_i * 60) + time unless $2.nil?
        time = ($1.to_i * 60 * 60) + time unless $1.nil?
      else
        fail UsageError, "invalid time: #{arg}"
      end

      time
    end

    def configure(path)
      @audio_selections.uniq!
      @subtitle_selections.uniq!

      [
        ['ffprobe', '-loglevel', 'quiet', '-version'],
        ['ffmpeg', '-loglevel', 'quiet', '-version'],
        ['mkvpropedit', '--version']
      ].each do |command|
        verify_tool_availability command
      end

      return if @scan or @detect

      encoders = find_encoders

      if @encoder.nil?
        standard = @hevc ? 'hevc' : 'h264'
        name = "#{standard}_videotoolbox"

        if encoders =~ /#{name}/
          @encoder = name if try_encoder(name, path)
        else
          ['nvenc', 'qsv', 'amf', 'vaapi'].each do |platform|
            name = standard + '_' + platform

            if encoders =~ /#{name}/ and try_encoder(name, path)
              @encoder = name
              break
            end
          end
        end

        @encoder ||= @hevc ? 'libx265' : 'libx264'
      else
        @encoder.sub!(/^h264/, 'hevc') if @hevc

        unless @dry_run or @encoder == 'copy' or encoders =~ /#{@encoder}/
          fail "video encoder not available: #{@encoder}"
        end
      end

      @nvenc_cq = nil unless @encoder =~ /nvenc$/
      @ten_bit = (@hevc and @encoder =~ /(nvenc|qsv|x265)$/ ? true : false) if @ten_bit.nil?

      if @encoder == 'libx264' and @x264_mbtree and @maxrate == 1.0
        @target_2160p ||= 15000
        @target_1080p ||= 7500
        @target_720p  ||= 4500
        @target_480p  ||= 2250
      else
        @target_2160p ||= @hevc ? 8000 : 12000
        @target_1080p ||= @hevc ? 4000 :  6000
        @target_720p  ||= @hevc ? 2000 :  3000
        @target_480p  ||= @hevc ? 1000 :  1500
      end

      @decode_method ||= @encoder =~ /nvenc$/ ? 'cuda' : 'auto'

      if @stereo_encoder.nil?
        if encoders =~ /aac_at/ or encoders =~ /libfdk_aac/
          @stereo_encoder = $MATCH
          @aac_fallback_encoder = 'libfdk_aac' if encoders =~ /libfdk_aac/
        else
          @stereo_encoder = 'aac'
        end

        @surround_encoder ||= @stereo_encoder
      end
    end

    def verify_tool_availability(command)
      Kernel.warn "Verifying \"#{command[0]}\" availability..."

      begin
        IO.popen(command, :err=>[:child, :out]) do |io|
          io.each do |line|
            Kernel.warn line if @debug
          end
        end
      rescue SystemCallError => e
        raise "verifying tool availability failed: #{e}"
      end

      fail "verifying tool availability failed: #{command[0]}" unless $CHILD_STATUS.exitstatus == 0
    end

    def find_encoders
      Kernel.warn 'Finding encoders...'
      output = ''

      begin
        IO.popen([
          'ffmpeg',
          '-loglevel', 'quiet',
          '-encoders'
        ], :err=>[:child, :out]) do |io|
          io.each do |line|
            Kernel.warn line if @debug
            output += line
          end
        end
      rescue SystemCallError => e
        raise "finding encoders failed: #{e}"
      end

      fail 'finding encoders failed' unless $CHILD_STATUS.exitstatus == 0

      output
    end

    def try_encoder(encoder, path)
      Kernel.warn "Trying \"#{encoder}\" video encoder..."
      begin
        IO.popen([
          'ffmpeg',
          '-loglevel', 'quiet',
          '-nostdin',
          *(encoder =~ /vaapi$/ ? ['-vaapi_device', '/dev/dri/renderD128'] : []),
          '-i', path,
          '-frames:v', '1',
          *(encoder =~ /vaapi$/ ? ['-filter:v', 'format=nv12,hwupload'] : []),
          '-c:v', encoder,
          '-b:v', '1000k',
          *(encoder =~ /nvenc$/ ? ['-rc:v', 'vbr'] : []),
          *(encoder == 'h264_qsv' ? ['-look_ahead:v', '1'] : []),
          *(encoder == 'hevc_qsv' ? ['-load_plugin:v', 'hevc_hw'] : []),
          *(encoder =~ /amf$/ ? ['-rc:v', 'vbr_latency'] : []),
          '-an',
          '-sn',
          '-ignore_unknown',
          '-f', 'null',
          '-'
        ], :err=>[:child, :out]) do |io|
          io.each do |line|
            Kernel.warn line if @debug
          end
        end
      rescue SystemCallError => e
        raise "trying \"#{encoder}\" encoder failed: #{e}"
      end

      $CHILD_STATUS.exitstatus == 0
    end

    def process_input(path)
      seconds = Time.now.tv_sec

      unless @scan or @detect
        output_path = File.basename(path, '.*') + '.' + @format.to_s
        fail_or_warn "output file already exists: #{output_path}" if File.exist? output_path
      end

      media_info = scan_media(path)

      if @scan
        print_media_info media_info
        return
      end

      video, burn_subtitle = get_video_streams(media_info)
      fail "video track not found: #{path}" if video.nil?

      max_x = video['width'] / 4
      max_y = video['height'] / 4

      if @detect or @crop == :auto
        crop = detect_crop(media_info, video)

        if @detect
          present_crop crop, path
          return
        else
          Kernel.warn "crop = #{crop[:width]}:#{crop[:height]}:#{crop[:x]}:#{crop[:y]}"
        end
      elsif @crop.nil?
        crop = nil
      elsif @crop[2] <= max_x and @crop[3] <= max_x and @crop[0] <= max_y and @crop[1] <= max_y
        Kernel.warn 'Interpreting crop geometry as TOP:BOTTOM:LEFT:RIGHT values...'
        crop = {
          :width  => video['width'] - (@crop[2] + @crop[3]),
          :height => video['height'] - (@crop[0] + @crop[1]),
          :x      => @crop[2],
          :y      => @crop[0]
        }
      else
        crop = {
          :width  => @crop[0],
          :height => @crop[1],
          :x      => @crop[2],
          :y      => @crop[3]
        }
      end

      time_options = get_time_options(media_info, burn_subtitle)
      decode_options, encode_options = get_video_options(media_info, video, burn_subtitle, crop)

      ffmpeg_command = [
        'ffmpeg',
        '-loglevel', (@debug ? 'verbose' : 'error'),
        '-stats',
        *time_options,
        *decode_options,
        '-i', path,
        *(@max_muxing_queue_size.nil? ? [] : ['-max_muxing_queue_size', @max_muxing_queue_size.to_s]),
        *encode_options,
        *get_audio_options(media_info),
        *get_subtitle_options(media_info, burn_subtitle),
        '-metadata:g', 'title=',
        *(@format == :mkv ? ['-default_mode', 'passthrough'] : ['-movflags', 'disable_chpl']),
        output_path
      ]

      command_line = escape_command(ffmpeg_command)
      Kernel.warn 'Command line:'

      if @dry_run
        puts command_line
        return
      end

      Kernel.warn command_line
      Kernel.warn 'Transcoding...'
      output = ''

      begin
        IO.popen(
            @debug ? {'FFREPORT' => "level=40"} : {},
            ffmpeg_command,
            'rb',
            :err=>[:child, :out]) do |io|
          Signal.trap 'INT' do
            Process.kill 'INT', io.pid
          end

          io.each_char do |char|
            output += char
            STDERR.print char
          end
        end
      rescue SystemCallError => e
        raise "transcoding failed: #{e}"
      end

      fail "transcoding failed: #{output_path}" unless $CHILD_STATUS.exitstatus == 0

      if @format == :mp4
        Kernel.warn 'Done.'
      else
        add_track_statistics_tags output_path
        ten_bit = (@ten_bit ? (@eight_bit_vc1 ? (video['codec_name'] != 'vc1') : true) : false)

        if (video.fetch('pix_fmt', 'yuv420p') == 'yuv420p10le') and ten_bit
          add_hdr_info path, output_path
        end
      end

      Kernel.warn "\nElapsed time: #{seconds_to_time(Time.now.tv_sec - seconds)}\n\n"
    end

    def fail_or_warn(message)
      if @dry_run
        Kernel.warn "#{$PROGRAM_NAME}: #{message}"
      else
        fail message
      end
    end

    def scan_media(path)
      Kernel.warn 'Scanning media...'
      output = ''

      begin
        IO.popen([
          'ffprobe',
          '-loglevel', 'quiet',
          '-show_streams',
          '-show_format',
          '-print_format', 'json',
          path
        ], :err=>[:child, :out]) do |io|
          io.each do |line|
            Kernel.warn line if @debug
            output += line
          end
        end
      rescue SystemCallError => e
        raise "scanning media failed: #{e}"
      end

      fail "scanning media failed: #{path}" unless $CHILD_STATUS.exitstatus == 0

      begin
        media_info = JSON.parse(output)
      rescue JSON::JSONError
        fail "media information not found: #{path}"
      end

      Kernel.warn media_info.inspect if @debug
      media_info
    end

    def print_media_info(media_info)
      video = nil
      audio_streams = []
      subtitles = []

      media_info['streams'].each do |stream|
        case stream['codec_type']
        when 'video'
          video = stream if video.nil?
        when 'audio'
          audio_streams += [stream]
        when 'subtitle'
          subtitles += [stream]
        end
      end

      puts media_info['format']['filename']
      size = "#{video['width']} x #{video['height']}"
      print "      format = #{video['codec_name']} / #{size} / #{video['avg_frame_rate']} fps"
      bitrate = get_bitrate(video)
      puts bitrate.nil? ? '' : " / #{bitrate} Kbps"
      duration = media_info['format']['duration'].to_f
      time = seconds_to_time(duration.to_i)
      milliseconds = duration.to_s.sub(/^[0-9]+(\.[0-9]+)$/, '\1')
      time += milliseconds unless milliseconds == '.0'
      puts "    duration = #{time}"
      index = 0

      audio_streams.each do |stream|
        index += 1
        puts "\##{index} audio:"
        codec_name = stream['codec_name']
        print "      format = #{codec_name}"

        if codec_name == 'dts'
          profile = stream.fetch('profile', 'DTS')
          print " (#{profile})" unless profile == 'DTS'
        end

        print ' / '
        layout = stream.fetch('channel_layout', '')

        if layout.empty?
          channels = stream['channels'].to_i
          print "#{channels} " + (channels > 1 ? 'channels' : 'channel')
        else
          print "#{layout}"
        end

        bitrate = get_bitrate(stream)
        puts bitrate.nil? ? '' : " / #{bitrate} Kbps"
        puts "    language = #{stream.fetch('tags', {}).fetch('language', '')}"
        title = stream.fetch('tags', {}).fetch('title', '')
        puts "       title = #{title}" unless title.empty?
      end

      index = 0

      subtitles.each do |stream|
        index += 1
        puts "\##{index} subtitle:"
        print "      format = #{stream['codec_name']}"
        tags = stream.fetch('tags', {})
        frames = tags.fetch('NUMBER_OF_FRAMES', tags.fetch('NUMBER_OF_FRAMES-eng', ''))
        puts frames.empty? ? '' : " / #{frames} " + (frames == 1 ? 'frame' : 'frames')
        puts "    language = #{tags.fetch('language', '')}"
        title = tags.fetch('title', '')
        puts "       title = #{title}" unless title.empty?
        default = (stream['disposition']['default'] == 1)
        forced  = (stream['disposition']['forced'] == 1)

        if default or forced
          puts '       flags = ' +
            (default ? 'default' : '') +
            ((default and forced) ? ' / ' : '') +
            (forced ? 'forced' : '')
        end
      end
    end

    def get_bitrate(stream)
      tags = stream.fetch('tags', {})
      bitrate = stream.fetch('bit_rate', tags.fetch('BPS', tags.fetch('BPS-eng', '')))
      return nil if bitrate.empty?

      bitrate.to_i / 1000
    end

    def detect_crop(media_info, video)
      Kernel.warn 'Detecting crop...'
      duration = media_info['format']['duration'].to_f
      fail "media duration too short: #{duration}" if duration < 2.0
      steps = 10
      interval = (duration / (steps + 1)).to_i
      target_interval = 5 * 60

      if interval == 0
        steps = 1
        interval = 1
      elsif interval > target_interval
        steps = ((duration / target_interval) - 1).to_i
        interval = (duration / (steps + 1)).to_i
      end

      Kernel.warn "duration = #{duration} / steps = #{steps} / interval = #{interval}" if @debug
      width   = video['width'].to_i
      height  = video['height'].to_i

      no_crop = {
        :width => width,
        :height => height,
        :x => 0,
        :y => 0
      }

      all_crop = {
        :width => 0,
        :height => 0,
        :x => width,
        :y => height
      }

      crop = all_crop.dup
      last_crop = crop.dup
      ignore_count = 0
      last_seconds = Time.now.tv_sec
      path = media_info['format']['filename']

      (1..steps).each do |step|
        s_crop = all_crop.dup

        begin
          position = (interval * step)

          if @debug
            Kernel.warn "crop = #{crop}"
            Kernel.warn "step = #{step} / position = #{position}"
          end

          IO.popen([
            'ffmpeg',
            '-hide_banner',
            '-nostdin',
            '-noaccurate_seek',
            '-ss', position.to_s,
            '-i', path,
            '-frames:v', '15',
            '-filter:v', 'cropdetect=24.0/255:2',
            '-an',
            '-sn',
            '-ignore_unknown',
            '-f', 'null',
            '-'
          ], :err=>[:child, :out]) do |io|
            io.each do |line|
              seconds = Time.now.tv_sec

              if seconds - last_seconds >= 3
                Kernel.warn '...'
                last_seconds = seconds
              end

              if line =~ / crop=([0-9]+):([0-9]+):([0-9]+):([0-9]+)$/
                d_width, d_height, d_x, d_y = $1.to_i, $2.to_i, $3.to_i, $4.to_i
                s_crop[:width]  = d_width   if s_crop[:width]   < d_width
                s_crop[:height] = d_height  if s_crop[:height]  < d_height
                s_crop[:x]      = d_x       if s_crop[:x]       > d_x
                s_crop[:y]      = d_y       if s_crop[:y]       > d_y
                Kernel.warn line if @debug
              end
            end
          end
        rescue SystemCallError => e
          raise "crop detection failed: #{e}"
        end

        fail 'crop detection failed' unless $CHILD_STATUS.exitstatus == 0

        if s_crop == no_crop and last_crop != no_crop
          ignore_count += 1
          Kernel.warn "ignore crop = #{s_crop}" if @debug
        else
          crop[:width]  = s_crop[:width]  if crop[:width]   < s_crop[:width]
          crop[:height] = s_crop[:height] if crop[:height]  < s_crop[:height]
          crop[:x]      = s_crop[:x]      if crop[:x]       > s_crop[:x]
          crop[:y]      = s_crop[:y]      if crop[:y]       > s_crop[:y]
        end

        last_crop = s_crop.dup
      end

      Kernel.warn "ignore count = #{ignore_count}" if @debug

      if  crop == all_crop or
          ignore_count > 2 or (
            ignore_count > 0 and (((crop[:width] + 2) == width and crop[:height] == height))
          )
        crop = no_crop
      end

      crop
    end

    def present_crop(crop, path)
      crop_string = "#{crop[:width]}:#{crop[:height]}:#{crop[:x]}:#{crop[:y]}"

      if @preview
        drawbox_string = "#{crop[:x]}:#{crop[:y]}:#{crop[:width]}:#{crop[:height]}"
        puts
        puts escape_command([
          'mpv', '--no-audio', "--vf=lavfi=[drawbox=#{drawbox_string}:invert:1]", path
        ])
        puts escape_command([
          'mpv', '--no-audio', "--vf=crop=#{crop_string}", path
        ])
        puts
        puts escape_command([
          File.basename($PROGRAM_NAME), '--crop', crop_string, path
        ])
        puts
      else
        puts crop_string
      end
    end

    def escape_command(command)
      command_line = ''
      command.each {|item| command_line += "#{escape_string(item)} " }
      command_line.sub!(/ $/, '')
      command_line
    end

    def escape_string(str)
      # See: https://github.com/larskanis/shellwords
      return '""' if str.empty?

      str = str.dup

      if RUBY_PLATFORM =~ /mingw/
        str.gsub!(/((?:\\)*)"/) { "\\" * ($1.length * 2) + "\\\"" }

        if str =~ /\s/
          str.gsub!(/(\\+)\z/) { "\\" * ($1.length * 2 ) }
          str = "\"#{str}\""
        end
      else
        str.gsub!(/([^A-Za-z0-9_\-.,:\/@\n])/, "\\\\\\1")
        str.gsub!(/\n/, "'\n'")
      end

      str
    end

    def get_video_streams(media_info)
      video = nil
      subtitle_track = 0
      burn_subtitle = nil

      media_info['streams'].each do |stream|
        case stream['codec_type']
        when 'video'
          video = stream if video.nil?
        when 'subtitle'
          subtitle_track += 1

          if stream['codec_name'] == 'hdmv_pgs_subtitle' or stream['codec_name'] == 'dvd_subtitle'
            if @burn_subtitle_track == :auto
              burn_subtitle = stream if stream['disposition']['forced'] == 1
            else
              burn_subtitle = stream if @burn_subtitle_track == subtitle_track
            end
          end
        end
      end

      return video, burn_subtitle
    end

    def get_time_options(media_info, burn_subtitle)
      duration = media_info['format']['duration'].to_f
      fail "media duration too short: #{duration}" if duration < 2.0

      if @position.nil?
        position = 0.0
      else
        position = [duration - 1.0, @position].min
        duration -= position
      end

      duration = [duration, [@duration, 0.1].max].min unless @duration.nil?
      options = []

      unless burn_subtitle.nil? and @position.nil?
        options += ['-ss', position.to_s.sub(/\.0$/, '')]
      end

      unless burn_subtitle.nil? and @duration.nil?
        options += ['-t', duration.to_s.sub(/\.0$/, '')]
      end

      time = seconds_to_time(duration.to_i)
      milliseconds = duration.to_s.sub(/^[0-9]+(\.[0-9]+)$/, '\1')
      time += milliseconds unless milliseconds == '.0'
      Kernel.warn "duration = #{time}"
      options
    end

    def seconds_to_time(seconds)
      sprintf("%02d:%02d:%02d", seconds / (60 * 60), (seconds / 60) % 60, seconds % 60)
    end

    def get_video_options(media_info, video, burn_subtitle, crop)
      if burn_subtitle.nil?
        overlay_filter = nil
      else
        overlay_filter = "[0:#{burn_subtitle['index']}]overlay"
        overlay_filter += "=#{@overlay_params}" unless @overlay_params.nil?
      end

      deinterlace = @deinterlace

      if @enable_filters and video.fetch('field_order', 'progressive') != 'progressive'
        deinterlace = true
      end

      frame_rate_filter = nil

      if deinterlace and @encoder != 'copy'
        frame_rate_filter = 'yadif'
        frame_rate_filter += "=#{@yadif_params}" unless @yadif_params.nil?
      end

      unless @rate.nil?
        frame_rate_filter = '' if frame_rate_filter.nil?
        frame_rate_filter += ',' unless frame_rate_filter.empty?
        frame_rate_filter += "fps=#{@rate}"
      end

      if @detelecine
        frame_rate_filter = 'fieldmatch=order=tff:combmatch=none,decimate'
      end

      width   = video['width'].to_i
      height  = video['height'].to_i

      if crop.nil? or (crop == {:width => width, :height => height, :x => 0, :y => 0})
        crop_filter = nil
      else
        width       = crop[:width]
        height      = crop[:height]
        crop_filter = "crop=#{width}:#{height}:#{crop[:x]}:#{crop[:y]}"
      end

      if @hevc
        max_width   = @max_width
        max_height  = @max_height
      else
        max_width   = [@max_width,  1920].min
        max_height  = [@max_height, 1080].min
      end

      if video['sample_aspect_ratio'] = '1:1' and (width > max_width or height > max_height)
        scale = [(max_width.to_f / width), (max_height.to_f / height)].min
        width   = ((width   * scale).ceil / 2) * 2
        height  = ((height  * scale).ceil / 2) * 2
        scale_filter = "scale=#{width}:#{height}"
        scale_filter += ':flags=bicubic' unless overlay_filter.nil?
      else
        scale_filter = nil
      end

      if @encoder =~ /vaapi$/
        decode_options = ['-vaapi_device', '/dev/dri/renderD128']
      else
        decode_options = []
      end

      nvenc_gpu_only = false

      if (@decode_scope == :vc1 and video['codec_name'] == 'vc1') or @decode_scope == :all
        if @encoder =~ /vaapi$/
          decode_options = [
            '-hwaccel', 'vaapi',
            '-hwaccel_device', '/dev/dri/renderD128',
            '-hwaccel_output_format', 'vaapi'
          ]
        else
          if @decode_method == 'qsv' and @encoder != 'h264_qsv'
            decode_method = 'auto'
          else
            decode_method = @decode_method
          end

          decode_options += ['-hwaccel', decode_method]

          if  @nvenc_gpu_only and
              decode_method == 'cuda' and
              @encoder =~ /nvenc$/ and
              overlay_filter.nil? and
              (frame_rate_filter.nil? or frame_rate_filter !~ /fps=/) and
              crop_filter.nil? and
              scale_filter.nil?
            decode_options += ['-hwaccel_output_format', 'cuda']
            nvenc_gpu_only = true
            frame_rate_filter.sub!(/^yadif/, 'yadif_cuda') unless frame_rate_filter.nil?
          end

          if  decode_method == 'qsv' and
              overlay_filter.nil? and
              frame_rate_filter.nil? and
              crop_filter.nil? and
              scale_filter.nil?
            qsv_decoder = case video['codec_name']
            when 'av1'
              'av1_qsv'
            when 'h264'
              'h264_qsv'
            when 'hevc'
              'hevc_qsv'
            when 'mjpeg'
              'mjpeg_qsv'
            when 'mpeg2video'
              'mpeg2_qsv'
            when 'vc1'
              'vc1_qsv'
            when 'vp8'
              'vp8_qsv'
            when 'vp9'
              'vp9_qsv'
            else
              nil
            end

            decode_options += ['-qsv_device', @qsv_device] unless @qsv_device.nil?
            decode_options += ['-c:v', qsv_decoder] unless qsv_decoder.nil?
          end
        end
      end

      ten_bit = (@ten_bit ? (@eight_bit_vc1 ? (video['codec_name'] != 'vc1') : true) : false)
      pix_fmt = true

      if @encoder =~ /vaapi$/ and not decode_options.include?('-hwaccel')
        conversion_filter = 'format=nv12,hwupload'
      elsif nvenc_gpu_only
        conversion_filter = "scale_cuda=format=#{ten_bit ? 'p010le' : 'yuv420p'}"
        pix_fmt = false
      else
        conversion_filter = nil
      end

      encode_options = []

      if @encoder == 'copy'
        filter = ''
      else
        if video['codec_name'] == 'mpeg2video' and video['avg_frame_rate'] == '30000/1001'
          encode_options += ['-vsync', 'cfr']
        end

        filter =  overlay_filter.nil?     ? '' : overlay_filter
        filter += frame_rate_filter.nil?  ? '' : ",#{frame_rate_filter}"
        filter += crop_filter.nil?        ? '' : ",#{crop_filter}"
        filter += scale_filter.nil?       ? '' : ",#{scale_filter}"
        filter += conversion_filter.nil?  ? '' : ",#{conversion_filter}"
        filter.sub!(/^,/, '')
      end

      if overlay_filter.nil?
        encode_options += [
          '-map', "0:#{video['index']}"
        ]

        unless filter.empty?
          encode_options += [
            '-filter:v', filter
          ]
        end
      else
        encode_options += [
          '-filter_complex', "[0:#{video['index']}]#{filter}[v]",
          '-map', '[v]'
        ]
      end

      color_primaries = video['color_primaries']
      color_trc       = video['color_transfer']
      color_trc       = 'gamma22' if color_trc == 'bt470m'
      color_trc       = 'gamma28' if color_trc == 'bt470bg'
      colorspace      = video['color_space']

      if (video.fetch('pix_fmt', 'yuv420p') == 'yuv420p10le') and ten_bit
        color_primaries ||= 'bt2020'
        color_trc       ||= 'smpte2084'
        colorspace      ||= 'bt2020nc'
      end

      if width > 1920 or height > 1080
        level = '5.1'
        bitrate = @target_2160p
        max_bitrate = @hevc ? 25000 : 135000 # Level 5 HEVC Main 10 or H.264 Main
      elsif width > 1280 or height > 720
        level = '4'
        bitrate = @target_1080p
        max_bitrate = @hevc ? 12000 : 20000 # Level 4
      elsif width > 720 or height > 576
        level = '3.1'
        bitrate = @target_720p
        max_bitrate = @hevc ? 10000 : 14000 # Level 3.1
      else
        color_primaries ||= (width == 720 and height == 576 and video['codec_name'] == 'mpeg2video') ? 'bt470bg' : 'smpte170m'
        colorspace      ||= 'smpte170m'
        level = '3'
        bitrate = @target_480p
        max_bitrate = @hevc ? 6000 : 10000 # Level 3
      end

      color_primaries ||= 'bt709'
      color_trc       ||= 'bt709'
      colorspace      ||= 'bt709'
      bitrate = @target unless @target.nil?
      bitrate = [bitrate, max_bitrate].min

      if @encoder =~ /(nvenc|hevc_qsv|libx26[45])$/
        maxrate = [max_bitrate, bitrate * 2].max

        unless @maxrate.nil?
          maxrate = [[(@maxrate < bitrate ? bitrate * @maxrate : @maxrate).to_i, bitrate].max, maxrate].min
        end

        bufsize = @encoder == 'hevc_qsv' ? 0 : maxrate

        unless @bufsize.nil?
          bufsize = [[(@bufsize < bitrate ? bitrate * @bufsize : @bufsize).to_i, bitrate].max, maxrate].min
        end
      else
        maxrate = 0
        bufsize = 0
      end

      unless @preset.nil?
        valid = false

        case @encoder
        when /nvenc$/
          case @preset
          when 'fast', 'medium', 'slow', /^p[1-7]$/
            valid = true
          end
        when /qsv$/
          case @preset
          when 'veryfast', 'faster', 'fast', 'medium', 'slow', 'slower', 'veryslow'
            valid = true
          end
        when /^libx26[45]$/
          case @preset
          when 'ultrafast', 'superfast', 'veryfast', 'faster', 'fast', 'medium',
          'slow', 'slower', 'veryslow', 'placebo'
            valid = true
          end
        end

        fail "invalid preset for encoder: #{@preset}" unless valid
      end

      Kernel.warn 'Stream mapping:'
      text = "#{sprintf("%2d", video['index'])} = #{@encoder}"

      unless @encoder == 'copy'
        text += @nvenc_cq.nil? ? " / #{bitrate} Kbps" : " / #{@nvenc_cq} CQ"
        text += " / #{@preset}" unless @preset.nil?
      end

      unless burn_subtitle.nil?
        text += " / #{sprintf("%d", burn_subtitle['index'])} = #{burn_subtitle['codec_name']} / burn"
      end

      Kernel.warn text
      encode_options += ['-c:v', @encoder]
      encode_options += ['-pix_fmt:v', (@encoder =~ /(videotoolbox|nvenc|qsv)$/ ? 'p010le' : 'yuv420p10le')] if ten_bit and pix_fmt
      encode_options += (@nvenc_cq.nil? ? ['-b:v', "#{bitrate}k"] : ['-cq:v', @nvenc_cq]) unless @encoder == 'copy'
      encode_options += ['-maxrate:v', "#{maxrate}k"] if maxrate > 0
      encode_options += ['-bufsize:v', "#{bufsize}k"] if bufsize > 0
      encode_options += ['-preset:v', @preset] unless @preset.nil?

      if @encoder =~ /videotoolbox$/
        encode_options += ['-allow_sw:v', '1'] if @vt_allow_sw
        encode_options += ['-profile:v', 'main10'] if ten_bit
      end

      if @encoder =~ /nvenc$/
        encode_options += ['-spatial-aq:v', '1']                      if @nvenc_spatial_aq
        encode_options += ['-temporal-aq:v', '1']                     if @nvenc_temporal_aq
        encode_options += ['-rc-lookahead:v', @nvenc_lookahead.to_s]  unless @nvenc_lookahead.nil?
        encode_options += ['-multipass:v', @nvenc_multipass]          unless @nvenc_multipass.nil?
        encode_options += ['-refs:v', @nvenc_refs.to_s]               unless @nvenc_refs.nil?
        encode_options += ['-bf:v', @nvenc_bframes.to_s]              unless @nvenc_bframes.nil?
        encode_options += ['-b_ref_mode:v', @nvenc_bframe_refs]       unless @nvenc_bframe_refs.nil?
      end

      if @encoder =~ /qsv$/
        encode_options += ['-look_ahead:v', '1']        if @encoder == 'h264_qsv'
        encode_options += ['-refs:v', @qsv_refs.to_s]   unless @qsv_refs.nil?
        encode_options += ['-bf:v', @qsv_bframes.to_s]  unless @qsv_bframes.nil?
        encode_options += ['-load_plugin:v', 'hevc_hw'] if @encoder == 'hevc_qsv'
      end

      if @encoder =~ /amf$/
        encode_options += ['-rc:v', 'vbr_latency']
        encode_options += ['-quality:v', @amf_quality]  unless @amf_quality.nil?
        encode_options += ['-enable_vbaq:v', '1']       if @amf_vbaq
        encode_options += ['-preanalysis:v', '1']       if @amf_pre_analysis
        encode_options += ['-refs:v', @amf_refs.to_s]   unless @amf_refs.nil?
        encode_options += ['-bf:v', @amf_bframes.to_s]  unless @amf_bframes.nil?
      end

      if @encoder =~ /vaapi$/
        encode_options += ['-compression_level:v', @vaapi_compression.to_s] unless @vaapi_compression.nil?
      end

      if @encoder == 'libx264'
        encode_options += ['-x264opts:v', 'ratetol=inf'] if @x264_avbr
        encode_options += ['-mbtree:v', '0'] unless @x264_mbtree

        if @preset.nil?
          if @x264_quick
            encode_options += [
              '-refs:v', '1',
              '-rc-lookahead:v', '30',
              '-partitions:v', 'none'
            ]
          end
        else
          case @preset
          when 'slow', 'slower', 'veryslow', 'placebo'
            encode_options += ['-level:v', level]
          end
        end

        encode_options += ['-x264-params:v', @x264_params] unless @x264_params.nil?
      end

      if @encoder == 'libx265'
        encode_options += ['-x265-params:v', @x265_params] unless @x265_params.nil?
      end

      unless ten_bit
        encode_options += ['-profile:v', 'high'] if @encoder =~ /^(h264_nvenc|h264_amf|libx264)$/
      end

      unless @encoder == 'copy'
        encode_options += [
          '-color_primaries:v', color_primaries,
          '-color_trc:v', color_trc,
          '-colorspace:v', colorspace
        ]
      end

      encode_options += [
        '-metadata:s:v', 'title=',
        '-disposition:v', 'default'
      ]

      encode_options += ['-tag:v', 'hvc1'] if @format == :mp4 and @hevc

      [decode_options, encode_options]
    end

    def get_audio_options(media_info)
      audio_track = 0
      main_audio = nil

      media_info['streams'].each do |stream|
        next if stream['codec_type'] != 'audio'

        audio_track += 1

        if audio_track == @audio_selections[0][:track]
          main_audio = stream
          break
        end
      end

      return ['-an'] if main_audio.nil?

      width = @audio_selections[0][:width]

      audio_tracks = [{
        :stream => main_audio,
        :width => width
      }]

      titles = {}
      index = 0

      @audio_selections.each do |selection|
        if index == 0
          index += 1
          next
        end

        width = selection[:width]

        unless selection[:track].nil?
          audio_track = 0

          media_info['streams'].each do |stream|
            next if stream['codec_type'] != 'audio'

            audio_track += 1

            if audio_track == selection[:track]
              audio_tracks += [{
                :stream => stream,
                :width => width
              }]

              break
            end
          end
        end

        unless selection[:language].nil?
          media_info['streams'].each do |stream|
            next if stream['codec_type'] != 'audio'

            if (selection[:language] == 'all' or
                stream.fetch('tags', {}).fetch('language', '') == selection[:language]) and
                stream['index'] != main_audio['index']
              audio_tracks += [{
                :stream => stream,
                :width => width
              }]
            end
          end
        end

        unless selection[:title].nil?
          media_info['streams'].each do |stream|
            next if stream['codec_type'] != 'audio'

            title = stream.fetch('tags', {}).fetch('title', '')

            if title =~ /#{selection[:title]}/i and stream['index'] != main_audio['index']
              audio_tracks += [{
                :stream => stream,
                :width => width
              }]

              titles[stream['index']] = title
            end
          end
        end

        index += 1
      end

      audio_tracks.uniq!
      options = []
      configurations = {}
      index = 0

      audio_tracks.each do |track|
        codec_name = track[:stream]['codec_name']
        input_channels = track[:stream]['channels'].to_i
        encoder = nil
        bitrate = nil
        channels = nil

        if track[:width] == :original
            encoder = 'copy'
        else
          input_bitrate = track[:stream].fetch('bit_rate', '256').to_i / 1000
          dts = (codec_name == 'dts' and track[:stream].fetch('profile', 'DTS') =~ /^DTS(?:-ES)?$/)

          if track[:width] == :surround
            if  (@surround_encoder =~ /aac/ and codec_name == 'aac') or
                (@surround_encoder =~ /ac3$/ and
                (codec_name == @surround_encoder or codec_name == 'ac3') and
                (@keep_ac3_surround or input_bitrate <= (@surround_bitrate.nil? ? 640 : @surround_bitrate))) or
                (@pass_dts and dts)
              encoder = 'copy'
            elsif input_channels > 2
              encoder = @surround_encoder
              bitrate = @surround_bitrate

              if encoder =~ /aac/
                encoder = @aac_fallback_encoder if encoder == 'aac_at'
                channels = 6
              elsif input_channels > 6
                channels = 6
              end
            end
          end

          if encoder.nil?
            if  input_channels <= 2 and (codec_name == 'aac' or
                (@surround_encoder =~ /ac3$/ and
                (codec_name == @surround_encoder or codec_name == 'ac3') and
                (@keep_ac3_stereo or input_bitrate <= (@stereo_bitrate.nil? ? 256 : @stereo_bitrate))) or
                (@pass_dts and dts))
              encoder = 'copy'
            else
              encoder = @stereo_encoder
              bitrate = @stereo_bitrate

              if input_channels > 2
                channels = 2
              elsif input_channels == 1
                bitrate = @mono_bitrate
              end
            end
          end
        end

        input_index = track[:stream]['index']

        configuration = {
          :encoder => encoder,
          :bitrate => bitrate,
          :channels => channels
        }

        next if configurations[input_index] == configuration

        configurations[input_index] = configuration

        if encoder == 'libfdk_aac' and not @fdk_vbr_mode.nil?
          bitrate = nil
          fdk_vbr_mode = @fdk_vbr_mode
        else
          fdk_vbr_mode = nil
        end

        text = "#{sprintf("%2d", input_index)} = #{encoder}"
        text += " / #{bitrate} Kbps" unless bitrate.nil?
        text += " / VBR mode #{fdk_vbr_mode}" unless fdk_vbr_mode.nil?
        text += ' / stereo' unless channels.nil? or channels > 2
        text += " / #{titles[input_index]}" if titles.has_key?(input_index)
        Kernel.warn text
        copy_track_name = (@copy_track_names or titles.has_key?(input_index))

        options += [
          '-map', "0:#{input_index}",
          "-c:a:#{index}", encoder,
          *(encoder == 'aac_at' ? ["-aac_at_mode:a:#{index}", 'cvbr'] : []),
          *(bitrate.nil? ? [] : ["-b:a:#{index}", "#{bitrate}k"]),
          *(fdk_vbr_mode.nil? ? [] : ["-vbr:a:#{index}", fdk_vbr_mode]),
          *(channels.nil? ? [] : ["-ac:a:#{index}", "#{channels}"]),
          *((encoder != 'copy' and track[:stream]['sample_rate'] != '48000') ? ["-ar:a:#{index}", '48000'] : []),
          *(copy_track_name ? [] : ["-metadata:s:a:#{index}", 'title=']),
          "-disposition:a:#{index}", (index == 0 ? 'default' : '0')
        ]

        index += 1
      end

      options
    end

    def get_subtitle_options(media_info, burn_subtitle)
      return ['-sn'] if @subtitle_selections.empty?

      force_subtitle = nil

      if @auto_add_subtitle
        media_info['streams'].each do |stream|
          next if stream['codec_type'] != 'subtitle'

          if stream['disposition']['forced'] == 1
            force_subtitle = stream
            break
          end
        end
      end

      subtitles = []

      @subtitle_selections.each do |selection|
        unless selection[:track].nil?
          track = 0

          media_info['streams'].each do |stream|
            next if stream['codec_type'] != 'subtitle'

            track += 1

            if track == selection[:track]
              if selection[:forced] and force_subtitle.nil?
                force_subtitle = stream
              else
                subtitles += [stream]
              end

              break
            end
          end
        end

        unless selection[:language].nil?
          media_info['streams'].each do |stream|
            next if stream['codec_type'] != 'subtitle'

            if (selection[:language] == 'all' or
                stream.fetch('tags', {}).fetch('language', '') == selection[:language])
              subtitles += [stream]
            end
          end
        end

        unless selection[:title].nil?
          media_info['streams'].each do |stream|
            next if stream['codec_type'] != 'subtitle'

            if stream.fetch('tags', {}).fetch('title', '') =~ /#{selection[:title]}/i
              subtitles += [stream]
            end
          end
        end
      end

      subtitles = [force_subtitle] + subtitles unless force_subtitle.nil?
      subtitles.uniq!
      options = []
      index = 0

      subtitles.each do |subtitle|
        next if (not burn_subtitle.nil?) and burn_subtitle['index'] == subtitle['index']

        force = (index == 0 and not force_subtitle.nil?)
        text = "#{sprintf("%2d", subtitle['index'])} = #{subtitle['codec_name']}"
        text += ' / force' if force
        title = subtitle.fetch('tags', {}).fetch('title', '')
        text += " / #{title}" unless title.empty?
        Kernel.warn text

        options += [
          '-map', "0:#{subtitle['index']}",
          "-c:s:#{index}", ((@format == :mp4 and subtitle['codec_name'] == 'subrip') ? 'mov_text' : 'copy'),
          "-disposition:s:#{index}", (force ? 'default+forced' : '0')
        ]

        index += 1
      end

      return ['-sn'] if options.empty?

      options
    end

    def add_track_statistics_tags(output_path)
      Kernel.warn 'Adding track statistics...'

      begin
        IO.popen(['mkvpropedit', output_path, '--add-track-statistics-tags'], 'rb') do |io|
          Signal.trap 'INT' do
            Process.kill 'INT', io.pid
          end

          io.each_char do |char|
            STDERR.print char
          end
        end
      rescue SystemCallError => e
        raise "adding track statistics tags failed: #{e}"
      end

      fail "adding track statistics tags failed: #{output_path}" unless $CHILD_STATUS.exitstatus == 0
    end

    def add_hdr_info(path, output_path)
      hdr_info = ''

      IO.popen([
        'ffprobe',
        '-loglevel', 'quiet',
        '-select_streams', 'v:0',
        '-show_frames',
        '-read_intervals', '%+#1',
        '-show_entries', 'frame=side_data_list',
        '-print_format', 'json',
        path
      ]) do |io|
        hdr_info = io.read
      end

      fail "scanning media failed: #{path}" unless $CHILD_STATUS.exitstatus == 0

      begin
        hdr_info = JSON.parse(hdr_info)
      rescue JSON::JSONError
        fail "media information not found: #{path}"
      end

      md = nil
      cll = nil

      hdr_info['frames'].each do |frame|
        frame.fetch('side_data_list', []).each do |side_data|
          if side_data['side_data_type'] == 'Mastering display metadata'
            md = side_data if md.nil?
          elsif side_data['side_data_type'] == 'Content light level metadata'
            cll = side_data if cll.nil?
          end
        end
      end

      return if md.nil? or cll.nil?

      Kernel.warn 'Adding HDR information...'

      begin
        IO.popen([
          'mkvpropedit',
          output_path,
          '--edit', 'track:v1',
          '--set', "max-content-light=#{cll['max_content']}",
          '--set', "max-frame-light=#{cll['max_average']}",
          '--set', "chromaticity-coordinates-red-x=#{eval md['red_x'] + '.0'}",
          '--set', "chromaticity-coordinates-red-y=#{eval md['red_y'] + '.0'}",
          '--set', "chromaticity-coordinates-green-x=#{eval md['green_x'] + '.0'}",
          '--set', "chromaticity-coordinates-green-y=#{eval md['green_y'] + '.0'}",
          '--set', "chromaticity-coordinates-blue-x=#{eval md['blue_x'] + '.0'}",
          '--set', "chromaticity-coordinates-blue-y=#{eval md['blue_y'] + '.0'}",
          '--set', "white-coordinates-x=#{eval md['white_point_x'] + '.0'}",
          '--set', "white-coordinates-y=#{eval md['white_point_y'] + '.0'}",
          '--set', "max-luminance=#{eval md['max_luminance'] + '.0'}",
          '--set', "min-luminance=#{eval md['min_luminance'] + '.0'}"
        ], 'rb') do |io|
          Signal.trap 'INT' do
            Process.kill 'INT', io.pid
          end

          io.each_char do |char|
            STDERR.print char
          end
        end
      rescue SystemCallError => e
        raise "adding HDR information failed: #{e}"
      end

      fail "adding HDR information failed: #{output_path}" unless $CHILD_STATUS.exitstatus == 0
    end
  end
end

Transcoding::Command.new.run
