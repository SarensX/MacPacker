Pod::Spec.new do |s|

  s.name         = "BitByteData"
  s.version      = "2.0.3"
  s.summary      = "Read and write bits and bytes in Swift."

  s.description  = "A Swift framework with classes for reading and writing bits and bytes."

  s.homepage     = "https://github.com/tsolomko/BitByteData"
  s.documentation_url = "http://tsolomko.github.io/BitByteData"

  s.license      = { :type => "MIT", :file => "LICENSE" }

  s.author       = { "Timofey Solomko" => "tsolomko@gmail.com" }

  s.source       = { :git => "https://github.com/tsolomko/BitByteData.git", :tag => "#{s.version}" }

  s.ios.deployment_target = "11.0"
  s.osx.deployment_target = "10.13"
  s.tvos.deployment_target = "11.0"
  s.watchos.deployment_target = "4.0"

  s.swift_versions = ["5"]

  s.source_files = "Sources/*.swift"

end
