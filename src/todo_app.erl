-module(todo_app).
-behaviour(application).
-export([start/0, start/2, stop/1]).
-define(APPS, [sync, crypto, ranch, cowboy, gproc, n2o, todon2o]).

start() -> [application:start(A) || A <- ?APPS].
start(_StartType, _StartArgs) -> todo_sup:start_link().
stop(_State) -> ok.
