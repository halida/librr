require 'thor'

class Librr::CMD < Thor
  def hello
    puts 'fdsasd'
  end

  def self.run!
    self.start(ARGV)
  end
end
