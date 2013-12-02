# usage:
# ruby sync_dir.rb [DIR] [CMD]
#
# like:
# ruby sync_dir.rb . "rsync -pr ./ user@xxx.com:/fda/fdas"

require 'rb-fsevent'


def main
  fsevent = FSEvent.new

  dir = ARGV[0]
  cmd = ARGV[1]

  dir = File.expand_path(dir)
  fsevent.watch dir do |filename|
    puts "onchange file: #{filename}"
    system cmd
    puts "finish run cmd: #{cmd}"
  end

  fsevent.run
end

main
