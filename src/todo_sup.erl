-module(todo_sup).
-behaviour(supervisor).
-export([start_link/0]).
-export([init/1]).
-define(APP, todon2o).

start_link() -> supervisor:start_link({local, ?MODULE}, ?MODULE, []).

init([]) ->
    {ok, _} = cowboy:start_http(http, 100,
                                [{port, 8000}],
                                [{env, [{dispatch, dispatch_rules()}]}]),
    todos:init(),
    {ok, {{one_for_one, 5, 10}, []}}.

dispatch_rules() ->
    cowboy_router:compile(
      [{'_', [
                  {"/assets/[...]", cowboy_static,
                {priv_dir, ?APP, <<"assets">>,[{mimetypes,cow_mimetypes,all}]}},
              {"/ws/[...]", bullet_handler, [{handler, n2o_bullet}]},
              {'_', n2o_cowboy, []}]}]).
