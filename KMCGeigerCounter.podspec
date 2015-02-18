Pod::Spec.new do |s|
  s.name             = "KMCGeigerCounter"
  s.version          = "0.2.1"
  s.summary          = "A framerate meter that clicks when animation drops frames"
  s.homepage         = "https://github.com/kconner/KMCGeigerCounter"
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { "Kevin Conner" => "connerk@gmail.com" }
  s.social_media_url = "http://twitter.com/connerk"
  s.platform         = :ios, '7.0'
  s.source           = { :git => "https://github.com/kconner/KMCGeigerCounter.git", :tag => s.version.to_s }
  s.requires_arc     = true
  s.source_files     = "KMCGeigerCounter/*.{h,m}"
  s.resources        = "KMCGeigerCounter/*.aiff"
end
