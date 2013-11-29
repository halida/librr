# run command
run:
	bin/librr search def -d
server:
	bin/librr daemon start -s
test:
	rake spec
gem:
	rm *.gem
	gem build librr.gemspec
publish: gem
	gem push *.gem
install: gem
	gem install --local *.gem
