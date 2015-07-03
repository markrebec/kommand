module Kommand
  module Scripts
    class Arguments < Array

      def named
        args = self.class.new
        args.concat(select { |arg| !arg.unnamed? })
      end

      def unnamed
        args = self.class.new
        args.concat(select { |arg| arg.unnamed? })
      end

      def arg(key)
        named.select { |arg| arg.name.to_s == key.to_s }.first
      end

      def arg?(key)
        !arg(key).nil?
      end

      def get(key)
        arg?(key) ? arg(key).value : nil
      end

      def to_s
        map do |arg|
          #if arg.valid.nil? || arg.valid.empty?
            "[#{arg.keys.join(", ")}]"
          #else
          #  "[#{arg.keys.join(", ")} = (#{arg.valid.join("|")})]"
          #end
        end.join(" ")
      end

      def to_help
        map do |arg|
          "  #{"%-#{sort { |a,b| a.keys.join(", ").length <=> b.keys.join(", ").length }.last.keys.join(", ").length + 2}s" % arg.keys.join(", ")}# #{arg.summary}"
        end.join("\n")
      end

      protected

      def initialize
        super
      end
    end
  end
end
