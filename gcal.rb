require 'httparty'
require 'nokogiri'
require 'open-uri'
require 'ostruct'
require 'ssl_certifier'
require_relative './config.rb'
require_relative './eventparser.rb'

module Bmjones

	class	Gcal < EventParser
		def self.get_events date=DateTime.now
			doc = Nokogiri::XML open(CONFIG.gcal_url)
			doc.css('entry').map do |entry|
				result = OpenStruct.new
				text = entry.css('summary').text
				search_date = date.strftime("%a %b %d, %Y") #=> "Mon Nov 11, 2013"
				next unless text =~ Regexp.new(search_date)
				result.date = Date.strptime(text.match(search_date)[0], '%a %b %d, %Y')
				from_to = text.gsub(/\b\d+[ap]m\b/).to_a rescue [] #=> ["9pm", "10pm"]
				result.start_time = Time.strptime(from_to[0], '%I%p')
				result.end_time = Time.strptime(from_to[1], '%I%p')
				result.title = entry.css('title').text.strip
				result
			end - [nil,'']
		end
	end

end