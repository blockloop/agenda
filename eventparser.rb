module Bmjones

	class EventParser
		@@subclasses = []

		def self.inherited(subclass)
			@@subclasses.push subclass
    end

    def self.children
    	@@subclasses
    end
	end

end