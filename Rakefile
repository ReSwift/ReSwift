task :bundle do
  raise("Bundler error") unless sh %Q{bundle check || bundle install}
end

desc "Generate documentation with jazzy"
task :docs => [:bundle] do
  sh %Q{jazzy}
end
