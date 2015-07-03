# TODO implement OptionParser
module Kommand
  module Scripts
    module Script
      def self.included(base)
        base.send :extend, ClassMethods
        base.send :include, InstanceMethods
      end

      module ClassMethods
        def run
          @script ||= new
          raise "You must define a `run` method for your script." unless @script.respond_to?(:run)
          @script.run
        end

        def validate_arguments(val=nil)
          @validate_arguments = val
        end

        def validate_arguments?
          @validate_arguments = true if @validate_arguments.nil?
          @validate_arguments
        end

        def valid_argument(arg)
          @valid_args ||= Arguments.new
          @valid_args << begin
            if arg.is_a?(Argument)
              arg
            elsif arg.is_a?(Hash)
              Argument.new(arg.keys.first.to_s, arg.values.first)
            elsif arg.is_a?(Array)
              Argument.new(arg[0].to_s, (arg.length > 1 ? arg[1] : []))
            else
              Argument.new(arg.to_s)
            end
          end
          @valid_args.last
        end

        def valid_arguments(*args)
          @valid_args ||= Arguments.new
          return @valid_args if args.empty?
          
          args.each { |arg| valid_argument(arg) }
          @valid_args
        end
        
        def arguments(*args)
          add_arguments(*args)
        end

        def user_arguments
          arguments
        end

        # reset arguments to the provided args
        def set_arguments(*args)
          @arguments = Arguments.new
          add_arguments(*args)
        end

        # add arguments to existing args
        def add_arguments(*args)
          @arguments ||= Arguments.new
          args.each_with_index do |arg,a|
            argk, argv = *parse_arg(arg)
            
            # if the argument is not a known flag, is not a valid argument and the last argument was
            # a known flag, this must be a value for the last argument
            if !argument_flag?(arg) && !valid_argument?(argk) && (a > 0 && argument_flag?(args[a-1]))
              @arguments.last.value = arg
              next
            end

            # swap key/val to create an unnamed arg - if next argument is a valid flag we must be
            # a standalone argument
            if (!args[a+1] || valid_argument?(args[a+1])) && (argv.nil? || argv.empty?) && !Commands::exists?(arg)
              argv = argk
              argk = nil
            end

            raise InvalidArgument, "Invalid Argument: #{arg}" if validate_arguments? && !valid_argument?(argk)
            @arguments << argument_object(argk)
            @arguments.last.value = argv unless argv.empty?
          end
          @arguments
        end

        def parse_arg(arg)
          arga = arg.split("=")
          [arga.slice!(0), arga.join("=")] # rejoin with '=' in case there was an '=' in the passed value
        end
        
        def valid_argument?(key)
          valid_arguments.map(&:keys).flatten.include?(key)
        end

        def argument_flag?(arg)
          arg.match(/\A(-)+[a-z0-9\-]=?.*\Z/i)
        end

        def argument_object(key)
          valid_arguments.select { |varg| varg.keys.include?(key) }.first || Argument.new(key)
        end
      end

      module InstanceMethods
        %w(arguments valid_arguments).each do |method|
          define_method method do |*args|
            self.class.send method, *args
          end
        end
      end
    
    end
  end
end
