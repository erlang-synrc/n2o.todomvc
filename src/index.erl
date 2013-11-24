-module(index).
-include_lib("n2o/include/wf.hrl").
-include("records.hrl").
-include("todos.hrl").
-export([main/0, event/1, loop/0]).

main() -> #dtl{file = "index", ext = "dtl", bindings = [{todoapp, todoapp()}]}.

sorted_todos() -> lists:sort(fun(#todo{id = Id1}, #todo{id = Id2}) -> Id1 > Id2 end, todos:all()).

todos_partition(Todos) -> lists:partition(fun (#todo{completed = C}) -> C end, Todos).

todo(#todo{id = Id, title = Title, completed = Completed} = Todo) ->
    Classes = if Completed -> [<<"completed">>]; true -> [] end,
    #li{class = Classes, body = [
      #panel{class = <<"view">>, body = [
        #check{class = <<"toggle">>, checked = Completed, postback = {toggle, Todo}},
        #label{body = Title},
        #button{class = <<"destroy">>}]},
      #textbox{class = <<"edit">>, value = Title}]}.

todos_body(Todos) -> [todo(T) || T <- Todos].

todo_count_body(Todos) -> [#strong{body = integer_to_binary(length(Todos))}, <<" item left">>].

clear_completed_body(Todos) -> [<<"Clear completed (">>, integer_to_binary(length(Todos)), <<")">>].

todoapp() ->
    {ok, Pid} = wf:async(fun loop/0),
    wf:wire(#event_enterkey{postback = {new_todo, Pid}, target = new_todo, sources = [new_todo]}),
    Todos = sorted_todos(),
    {Completed, Active} = todos_partition(Todos),
    [
      #header{id = header, body = [
        #h1{body = <<"todos">>},
        #textbox{id = new_todo, placeholder = <<"What needs to be done?">>}]},
      #section{id = main, body = [
        #check{id = toggle_all, checked = Active =:= [], postback = {toggle_all, Pid}},
        #label{for = toggle_all, body = <<"Mark all as complete">>},
        #list{id = todo_list, body = todos_body(Todos)}]},
      #footer{id = footer, body = [
        #span{id = todo_count, body = todo_count_body(Active)},
        #list{id = filters, body = [
          #li{body = #link{class = <<"selected">>, body = <<"All">>}},
          #li{body = #link{body = <<"Active">>}},
          #li{body = #link{body = <<"Completed">>}}]},
        #button{id = clear_completed, body = clear_completed_body(Completed), postback = {clear_completed, Pid}}]}].


update() ->
    Todos = sorted_todos(),
    {Completed, Active} = todos_partition(Todos),
    wf:wire(wf:f("$('#toggle_all').attr('checked', ~s);", [Active =:= []])),
    wf:update(todo_list, todos_body(Todos)),
    wf:update(todo_count, todo_count_body(Active)),
    wf:update(clear_completed, clear_completed_body(Completed)),
    wf:flush(room).


event(init) -> wf:reg(room);

event({new_todo, LoopPid}) ->
    Todo = wf:q(new_todo),
    case Todo =/= "" of
        true ->
            todos:insert(Todo),
            wf:wire("$('#new_todo').val('');"),
            LoopPid ! update;
        false -> ok
    end;

event({toggle_all, LoopPid}) ->
    case todos_partition(todos:all()) of
        {Completed, []} ->
            [todos:update(T#todo{completed = false}) || T <- Completed];
        {_, Active} ->
            [todos:update(T#todo{completed = true}) || T <- Active]
    end,
    LoopPid ! update;

event({clear_completed, LoopPid}) ->
    {Completed, _} = todos_partition(todos:all()),
    [todos:delete(T) || T <- Completed],
    LoopPid ! update;

event(Event) -> error_logger:info_msg("Event: ~p~n", [Event]).


loop() ->
    receive
        update  -> update();
        Unknown -> error_logger:info_msg("Unknown loop message: ~p~n", [Unknown])
    end,
    loop().
