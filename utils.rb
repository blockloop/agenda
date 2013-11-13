module Bmjones

	class Utils
		def self.quietly(&block)
			original_stdout = $stdout
			$stdout = StringIO.new
			begin
				yield
			ensure
				$stdout = original_stdout
			end
		end


		def self.is_windows
			(RbConfig::CONFIG['host_os'] =~ /mswin|mingw|cygwin/)
		end
	end

end