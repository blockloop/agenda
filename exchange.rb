require 'kconv'
require 'viewpoint'
require 'ostruct'
require_relative './eventparser.rb'
require_relative './config.rb'

module Bmjones
	class Exchange < EventParser
		def self.get_events date=DateTime.now
			Viewpoint::EWS::EWS.endpoint = CONFIG.exchange.endpoint
			Viewpoint::EWS::EWS.set_auth CONFIG.exchange.username, CONFIG.exchange.password
			Viewpoint::EWS::CalendarFolder.find_folders.flat_map{ |folder|
				folder.items_between(date-1, date)
			}.map{ |item|
				result = OpenStruct.new
				result.title = item.subject
				result.date = item.start.to_date
				result.start_time = item.start.to_time
				result.end_time = item.end.to_time
				result
			}
		end
	end
end
