-module(sequence_server_tests).
-compile(export_all).
-include_lib("eunit/include/eunit.hrl").

get_sequence_test_() ->
	[{setup, fun() ->
			{ok, Pid} = sequence_server:start_link(),
			Pid end,
	fun(P) ->
		exit(P, shutdown) end,
	[fun() ->
		Sequence = sequence_server:get_sequence(impression),
		?assert(Sequence > 0),
		Sequence2 = sequence_server:get_sequence(impression),
		?assert(Sequence2 =:= Sequence + 1) end
	]}].