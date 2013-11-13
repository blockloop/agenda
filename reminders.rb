require 'ssl_certifier'
require 'ostruct'
require 'icloud'
require_relative './config.rb'
require_relative './eventparser.rb'

module Bmjones

	class Reminders < EventParser
		def self.get_events date=DateTime.now
			session = ::ICloud::Session.new(CONFIG.icloud.email, CONFIG.icloud.password)
			session.reminders
			raw = session.reminders.find_all do |r|
			  next if r.complete?
				year = r.due_date[1] rescue nil
				month = r.due_date[2] rescue nil
				day = r.due_date[3] rescue nil
				date.day == day and date.month == month and date.year == year
			end

			raw.map do |e|
				result = OpenStruct.new
				result.date = Date.strptime(e.due_date[0].to_s, '%Y%m%d')
				raw_start_time = e.due_date[4]
				result.start_time = Time.strptime("#{raw_start_time}", '%H')
				result.title = e.title
				result
			end
		end
	end

end