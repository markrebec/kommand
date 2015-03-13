require "kommand/version"

module Kommand
  def self.kommand
    File.basename($0)
  end
end
