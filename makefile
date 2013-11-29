# run command
run:
	bin/librr search def
server:
	bin/librr daemon_start --sync
test:
	rake spec
gem:
	gem build librr.gemspec
install: gem
	gem install --local *.gem
