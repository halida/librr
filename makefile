# run command
run:
	ruby -I ./lib bin/librr search def
server:
	ruby -I ./lib bin/librr start --sync
test:
	rake spec
