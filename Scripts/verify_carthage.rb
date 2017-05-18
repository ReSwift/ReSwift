# Original Source: Moya Rakefile
# https://github.com/Moya/Moya/blob/master/Rakefile
# Thanks a lot!

Dir.mkdir("carthage_test")
File.write(File.join("carthage_test", "Cartfile"), "git \"file://#{Dir.pwd}\"")
Dir.chdir "carthage_test" do
  system "carthage bootstrap --platform 'iOS'"
  has_artifacts = Dir.glob("Carthage/Builds/*").count > 0
  raise("Carthage did not succeed") unless has_artifacts
end
