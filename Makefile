all: get-deps compile run

get-deps:
	rebar get-deps

compile:
	rebar compile

clean:
	rebar clean

run:
	./run.sh
