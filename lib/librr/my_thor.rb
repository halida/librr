require 'thor'

class MyThor < Thor
  class_option :debug, type: :boolean, aliases: "-d"

  class << self

    protected

    def method_added(meth)
      meth = meth.to_s
      @my_defined_methods ||= {}
      return if @my_defined_methods[meth] or meth =~ /_old_/
      @my_defined_methods[meth] = true
      my_wrap_methods(meth)

      super(meth)
    end

    def my_wrap_methods(meth)
      old_meth = "_old_#{meth}"
      alias_method old_meth, meth

      define_method meth do |*args|
        # set logger
        if options[:debug]
          Librr::Logger.instance.set_level Logger::DEBUG
        end

        self.send(old_meth, *args)
      end
    end

  end

end
