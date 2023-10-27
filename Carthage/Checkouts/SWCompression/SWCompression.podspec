Pod::Spec.new do |s|

  s.name         = "SWCompression"
  s.version      = "4.8.5"
  s.summary      = "A framework with functions for working with compression, archives and containers."

  s.description  = "A framework with (de)compression algorithms and functions for processing various archives and containers."

  s.homepage     = "https://github.com/tsolomko/SWCompression"
  s.documentation_url = "http://tsolomko.github.io/SWCompression"

  s.license      = { :type => "MIT", :file => "LICENSE" }

  s.author       = { "Timofey Solomko" => "tsolomko@gmail.com" }

  s.source       = { :git => "https://github.com/tsolomko/SWCompression.git", :tag => "#{s.version}" }

  s.ios.deployment_target = "11.0"
  s.osx.deployment_target = "10.13"
  s.tvos.deployment_target = "11.0"
  s.watchos.deployment_target = "4.0"

  s.swift_versions = ["5"]

  s.dependency "BitByteData", "~> 2.0"

  s.subspec "Deflate" do |sp|
    sp.source_files = "Sources/{Deflate/*,Common/*,Common/CodingTree/*}.swift"
    sp.pod_target_xcconfig = { "OTHER_SWIFT_FLAGS" => "-DSWCOMPRESSION_POD_DEFLATE" }
  end

  s.subspec "GZip" do |sp|
    sp.dependency "SWCompression/Deflate"
    sp.source_files = "Sources/{GZip/*,Common/*}.swift"
  end

  s.subspec "Zlib" do |sp|
    sp.dependency "SWCompression/Deflate"
    sp.source_files = "Sources/{Zlib/*,Common/*}.swift"
  end

  s.subspec "BZip2" do |sp|
    sp.source_files = "Sources/{BZip2/*,Common/*,Common/CodingTree/*}.swift"
    sp.pod_target_xcconfig = { "OTHER_SWIFT_FLAGS" => "-DSWCOMPRESSION_POD_BZ2" }
  end

  s.subspec "LZMA" do |sp|
    sp.source_files = "Sources/{LZMA/*,Common/*}.swift"
    sp.pod_target_xcconfig = { "OTHER_SWIFT_FLAGS" => "-DSWCOMPRESSION_POD_LZMA" }
  end

  s.subspec "LZMA2" do |sp|
    sp.dependency "SWCompression/LZMA"
    sp.source_files = "Sources/{LZMA2/*,Common/*}.swift"
  end

  s.subspec "LZ4" do |sp|
    sp.source_files = "Sources/{LZ4/*,Common/*}.swift"
    sp.pod_target_xcconfig = { "OTHER_SWIFT_FLAGS" => "-DSWCOMPRESSION_POD_LZ4" }
  end

  s.subspec "XZ" do |sp|
    sp.dependency "SWCompression/LZMA2"
    sp.source_files = "Sources/{XZ/*,Common/*}.swift"
  end

  s.subspec "ZIP" do |sp|
    sp.dependency "SWCompression/Deflate"
    sp.source_files = "Sources/{Zip/*,Common/*,Common/Container/*}.swift"
    sp.pod_target_xcconfig = { "OTHER_SWIFT_FLAGS" => "-DSWCOMPRESSION_POD_ZIP" }
  end

  s.subspec "TAR" do |sp|
    sp.source_files = "Sources/{TAR/*,Common/*,Common/Container/*}.swift"
  end

  s.subspec "SevenZip" do |sp|
    sp.dependency "SWCompression/LZMA2"
    sp.source_files = "Sources/{7-Zip/*,Common/*,Common/Container/*}.swift"
    sp.pod_target_xcconfig = { "OTHER_SWIFT_FLAGS" => "-DSWCOMPRESSION_POD_SEVENZIP" }
  end

end
