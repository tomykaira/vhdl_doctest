require 'vhdl_doctest/types/std_logic'
require 'vhdl_doctest/types/std_logic_vector'

module VhdlDoctest
  module Types
    def self.parse(str)
      Types.constants.each do |c|
        klass = const_get("#{c}")
        next unless klass.respond_to?(:parse)
        if result = klass.parse(str)
          return result
        end
      end
      raise "Type for #{str} is not found."
    end
  end
end
