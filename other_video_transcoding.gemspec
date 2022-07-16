Gem::Specification.new do |s|
  s.name                  = 'other_video_transcoding'
  s.version               = '0.11.0'
  s.required_ruby_version = '>= 2.0'
  s.summary               = 'Other tools to transcode videos.'
  s.description           = <<-HERE
    Other Video Transcoding is a package of tools to transcode videos.
  HERE
  s.license               = 'MIT'
  s.author                = 'Don Melton'
  s.email                 = 'don@blivet.com'
  s.homepage              = 'https://github.com/donmelton/other_video_transcoding'
  s.files                 = Dir['bin/*'] + Dir['[A-Z]*'] + ['other_video_transcoding.gemspec']
  s.executables           = ['ask-ffmpeg-log', 'other-transcode']
  s.extra_rdoc_files      = ['LICENSE', 'README.md']
end
