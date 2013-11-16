#!/usr/bin/env ruby

require 'openssl'
require 'thor'
require_relative './utils.rb'
require_relative './reminders.rb'
require_relative './gcal.rb'
require_relative './exchange.rb'

if Bmjones::Utils.is_windows # windows sucks and doesn't auth icloud properly
	Bmjones::Utils.quietly do
		::OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE
	end
end

module Bmjones
	class Agenda < Thor
		class_option :date, :aliases => "-d", :desc => "Specify a date to check", :default => DateTime.now.strftime("%Y-%m-%d")

		desc 'print', 'Pretty prints the agenda for the day given (default today)'
		def print
			if events.none?
				puts "No events for #{options[:date]}"
				exit 0
			end

			require 'awesome_print'
			events.each do |item|
				ap item.marshal_dump
			end
		end

		desc 'pushover', 'Sends the formatted data to pushover'
		def pushover
			if events.none?
				puts "No events for #{options[:date]}"
				exit 0
			end

			require "net/https"
			formatted_message = events.map.with_index do |item,index|
				msg = "#{index+1}. #{item.title}"
				msg += ": #{item.start_time.strftime('%I:%M%p')}" if item.start_time
				msg += " - #{item.end_time.strftime('%I:%M%p')}" if item.end_time
				msg
			end.join('. ')

			url = URI.parse("https://api.pushover.net/1/messages")
			req = Net::HTTP::Post.new(url.path)
			req.set_form_data({
				:token => ENV['PUSHOVER_TOKEN'] || CONFIG.pushover.token,
				:user => ENV['PUSHOVER_USER'] || CONFIG.pushover.user,
				:message => formatted_message,
				:title => "Agenda for #{options[:date]}"
				})
			res = Net::HTTP.new(url.host, url.port)
			res.use_ssl = true
			res.verify_mode = OpenSSL::SSL::VERIFY_PEER
			res.start { |http| http.request(req) }
		end

		desc "gmail", "Sends the formatted data to Gmail"
		def gmail
			if events.none?
				puts "No events for #{options[:date]}"
				exit 0
			end
			require 'gmail'

			formatted_message = events.map do |item|
				msg = "<li> <b>#{item.title}</b>"
				msg += ": #{item.start_time.strftime('%I:%M%p')}" if item.start_time
				msg += " - #{item.end_time.strftime('%I:%M%p')}" if item.end_time
				msg += "</li>"
				msg
			end.join()

			formatted_message = "<ul> #{formatted_message} </ul>"
			title = "Agenda for #{options[:date]}"

			Gmail.new(CONFIG.gmail.email, CONFIG.gmail.password) do |gmail|
				resp = gmail.deliver do
					to CONFIG.gmail.email
					subject title
					html_part do
						body formatted_message
					end
				end
			end
		end


		no_tasks do
			def events
				@events ||= EventParser.children.flat_map { |item| item.get_events(run_date) }.sort_by(&:start_time)
			end

			def startup
				if events.none?
					puts "No events for #{options[:date]}"
				end
			end

			def run_date
				DateTime.strptime(options[:date], '%Y-%m-%d')
			end
		end

		# default_task :print
	end

end

if __FILE__ == $0
	Bmjones::Agenda.start
end
