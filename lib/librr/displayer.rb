module Librr::Displayer

  class << self
    attr_accessor :save_output, :output

    def clear_output
      @output = []
    end

    def save(text)
      @output ||= []
      @output << text
    end

  end

  def show text
    if Librr::Displayer.save_output
      Librr::Displayer.save(text)
      return
    end

    puts text
  end

end
