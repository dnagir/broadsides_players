require "rake/testtask"

desc "Default task:  run all tests"
task :default => :test

Rake::TestTask.new do |test|
  test.libs    << "test"
  test.pattern =  "test/**/*_test.rb"
  test.warning =  true
  test.verbose =  true
end

