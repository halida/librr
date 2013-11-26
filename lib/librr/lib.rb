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


def fix_encoding text
  # solution copy from:
  # http://stackoverflow.com/questions/11375342/stringencode-not-fixing-invalid-byte-sequence-in-utf-8-error
  text
    .encode('UTF-16', undef: :replace, invalid: :replace, replace: "")
    .encode('UTF-8')
end
