class DelayIterator
  def initialize(iter)
    @iter = iter
  end

  def each(proc, finished=nil)
    do_work = proc {
      begin
        item = @iter.next
      rescue StopIteration
        finished.call if finished
        return
      end

      proc.call(item)
      EM.next_tick(&do_work)
    }
    EM.next_tick(&do_work)
  end
end
