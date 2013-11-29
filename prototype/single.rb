require 'singleton'

class Abc
  include Singleton

  def work
    puts 'work'
  end
end

Abc.instance.work
