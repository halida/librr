def restart
  cmd = "ruby #{$0} #{ARGV.join(' ')}"
  puts cmd
  IO.popen(cmd)
  sleep 1
end

def working
  sleep 1
  puts Time.now
  puts "working"
end

working
restart
