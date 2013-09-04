require "rubygems"
require "mechanize"
require "yaml"

credentials = YAML.load_file("credentials.yml")
username = credentials["sgw_login"]["username"]
password = credentials["sgw_login"]["password"]


starting_url = "http://story-games.com/forums/entry/signin?Target=discussions"

agent = Mechanize.new()

page = agent.get(starting_url)

page.form_with(:action => "/forums/entry/signin") do |f|
  f["Form/Email"] = username
  f["Form/Password"] = password 
end.submit

names = []

pn = 1
while
  page = agent.get("http://story-games.com/forums/dashboard/user?Page=p#{pn}")
  rows = page.search("table#Users tr")
  found_row = false
  if rows
    page.search("table#Users tbody tr").each do |row|
      cells =  row.search("td").children
      if cells && cells.length > 0
        user = {}
        user[:username] = cells[0].text
        user[:email] = cells[1].inner_html.to_s.gsub("<strong>at</strong>", "@").gsub("<em>dot</em>", ".")
        user[:first_visit] = cells[5].text
        found_row = true
        unless user[:email].include?("support") && user[:email].include?("microsoft.com")
          names << user
        end
      end
    end
  end

  pn += 1
  break unless found_row
end


File.write('./all_the_names.yml', names.to_yaml)
