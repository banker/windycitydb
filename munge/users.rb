require 'mongo'
require 'json'

c = Mongo::Connection.new
db = c['windy']
users = db['users']

f = File.open("users.json").read
js = JSON.parse(f)

js['users'].each do |user|
  users.save(user)
end
