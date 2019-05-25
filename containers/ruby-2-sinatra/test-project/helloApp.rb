require 'sinatra'

# set :bind, "0.0.0.0"    # used -o arg in .vscode/launch.json

# ===== Routes =====

get '/' do
  'Hello from Sinatra!'
end

# ===== Instructive information =====

port = Sinatra::Application.settings.port
puts "===== Instructive information ====="
puts "Try http://localhost:#{port}/ in the browser!"
puts