-module(enterkey).
-include_lib("n2o/include/wf.hrl").
-include("records.hrl").
-export([render_action/1]).

render_action(#event_enterkey{postback = Postback, target = Element, sources = Sources}) ->
    PostbackScript = wf_event:new(Postback, Element, undefined, event, data(Sources)),
    [wf:f("$('#~s').bind('keyup', function (event) { if (event.keyCode == 13) {", [Element]),
     PostbackScript,
     "}});"].

data(Sources) -> "[" ++ string:join([source(atom_to_list(S)) || S <- Sources], ",") ++ "]".
source(S) -> "tuple(atom('" ++ S ++ "'), utf8.toByteArray($('#" ++ S ++ "').val()))".
