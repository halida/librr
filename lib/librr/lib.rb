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

