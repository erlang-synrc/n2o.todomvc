-module(index).
-compile(export_all).
-include_lib("n2o/include/wf.hrl").
-include("records.hrl").
-include("todos.hrl").

main() -> #dtl{file = "index", ext = "dtl", bindings = [{todoapp, todoapp()}]}.

checkbox(Id) -> checkbox(Id, undefined).
checkbox(Id, Class) -> checkbox(Id, Class, false).
checkbox(Id, Class, Checked) ->
    wf_tags:emit_tag(<<"input">>, [], [{<<"type">>, <<"checkbox">>},
                                       {<<"id">>, Id},
                                       {<<"class">>, Class},
                                       {<<"checked">>, if Checked -> <<"checked">>; true -> undefined end}]).

todo(#todo{id = Id, title = Title, completed = Completed}) ->
    Classes = case Completed of true -> [<<"completed">>]; false -> [] end,
    #li{class = Classes, id = ["todo_", integer_to_list(Id)], body = [
      #panel{class = <<"view">>, body = [
        checkbox(undefined, <<"toggle">>, Completed),
        #label{body = Title},
        #button{class = <<"destroy">>}]},
      #textbox{class = <<"edit">>, value = Title}]}.

todos() ->
    #list{id = todo_list, body = [todo(T) || T <- lists:sort(fun(#todo{id = Id1}, #todo{id = Id2}) -> Id1 > Id2 end, todos:all())]}.

todoapp() ->
    wf:wire(#event_enterkey{postback = new_todo, target = new_todo, sources = [new_todo]}),
    Completed = todos:find_all_by_complete(true),
    Active = todos:find_all_by_complete(false),
    [
      #header{id = <<"header">>, body = [
        #h1{body = <<"todos">>},
        #textbox{id = new_todo, placeholder = <<"What needs to be done?">>}]},
      #section{id = <<"main">>, body = [
        checkbox(<<"toggle-all">>),
        #label{for = <<"toggle-all">>, body = <<"Mark all as complete">>},
        todos()]},
      #footer{id = <<"footer">>, body = [
        #span{id = <<"todo-count">>, body = [#strong{body = integer_to_binary(length(Active))}, <<" item left">>]},
        #list{id = <<"filters">>, body = [
          #li{body = #link{class = <<"selected">>, body = <<"All">>}},
          #li{body = #link{body = <<"Active">>}},
          #li{body = #link{body = <<"Completed">>}}]},
        #button{id = <<"clear-completed">>, body = [<<"Clear completed (">>, integer_to_binary(length(Completed)), <<")">>]}]}].

update() ->
    wf:replace(todo_list, todos()).

%event(init) -> update();
event(new_todo) ->
    Todo = wf:q(new_todo),
    case Todo =/= "" of
        true ->
            todos:insert(Todo),
            wf:wire("$('#new_todo').val('');"),
            update();
        false -> ok
    end;

event(Event) -> error_logger:info_msg("Event: ~p~n", [Event]).
