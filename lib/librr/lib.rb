def redirect_std
  stdin = $stdin.dup
  stdout = $stdout.dup
  stderr = $stderr.dup

  ri, wi = IO::pipe
  ro, wo = IO::pipe
  re, we = IO::pipe

  $stdin.reopen ri
  $stdout.reopen wo
  $stderr.reopen we

  yield

  $stdin.reopen stdin
  $stdout.reopen stdout
  $stderr.reopen stderr
  [wi, ro, re]
end

def redirect_std_to_file(filename)
  f = File.open(filename, 'a+')
  f.sync = true

  $stdout.reopen f
  $stderr.reopen f

  yield
end


def fix_encoding text
  # solution copy from:
  # http://stackoverflow.com/questions/11375342/stringencode-not-fixing-invalid-byte-sequence-in-utf-8-error
  text
    .encode('UTF-16', undef: :replace, invalid: :replace, replace: "")
    .encode('UTF-8')
end

def kill_process_by_file file
  begin
    pid = File.read(file).to_i
    Process.kill 'TERM', pid if pid > 0
    File.delete file
  rescue
  end
end

# colorize terminal
class String
  COLORS = {
    :red => "\033[31m",
    :green => "\033[32m",
    :yellow => "\033[33m",
    :blue => "\033[34m"
  }
  def colorize(color)
    "#{COLORS[color]}#{self}\033[0m"
  end
end
