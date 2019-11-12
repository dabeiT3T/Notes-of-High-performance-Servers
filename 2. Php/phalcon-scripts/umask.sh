#!/bin/bash

chown -R git:developer phalcon/
chmod -R 660 phalcon/
chmod 770 phalcon

dirs=$(find phalcon/*);

for foo in $dirs
do
    if [ -d $foo ]; then
        chmod 2770 $foo
    fi
done

exit 0
