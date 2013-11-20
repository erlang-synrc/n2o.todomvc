#!/bin/sh
cd `dirname $0`

exec erl -pa $PWD/ebin -pa $PWD/deps/*/ebin \
    -s todo_app start -config $PWD/priv/todon2o
