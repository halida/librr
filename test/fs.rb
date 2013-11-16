require 'rb-fsevent'

fsevent = FSEvent.new
fsevent.watch Dir.pwd do |directories|
  puts "Detected change inside: #{directories.inspect}"
end
fsevent.run
