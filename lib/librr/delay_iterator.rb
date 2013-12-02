class DelayIterator
  def initialize(iter)
    @iter = iter
  end

  def each(proc, finished=nil)
    @finished = finished
    @do_work = proc {
      begin
        item = @iter.next
        proc.call(item, self)
      rescue StopIteration
        finished.call if finished
      end
    }
    self.next
  end

  def next
    EM.next_tick(&@do_work)
  end

  def end
    @finished.call if @finished
  end
end
