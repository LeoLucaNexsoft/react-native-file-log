
Pod::Spec.new do |s|
  s.name         = "RNReactLogging"
  s.version      = "1.0.0"
  s.summary      = "RNReactLogging"
  s.description  = <<-DESC
                  RNReactLogging
                   DESC
  s.homepage     = "https://github.com/LeoLucaNexsoft/react-native-file-log"
  s.license      = "MIT"
  # s.license      = { :type => "MIT", :file => "FILE_LICENSE" }
  s.author             = { "author" => "author@domain.cn" }
  s.platform     = :ios, "7.0"
  s.source       = { :git => "https://github.com/author/RNReactLogging.git", :tag => "master" }
  s.source_files  = "RNReactLogging/**/*.{h,m}"
  s.requires_arc = true


  s.dependency "React"
  #s.dependency "others"

end

  
