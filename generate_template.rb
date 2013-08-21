require "rubygems"
require "bundler/setup"

require "google_drive"
require "yaml"
require "erb"

credentials = YAML.load_file("credentials.yml")

username = credentials["google_login"]["username"]
password = credentials["google_login"]["password"]

session = GoogleDrive.login(username, password)

ws = session.spreadsheet_by_key("0Ahv3gKBkfcOCdG53QnZXR1NOa3BGSGZWSmlDN3FhbWc").worksheets[0]

data = Hash.new { |h,k| h[k] = {} }


(2..100).each do |row|
  section, element, title, value, url, subtext = (1..6).collect { |col| ws[row,col].to_s.strip }

  unless section.empty?
    if element.empty?
      data[section] = value
    elsif element == "item"
      data[section]['items'] ||= []
      data[section]['items'] << {title: title, value: value, url: url, subtext: subtext}
    else
      data[section][element] = value
    end
  end
end


sections = ["New Games", "News", "Game Design", "Crowdfunding", "Conventions"]

template = ERB.new(File.read("mailchimp_template.html.erb"), nil, "-")

File.open("mailchimp_result.html", "w") { |f| f.puts(template.result) }

