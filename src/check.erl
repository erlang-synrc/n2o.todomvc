-module(check).
-include_lib("n2o/include/wf.hrl").
-include("records.hrl").
-export([render_element/1]).

render_element(#check{id = CheckId, class = Class, checked = Checked, body = Body, postback = Pb}) ->
    Id = case Pb of
             undefined -> CheckId;
             _ ->
                 PbId = if CheckId =:= undefined -> wf:temp_id(); true -> CheckId end,
                 wf:wire(#event{type = change, postback = Pb, target = PbId}),
                 PbId
         end,
    wf_tags:emit_tag(<<"input">>, wf:render(Body), [
        {<<"type">>,    <<"checkbox">>},
        {<<"id">>,      Id},
        {<<"class">>,   Class},
        {<<"checked">>, if Checked -> <<"checked">>; true -> undefined end}]).
