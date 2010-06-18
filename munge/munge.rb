require 'rubygems'
require 'mongo'
c = Mongo::Connection.new

db = c['windy']

posts = db['posts']

comments = db['comments']
answers = db['answers']

# Make posts into first class documents
posts.find_one["posts"].each do |post|
  posts.save(post)
end

# Push answers onto posts
answers.find_one['answers'].each do |answer|
  id = answer.delete("ParentId")
  posts.update({"Id" => id}, {"$push" => {"answers" => answer}})
end

# Push comments onto posts
comments.find_one['comments'].each do |comment|
  id = comment["PostId"]
  posts.update({"Id" => id}, {"$push" => {"comments" => comment}})
end

# Push comments onto answers (now embedded in posts)
comments.find_one['comments'].each do |comment|
  posts.update({"answers" => {"$elemMatch" => {"Id" => comment['PostId']}}},
    {"$push" => {"answers.$.comments" => comment}})
end

