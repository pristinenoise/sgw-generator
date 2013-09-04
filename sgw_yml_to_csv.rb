require "rubygems"
require "yaml"

all_the_names = YAML.load_file("all_the_names.yml")
File.open("all_the_names.csv", "w") do |file|
  all_the_names.each do |user|
    file.write("#{user[:username]},#{user[:email]},#{user[:first_visit]}\n")

  end
end
