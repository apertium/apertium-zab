#!/bin/bash

linenr=`awk '/^0\s+[0-9]+\s+[^@]/ { print NR }' .deps/zab.autogen.att | head -n1`
grep -E "^0\s+[0-9]+\s+[^@]" .deps/zab.autogen.att | head -n1 > newfile.att
awk "NR != $linenr { print }" .deps/zab.autogen.att >> newfile.att
mv newfile.att .deps/zab.autogen.att
