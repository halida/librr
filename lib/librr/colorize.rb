# colorize terminal
module Colorize
  COLORS = {
    :red => "\033[31m",
    :green => "\033[32m",
    :yellow => "\033[33m",
    :blue => "\033[34m"
  }

  def self.set text, color
    raise "Color not support: #{color}" unless COLORS.include?(color)
    "#{COLORS[color]}#{text}\033[0m"
  end
end
