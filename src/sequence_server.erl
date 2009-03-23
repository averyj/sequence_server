%%%-------------------------------------------------------------------
%%% File:      sequence_server.erl
%%% @author    James Avery
%%% @copyright 2009 James Avery
%%% @doc
%%%
%%% @end
%%%
%%% @since 2009-03-18 by James Avery
%%%-------------------------------------------------------------------
-module(sequence_server).
-author('James Avery').

-behaviour(gen_server).
-export([start_link/0, get_sequence/1]).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2,
        terminate/2, code_change/3]).

-record(sequence, {id, sequence}).
-record(state, {}).

start_link() ->
  gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).

get_sequence(Id) ->
  mnesia:wait_for_tables([sequence], infinity),
  gen_server:call(?MODULE, {get_sequence, Id}).

init([]) ->
  mnesia:start(),
  mnesia:create_schema([node()]),
  mnesia:create_table(sequence, [{attributes, record_info(fields, sequence)},
                                 {type, ordered_set},
                                 {disc_copies, [node()]}]),
  {ok, #state{}}.

handle_call({get_sequence, Id}, _From, State) ->
  F = fun() ->
    Return = mnesia:read(sequence, Id, write),
    case Return of
      [S] ->
        Seq = S#sequence.sequence,
        New = S#sequence{sequence = Seq + 1},
        mnesia:write(New),
        Seq;
      [] ->
        SequenceRecord = #sequence{id = Id, sequence = 2},
        mnesia:write(SequenceRecord),
        1
    end
  end,
  {atomic, Seq} = mnesia:transaction(F),
  {reply, Seq, State};

handle_call(_Request, _From, State) ->
  Reply = ok,
  {reply, Reply, State}.

handle_cast(_Msg, State) ->
  {noreply, State}.

handle_info(_Info, State) ->
  {noreply, State}.

terminate(_Reason, _State) ->
  ok.

code_change(_OldVsn, State, _Extra) ->
  {ok, State}.