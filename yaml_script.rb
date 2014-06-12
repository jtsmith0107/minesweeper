require 'yaml'

a = {"Bob" => 10}.to_yaml

File.open('leaderboard.save', 'w') do |f|
  f.puts a
end