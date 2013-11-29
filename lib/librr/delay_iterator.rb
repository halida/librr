class DelayIterator
  def initialize(iter)
    @iter = iter
  end

  def each(proc, finished=nil)
    do_work = proc {
      begin
        item = @iter.next
        proc.call(item)
        EM.next_tick(&do_work)
      rescue StopIteration
        finished.call if finished
      end
    }
    EM.next_tick(&do_work)
  end
end
