-module(todos).
-include_lib("stdlib/include/ms_transform.hrl").
-include("todos.hrl").
-export([init/0, all/0, find/1, find_all_by_complete/1, insert/1, update/1, delete/1]).

init() -> ets:new(todos, [public, named_table, {keypos, #todo.id}]).
all() -> ets:tab2list(todos).
find(Id) -> [T | _] = ets:lookup(todos, Id), T.
find_all_by_complete(Completed) ->
    ets:select(todos, ets:fun2ms(fun(T = #todo{completed = C}) when C =:= Completed -> T end)).
insert(Title) -> ets:insert(todos, #todo{id = next_id(), title = Title}).
update(Todo) -> ets:insert(todos, Todo).
delete(Id) -> ets:delete(todos, Id).

next_id() -> ets:foldl(fun(#todo{id = Id}, Max) ->
                               if Id > Max -> Id; true -> Max end
                       end, 0, todos) + 1.
