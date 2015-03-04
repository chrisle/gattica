module Gattica

  # Common output methods that are sharable

  module Convertible

    # Output as hash
    def to_h
      output = {}
      instance_variables.each do |var|
        output.merge!({ var[1..-1] => instance_variable_get(var) }) unless var == '@xml'    # exclude the whole XML dump
      end
      output.tap { |h| h.include? HashExtensions }
    end

    # Output nice inspect syntax
    def to_s
      to_h.inspect
    end

    alias inspect to_s

    def to_query
      to_h.to_query
    end

    # Return the raw XML (if the object has a @xml instance variable, otherwise convert the object itself to xml)
    def to_xml
      if @xml
        @xml
      else
        self.to_xml
      end
    end

    alias to_yml to_yaml

  end
end