require_relative './config/environment'
require 'sinatra/activerecord/rake'

desc 'Start our app console'
task :console do
    Pry.start
    ActiveRecord::Base.logger = Logger.new(STDOUT)
end

desc 'run the app'
task :run do
    cli = CLI.new
    cli.run
end
