#!/usr/bin/env bash

open -a Terminal ~/Dropbox/Work/code/tss/run-server.sh

sleep 15

acc/add-examples.sh generic

open http://apps.dekt-dev.io:8877/dashboard/

#architects: localhost:8877/admin/#/starters
#devs: localhost:8877/dashboard/#/
