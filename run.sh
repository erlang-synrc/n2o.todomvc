#!/bin/sh
cd `dirname $0`

exec erl -pa $PWD/ebin -pa $PWD/deps/*/ebin -name todon2o"@"$HOSTNAME \
    -s todo_app start -config $PWD/priv/todon2o
