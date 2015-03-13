require 'active_support/inflector'
require 'kommand'
require 'kommand/scripts'
require 'kommand/commands'

module Kommand
  class CLI
    include Scripts::Script

    def self.inherited(sub)
      sub.send :valid_argument, Scripts::Argument.new("-v, --verbose", :valid => [], :summary => "Output additional information from command executions to STDOUT")
      sub.send :valid_argument, Scripts::Argument.new("-d, --debug", :valid => [], :summary => "Output full backtraces for exceptions and errors")
    end

    valid_argument Scripts::Argument.new("-v, --verbose", :valid => [], :summary => "Output additional information from command executions to STDOUT")
    valid_argument Scripts::Argument.new("-d, --debug", :valid => [], :summary => "Output full backtraces for exceptions and errors")

    def self.verbose?
      user_arguments.map(&:key).include?("-v")
    end

    def self.debug?
      user_arguments.map(&:key).include?("-d")
    end

    def self.exec(cmd)
      if verbose?
        system cmd
      else
        `#{cmd}`
      end
    end
    
    def self.add_arguments(*args)
      keep = []
      args.each_with_index do |arg,a|
        if Commands::exists?(arg)
          begin
            @command = Commands::command(arg)
            @command.set_arguments(*args.slice(a+1,args.length-a))
          rescue Scripts::InvalidArgument => e
            puts e.message
            Commands::command(arg).usage
            exit 1
          end
          break
        end

        keep << arg
      end
      super(*keep)
    end

    def self.binary=(bin)
      @binary = bin
    end

    def self.binary
      @binary ||= Kommand.kommand
    end

    def self.command_name
      binary
    end

    def self.version=(ver)
      @version = ver
    end

    def self.version
      @version ||= VERSION
    end

    def self.usage
      puts "#{binary} v#{version}"
      puts
      puts "usage: #{binary} #{valid_arguments.to_s} <command> [<args>]"
      unless valid_arguments.empty?
        puts
        puts "Arguments:"
        puts valid_arguments.to_help
      end
      puts
      puts "The available #{binary} commands are:"
      
      Commands::commands.each do |cmd|
        print "   %-#{Commands::commands.sort { |a,b| a.command_name.length <=> b.command_name.length }.last.command_name.length + 2}s" % cmd.command_name
        puts "# #{cmd.command_summary}"
      end

      puts
      puts "See `#{binary} help <command>` for more information on a specific command."
    end
    
    def self.start(*args)
      args = args[0] if args.length == 1 && args.first.is_a?(Array)
      begin
        set_arguments(*args)
      rescue Scripts::InvalidArgument => e
        puts e.message
        return
      rescue Exception => e
        usage
        return
      end

      if @command.nil?
        usage
        return
      end

      @command.run
    end
  
  end
end
