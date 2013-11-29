# run command
run:
	bin/librr search def -d
server:
	bin/librr daemon start -s -d
test:
	rake spec
gem:
	gem build librr.gemspec
install: gem
	gem install --local *.gem
