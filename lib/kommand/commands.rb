module Kommand
  module Commands
    def self.commands
      @commands ||= []
    end

    def self.exists?(cmd)
      commands.map(&:command_name).include?(cmd.underscore.to_s)
    end

    def self.command(cmd)
      raise "Command does not exist: #{cmd}" unless exists?(cmd)
      commands.select { |command| command.command_name == cmd.underscore.to_s }.first
    end
  end
end

require 'kommand/commands/command'
require 'kommand/commands/help'
