module Kommand
  module Scripts
    class Argument
      attr_reader :value, :valid, :summary

      def value=(val)
        raise "Invalid value for `#{key}` argument: '#{val}'" if (!@valid.nil? && !@valid.include?(val)) && (!val.nil? && !val.empty?)
        @value = val
      end

      def key
        if unnamed?
          value
        else
          @keys.is_a?(Array) ? @keys[0] : @keys
        end
      end

      def keys
        if unnamed?
          [value]
        else
          @keys.is_a?(Array) ? @keys : [@keys]
        end
      end

      def name
        keys.sort { |a,b| a.length <=> b.length }.last.gsub(/^--/, '')
      end

      # is this an unnamed argument?
      def unnamed?
        @keys == nil
      end

      # is this argument valid?
      def valid?
        !((validate? && !@valid.include?(val)) && (!val.nil? && !val.empty?))
      end

      # should this argument validate?
      def validate?
        !@valid.nil?
      end

      protected

      def initialize(keys, *args)
        @keys = (keys.is_a?(String) && keys.match(/,?\s/) ? keys.gsub(/,?\s+/, " ").split(" ") : keys)
        
        val = args.slice!(0) if %w(String Symbol Integer).include?(args[0].class.name)

        if args.length > 0 && args[0].is_a?(Hash)
          opts = args.slice!(0)
          @valid = (opts[:valid].is_a?(Array) ? opts[:valid].map(&:to_s) : [opts[:valid].to_s]) if opts.has_key?(:valid)
          @summary = opts[:summary] if opts.has_key?(:summary)
        end
        
        self.value = val
      end
    end
  end
end
