module Subit
  module Matchers
    class Parse
      def initialize(from, to, names = [])
        @from, @to, @names = from, to, Array(names)
      end
    
      def matches?(parser)
        @result = parser.parse(@from, *@names)
        @result == @to
      end

      def description
        "parse: '#{@from}' to: '#{@to}' #{using_names}"
      end

      def failure_message
        " expected '#{@from}' to parse as '#{@to}' #{using_names}, but it parsed as '#{@result}'"
      end

      def negative_failure_message
        " expected '#{@from}' not to parse as '#{@to}' #{using_names}, but it did"
      end
    
      def using_names
        "(using #{@names.any? ? @names.join(',') : 'no rules'})"
      end
    end

    def parse(original, options = {})
      Parse.new(original, options[:to], options[:using] || options[:with] || options[:names] || [])
    end
  end
end